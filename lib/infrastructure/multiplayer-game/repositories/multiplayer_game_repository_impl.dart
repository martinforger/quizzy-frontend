import 'dart:async';
import '../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';
import '../../../domain/multiplayer-game/entities/session_entity.dart';
import '../../../domain/multiplayer-game/entities/lobby_state_entity.dart';
import '../../../domain/multiplayer-game/entities/multiplayer_slide_entity.dart';
import '../../../domain/multiplayer-game/entities/results_entity.dart';
import '../../../domain/multiplayer-game/entities/game_end_entity.dart';
import '../data_sources/multiplayer_session_http_service.dart';
import '../data_sources/multiplayer_socket_service.dart';
import '../models/session_model.dart';
import '../models/lobby_state_model.dart';
import '../models/question_state_model.dart';
import '../models/results_model.dart';
import '../models/game_end_model.dart';

/// Implementación del repositorio de juego multijugador.
///
/// Combina servicios HTTP y WebSocket para proporcionar una interfaz
/// unificada para el motor de juego en vivo.
class MultiplayerGameRepositoryImpl implements MultiplayerGameRepository {
  final MultiplayerSessionHttpService _httpService;
  final MultiplayerSocketService _socketService;

  MultiplayerGameRepositoryImpl(this._httpService, this._socketService);

  // ============ HTTP Endpoints ============

  @override
  Future<SessionEntity> createSession(String kahootId) async {
    // Reintentar hasta 3 veces en caso de error de generación de PIN
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _httpService.createSession(kahootId);
        return SessionModel.fromJson(response);
      } on RetryableSessionException {
        if (attempt == 2) rethrow;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw Exception('Error al crear sesión después de 3 intentos');
  }

  @override
  Future<String> getSessionPinByQrToken(String qrToken) async {
    return await _httpService.getSessionPinByQrToken(qrToken);
  }

  // ============ WebSocket Connection ============

  @override
  Future<void> connect({
    required String pin,
    required MultiplayerRole role,
    required String jwt,
  }) async {
    final roleString = role == MultiplayerRole.host ? 'HOST' : 'PLAYER';
    await _socketService.connect(pin: pin, role: roleString, jwt: jwt);
  }

  @override
  void disconnect() => _socketService.disconnect();

  @override
  bool get isConnected => _socketService.isConnected;

  // ============ Client Events (Emit) ============

  @override
  void emitClientReady() => _socketService.emitClientReady();

  @override
  void emitPlayerJoin(String nickname) =>
      _socketService.emitPlayerJoin(nickname);

  @override
  void emitHostStartGame() => _socketService.emitHostStartGame();

  @override
  void emitPlayerSubmitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    _socketService.emitPlayerSubmitAnswer(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: timeElapsedMs,
    );
  }

  @override
  void emitHostNextPhase() => _socketService.emitHostNextPhase();

  @override
  void emitHostEndSession() => _socketService.emitHostEndSession();

  // ============ Server Events (Streams) ============

  @override
  Stream<HostLobbyStateEntity> get hostLobbyUpdates => _socketService
      .hostLobbyUpdates
      .map((data) => HostLobbyStateModel.fromJson(data));

  @override
  Stream<PlayerLobbyStateEntity> get playerConnectedToSession => _socketService
      .playerConnected
      .map((data) => PlayerLobbyStateModel.fromJson(data));

  @override
  Stream<MultiplayerQuestionEntity> get questionStarted => _socketService
      .questionStarted
      .map((data) => MultiplayerQuestionModel.fromJson(data));

  @override
  Stream<AnswerConfirmationEntity> get playerAnswerConfirmation =>
      _socketService.playerAnswerConfirmation.map(
        (data) => AnswerConfirmationModel.fromJson(data),
      );

  @override
  Stream<int> get hostAnswerUpdate => _socketService.hostAnswerUpdate;

  @override
  Stream<PlayerResultsEntity> get playerResults => _socketService.playerResults
      .map((data) => PlayerResultsModel.fromJson(data));

  @override
  Stream<HostResultsEntity> get hostResults =>
      _socketService.hostResults.map((data) => HostResultsModel.fromJson(data));

  @override
  Stream<PlayerGameEndEntity> get playerGameEnd => _socketService.playerGameEnd
      .map((data) => PlayerGameEndModel.fromJson(data));

  @override
  Stream<HostGameEndEntity> get hostGameEnd =>
      _socketService.hostGameEnd.map((data) => HostGameEndModel.fromJson(data));

  @override
  Stream<SessionClosedEntity> get sessionClosed => _socketService.sessionClosed
      .map((data) => SessionClosedModel.fromJson(data));

  @override
  Stream<PlayerLeftEntity> get playerLeftSession =>
      _socketService.playerLeft.map((data) => PlayerLeftModel.fromJson(data));

  @override
  Stream<String> get hostLeftSession => _socketService.hostLeft;

  @override
  Stream<String> get hostReturnedToSession => _socketService.hostReturned;

  @override
  Stream<GameErrorEntity> get gameErrors =>
      _socketService.gameErrors.map((data) => GameErrorModel.fromJson(data));

  @override
  Stream<GameErrorEntity> get syncErrors =>
      _socketService.syncErrors.map((data) => GameErrorModel.fromJson(data));

  @override
  Stream<GameErrorEntity> get connectionErrors => _socketService
      .connectionErrors
      .map((data) => GameErrorModel.fromJson(data));

  /// Liberar recursos.
  void dispose() {
    _socketService.dispose();
  }
}
