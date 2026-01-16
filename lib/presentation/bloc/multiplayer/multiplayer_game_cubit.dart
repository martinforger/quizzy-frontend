import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/multiplayer-game/entities/session_entity.dart';
import '../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';
import '../../../application/multiplayer-game/usecases/create_session_use_case.dart';
import '../../../application/multiplayer-game/usecases/get_session_pin_use_case.dart';
import '../../../application/multiplayer-game/usecases/connect_to_session_use_case.dart';
import '../../../application/multiplayer-game/usecases/join_as_player_use_case.dart';
import '../../../application/multiplayer-game/usecases/start_game_use_case.dart';
import '../../../application/multiplayer-game/usecases/submit_answer_use_case.dart';
import '../../../application/multiplayer-game/usecases/next_phase_use_case.dart';
import '../../../application/multiplayer-game/usecases/end_session_use_case.dart';
import 'multiplayer_game_state.dart';

/// Cubit para manejar el estado del juego multijugador.
///
/// Gestiona tanto el flujo del HOST como del PLAYER, suscribiéndose
/// a los eventos del repositorio y actualizando el estado en consecuencia.
class MultiplayerGameCubit extends Cubit<MultiplayerGameState> {
  final CreateMultiplayerSessionUseCase _createSessionUseCase;
  final GetSessionPinByQrTokenUseCase _getSessionPinUseCase;
  final ConnectToSessionUseCase _connectUseCase;
  final JoinAsPlayerUseCase _joinAsPlayerUseCase;
  final StartMultiplayerGameUseCase _startGameUseCase;
  final SubmitMultiplayerAnswerUseCase _submitAnswerUseCase;
  final NextPhaseUseCase _nextPhaseUseCase;
  final EndSessionUseCase _endSessionUseCase;
  final MultiplayerGameRepository _repository;

  // Subscripciones a los streams
  final List<StreamSubscription> _subscriptions = [];

  // Estado interno
  MultiplayerRole? _currentRole;
  SessionEntity? _currentSession;

  MultiplayerGameCubit({
    required CreateMultiplayerSessionUseCase createSessionUseCase,
    required GetSessionPinByQrTokenUseCase getSessionPinUseCase,
    required ConnectToSessionUseCase connectUseCase,
    required JoinAsPlayerUseCase joinAsPlayerUseCase,
    required StartMultiplayerGameUseCase startGameUseCase,
    required SubmitMultiplayerAnswerUseCase submitAnswerUseCase,
    required NextPhaseUseCase nextPhaseUseCase,
    required EndSessionUseCase endSessionUseCase,
    required MultiplayerGameRepository repository,
  }) : _createSessionUseCase = createSessionUseCase,
       _getSessionPinUseCase = getSessionPinUseCase,
       _connectUseCase = connectUseCase,
       _joinAsPlayerUseCase = joinAsPlayerUseCase,
       _startGameUseCase = startGameUseCase,
       _submitAnswerUseCase = submitAnswerUseCase,
       _nextPhaseUseCase = nextPhaseUseCase,
       _endSessionUseCase = endSessionUseCase,
       _repository = repository,
       super(MultiplayerInitial());

  // ============ HOST Actions ============

  /// Host crea una nueva sesión y se conecta.
  Future<void> createSessionAsHost(String kahootId, String jwt) async {
    try {
      emit(MultiplayerConnecting());
      _currentRole = MultiplayerRole.host;

      // Crear sesión via HTTP
      _currentSession = await _createSessionUseCase(kahootId);

      // Conectar al WebSocket
      await _connectUseCase(
        pin: _currentSession!.sessionPin,
        role: MultiplayerRole.host,
        jwt: jwt,
      );

      // Suscribirse a eventos
      _subscribeToHostEvents();

      // Emitir client_ready para sincronización
      _repository.emitClientReady();

      // Mostrar lobby inicial
      emit(
        HostLobbyState(
          session: _currentSession!,
          players: [],
          numberOfPlayers: 0,
        ),
      );
    } catch (e) {
      emit(MultiplayerError(e.toString()));
    }
  }

  /// Host inicia el juego.
  void startGame() {
    _startGameUseCase();
  }

  /// Host avanza a la siguiente fase.
  void nextPhase() {
    _nextPhaseUseCase();
  }

  /// Host cierra la sesión.
  void endSession() {
    _endSessionUseCase();
  }

  // ============ PLAYER Actions ============

  /// Player se conecta con PIN.
  Future<void> connectAsPlayer(String pin, String jwt) async {
    try {
      emit(MultiplayerConnecting());
      _currentRole = MultiplayerRole.player;

      // Conectar al WebSocket
      await _connectUseCase(pin: pin, role: MultiplayerRole.player, jwt: jwt);

      // Suscribirse a eventos
      _subscribeToPlayerEvents();

      // Emitir client_ready para sincronización
      _repository.emitClientReady();

      // Mostrar lobby inicial (esperando player_connected_to_session)
      emit(
        PlayerLobbyState(
          nickname: '',
          connectedBefore: false,
          nicknameSubmitted: false,
        ),
      );
    } catch (e) {
      emit(MultiplayerError(e.toString()));
    }
  }

  /// Player obtiene PIN desde QR y se conecta.
  Future<void> connectWithQrToken(String qrToken, String jwt) async {
    try {
      emit(MultiplayerConnecting());

      // Obtener PIN desde el token QR
      final pin = await _getSessionPinUseCase(qrToken);

      // Conectar como player
      await connectAsPlayer(pin, jwt);
    } catch (e) {
      emit(MultiplayerError(e.toString()));
    }
  }

  /// Player envía su nickname para unirse.
  void joinWithNickname(String nickname) {
    _joinAsPlayerUseCase(nickname);
  }

  /// Player envía su respuesta.
  void submitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    _submitAnswerUseCase(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: timeElapsedMs,
    );

    // Marcar como respondido en el estado
    if (state is PlayerQuestionState) {
      emit((state as PlayerQuestionState).copyWith(hasAnswered: true));
    }
  }

  // ============ Event Subscriptions ============

  void _subscribeToHostEvents() {
    _subscriptions.add(
      _repository.hostLobbyUpdates.listen((lobby) {
        if (state is HostLobbyState) {
          emit(
            (state as HostLobbyState).copyWith(
              players: lobby.players,
              numberOfPlayers: lobby.numberOfPlayers,
            ),
          );
        } else if (_currentSession != null) {
          emit(
            HostLobbyState(
              session: _currentSession!,
              players: lobby.players,
              numberOfPlayers: lobby.numberOfPlayers,
            ),
          );
        }
      }),
    );

    _subscriptions.add(
      _repository.questionStarted.listen((question) {
        emit(HostQuestionState(question: question, submissionCount: 0));
      }),
    );

    _subscriptions.add(
      _repository.hostAnswerUpdate.listen((count) {
        if (state is HostQuestionState) {
          emit((state as HostQuestionState).copyWith(submissionCount: count));
        }
      }),
    );

    _subscriptions.add(
      _repository.hostResults.listen((results) {
        emit(HostResultsState(results));
      }),
    );

    _subscriptions.add(
      _repository.hostGameEnd.listen((gameEnd) {
        emit(HostGameEndState(gameEnd));
      }),
    );

    _subscribeToSharedEvents();
  }

  void _subscribeToPlayerEvents() {
    _subscriptions.add(
      _repository.playerConnectedToSession.listen((lobbyState) {
        emit(
          PlayerLobbyState(
            nickname: lobbyState.nickname,
            connectedBefore: lobbyState.connectedBefore,
            nicknameSubmitted: lobbyState.nickname.isNotEmpty,
          ),
        );
      }),
    );

    _subscriptions.add(
      _repository.questionStarted.listen((question) {
        emit(
          PlayerQuestionState(
            question: question,
            hasAnswered: question.hasAnswered ?? false,
          ),
        );
      }),
    );

    _subscriptions.add(
      _repository.playerAnswerConfirmation.listen((_) {
        if (state is PlayerQuestionState) {
          emit((state as PlayerQuestionState).copyWith(hasAnswered: true));
        }
      }),
    );

    _subscriptions.add(
      _repository.playerResults.listen((results) {
        emit(PlayerResultsState(results));
      }),
    );

    _subscriptions.add(
      _repository.playerGameEnd.listen((gameEnd) {
        emit(PlayerGameEndState(gameEnd));
      }),
    );

    _subscriptions.add(
      _repository.hostLeftSession.listen((message) {
        emit(HostDisconnected(message));
      }),
    );

    _subscriptions.add(
      _repository.hostReturnedToSession.listen((_) {
        // Si el host regresa mientras estamos en HostDisconnected,
        // volver al estado anterior o esperar siguiente evento
      }),
    );

    _subscribeToSharedEvents();
  }

  void _subscribeToSharedEvents() {
    _subscriptions.add(
      _repository.sessionClosed.listen((event) {
        emit(
          MultiplayerSessionClosed(
            reason: event.reason,
            message: event.message,
          ),
        );
      }),
    );

    _subscriptions.add(
      _repository.gameErrors.listen((error) {
        emit(MultiplayerError(error.message, code: error.code));
      }),
    );

    _subscriptions.add(
      _repository.syncErrors.listen((error) {
        emit(MultiplayerError(error.message, code: error.code));
      }),
    );

    _subscriptions.add(
      _repository.connectionErrors.listen((error) {
        emit(MultiplayerError(error.message, code: error.code));
      }),
    );
  }

  // ============ Cleanup ============

  /// Desconectar y limpiar recursos.
  void disconnect() {
    _repository.disconnect();
    reset();
  }

  /// Resetear al estado inicial.
  void reset() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _currentRole = null;
    _currentSession = null;
    emit(MultiplayerInitial());
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
