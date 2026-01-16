import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/backend_config.dart';

/// Servicio WebSocket para comunicación en tiempo real con el servidor de juego.
///
/// Maneja la conexión al namespace /multiplayer-sessions y todos los eventos
/// del protocolo de juego multijugador.
class MultiplayerSocketService {
  io.Socket? _socket;

  // Stream controllers para cada evento del servidor
  final _hostLobbyUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerConnectedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _questionStartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerAnswerConfirmationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _hostAnswerUpdateController = StreamController<int>.broadcast();
  final _playerResultsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _hostResultsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerGameEndController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _hostGameEndController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _sessionClosedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _hostLeftController = StreamController<String>.broadcast();
  final _hostReturnedController = StreamController<String>.broadcast();
  final _gameErrorController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _syncErrorController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionErrorController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Streams públicos
  Stream<Map<String, dynamic>> get hostLobbyUpdates =>
      _hostLobbyUpdateController.stream;
  Stream<Map<String, dynamic>> get playerConnected =>
      _playerConnectedController.stream;
  Stream<Map<String, dynamic>> get questionStarted =>
      _questionStartedController.stream;
  Stream<Map<String, dynamic>> get playerAnswerConfirmation =>
      _playerAnswerConfirmationController.stream;
  Stream<int> get hostAnswerUpdate => _hostAnswerUpdateController.stream;
  Stream<Map<String, dynamic>> get playerResults =>
      _playerResultsController.stream;
  Stream<Map<String, dynamic>> get hostResults => _hostResultsController.stream;
  Stream<Map<String, dynamic>> get playerGameEnd =>
      _playerGameEndController.stream;
  Stream<Map<String, dynamic>> get hostGameEnd => _hostGameEndController.stream;
  Stream<Map<String, dynamic>> get sessionClosed =>
      _sessionClosedController.stream;
  Stream<Map<String, dynamic>> get playerLeft => _playerLeftController.stream;
  Stream<String> get hostLeft => _hostLeftController.stream;
  Stream<String> get hostReturned => _hostReturnedController.stream;
  Stream<Map<String, dynamic>> get gameErrors => _gameErrorController.stream;
  Stream<Map<String, dynamic>> get syncErrors => _syncErrorController.stream;
  Stream<Map<String, dynamic>> get connectionErrors =>
      _connectionErrorController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Conectar al servidor WebSocket.
  ///
  /// [pin] - PIN de la sesión
  /// [role] - 'HOST' o 'PLAYER'
  /// [jwt] - Token JWT del usuario
  Future<void> connect({
    required String pin,
    required String role,
    required String jwt,
  }) async {
    final baseUrl = BackendSettings.baseUrl.replaceAll('/api', '');

    debugPrint('🔌 [Socket] Connecting to $baseUrl/multiplayer-sessions');
    debugPrint(
      '🔌 [Socket] Handshake Data: pin=$pin, role=$role, jwt=${jwt.isNotEmpty ? "PRESENT" : "MISSING"}',
    );

    _socket = io.io(
      '$baseUrl/multiplayer-sessions',
      io.OptionBuilder()
          .setQuery({'pin': pin, 'role': role, 'jwt': jwt})
          .setExtraHeaders({
            'pin': pin,
            'role': role,
            'jwt': jwt,
            'authorization': 'Bearer $jwt',
          })
          .setAuth({
            'pin': pin,
            'role': role,
            'jwt': jwt,
            'authorization': 'Bearer $jwt',
          })
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _setupListeners();

    // Esperar a que se conecte
    final completer = Completer<void>();

    _socket!.onConnect((_) {
      debugPrint('🔌 [Socket] Connected!');
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onConnectError((error) {
      debugPrint('🔌 [Socket] Connection Error: $error');
      if (!completer.isCompleted) {
        completer.completeError(Exception('Error de conexión: $error'));
      }
    });

    _socket!.onDisconnect((reason) {
      debugPrint('🔌 [Socket] Disconnected: $reason');
      // If disconnected while waiting to connect, it's a failure (e.g. invalid PIN)
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Conexión rechazada por el servidor (¿PIN inválido?)'),
        );
      }
    });

    _socket!.connect();

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout al conectar con el servidor'),
    );
  }

  /// Configurar todos los listeners de eventos del servidor.
  void _setupListeners() {
    if (_socket == null) return;

    // HOST_CONNECTED_SUCCESS - Confirmación de conexión del host
    _socket!.on('HOST_CONNECTED_SUCCESS', (data) {
      debugPrint('🔌 [Socket] HOST_CONNECTED_SUCCESS: $data');
    });

    // DEBUG: Listen to all events
    _socket!.onAny((event, data) {
      debugPrint('🔥 [Socket ANY] Event: $event, Data: $data');
    });

    // host_lobby_update - Actualización del lobby para el host
    _socket!.on('host_lobby_update', (data) {
      debugPrint('🔌 [Socket] host_lobby_update: $data');
      if (data is Map<String, dynamic>) {
        _hostLobbyUpdateController.add(data);
      }
    });

    // player_connected_to_session - Jugador conectado exitosamente
    _socket!.on('player_connected_to_session', (data) {
      debugPrint('🔌 [Socket] player_connected_to_session: $data');
      if (data is Map<String, dynamic>) {
        _playerConnectedController.add(data);
      }
    });

    // question_started - Nueva pregunta iniciada
    _socket!.on('question_started', (data) {
      debugPrint('🔌 [Socket] question_started: $data');
      if (data is Map<String, dynamic>) {
        _questionStartedController.add(data);
      }
    });

    // player_answer_confirmation - Confirmación de respuesta recibida
    _socket!.on('player_answer_confirmation', (data) {
      debugPrint('🔌 [Socket] player_answer_confirmation: $data');
      if (data is Map<String, dynamic>) {
        _playerAnswerConfirmationController.add(data);
      }
    });

    // host_answer_update - Actualización de respuestas para el host
    _socket!.on('host_answer_update', (data) {
      debugPrint('🔌 [Socket] host_answer_update: $data');
      if (data is Map<String, dynamic>) {
        final submissions = data['numberOfSubmissions'] as int? ?? 0;
        _hostAnswerUpdateController.add(submissions);
      }
    });

    // player_results - Resultados para el jugador
    _socket!.on('player_results', (data) {
      debugPrint('🔌 [Socket] player_results: $data');
      if (data is Map<String, dynamic>) {
        _playerResultsController.add(data);
      }
    });

    // host_results - Resultados para el host
    _socket!.on('host_results', (data) {
      debugPrint('🔌 [Socket] host_results: $data');
      if (data is Map<String, dynamic>) {
        _hostResultsController.add(data);
      }
    });

    // player_game_end - Fin del juego para el jugador
    _socket!.on('player_game_end', (data) {
      debugPrint('🔌 [Socket] player_game_end: $data');
      if (data is Map<String, dynamic>) {
        _playerGameEndController.add(data);
      }
    });

    // host_game_end - Fin del juego para el host
    _socket!.on('host_game_end', (data) {
      debugPrint('🔌 [Socket] host_game_end: $data');
      if (data is Map<String, dynamic>) {
        _hostGameEndController.add(data);
      }
    });

    // session_closed - Sesión cerrada
    _socket!.on('session_closed', (data) {
      debugPrint('🔌 [Socket] session_closed: $data');
      if (data is Map<String, dynamic>) {
        _sessionClosedController.add(data);
      }
    });

    // player_left_session - Jugador abandonó
    _socket!.on('player_left_session', (data) {
      debugPrint('🔌 [Socket] player_left_session: $data');
      if (data is Map<String, dynamic>) {
        _playerLeftController.add(data);
      }
    });

    // host_left_session - Host abandonó
    _socket!.on('host_left_session', (data) {
      debugPrint('🔌 [Socket] host_left_session: $data');
      if (data is Map<String, dynamic>) {
        _hostLeftController.add(
          data['message'] as String? ?? 'El host se ha desconectado',
        );
      }
    });

    // host_returned_to_session - Host regresó
    _socket!.on('host_returned_to_session', (data) {
      debugPrint('🔌 [Socket] host_returned_to_session: $data');
      if (data is Map<String, dynamic>) {
        _hostReturnedController.add(
          data['message'] as String? ?? 'El host ha regresado',
        );
      }
    });

    // game_error - Error del juego
    _socket!.on('game_error', (data) {
      debugPrint('🔌 [Socket] game_error: $data');
      if (data is Map<String, dynamic>) {
        _gameErrorController.add(data);
      }
    });

    // sync_error - Error de sincronización
    _socket!.on('SYNC_ERROR', (data) {
      debugPrint('🔌 [Socket] SYNC_ERROR: $data');
      if (data is Map<String, dynamic>) {
        _syncErrorController.add(data);
      }
    });

    // connection_error - Error de conexión
    _socket!.on('connection_error', (data) {
      debugPrint('🔌 [Socket] connection_error: $data');
      if (data is Map<String, dynamic>) {
        _connectionErrorController.add(data);
      }
    });

    // fatal_error - Errores fatales (ej. 400 Bad Request)
    _socket!.on('fatal_error', (data) {
      debugPrint('🚨 [Socket] fatal_error: $data');
      if (data is Map<String, dynamic>) {
        // Re-use game error controller to propagate this to UI
        _gameErrorController.add(data);
      }
    });
  }

  // ============ Eventos del Cliente ============

  /// Emitir client_ready después de suscribirse a todos los listeners.
  void emitClientReady() {
    debugPrint('🔌 [Socket] Emitting client_ready');
    _socket?.emit('client_ready');
  }

  /// Jugador se une con nickname.
  void emitPlayerJoin(String nickname) {
    debugPrint('🔌 [Socket] Emitting player_join: $nickname');
    _socket?.emit('player_join', {'nickname': nickname});
  }

  /// Host inicia el juego.
  void emitHostStartGame() {
    debugPrint('🔌 [Socket] Emitting host_start_game');
    _socket?.emit('host_start_game');
  }

  /// Jugador envía respuesta.
  void emitPlayerSubmitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    debugPrint(
      '🔌 [Socket] Emitting player_submit_answer: questionId=$questionId, answers=$answerIds, time=$timeElapsedMs',
    );
    _socket?.emit('player_submit_answer', {
      'questionId': questionId,
      'answerId': answerIds,
      'timeElapsedMs': timeElapsedMs,
    });
  }

  /// Host avanza a la siguiente fase.
  void emitHostNextPhase() {
    debugPrint('🔌 [Socket] Emitting host_next_phase');
    _socket?.emit('host_next_phase');
  }

  /// Host cierra la sesión.
  void emitHostEndSession() {
    debugPrint('🔌 [Socket] Emitting host_end_session');
    _socket?.emit('host_end_session');
  }

  /// Desconectar del servidor.
  void disconnect() {
    debugPrint('🔌 [Socket] Disconnecting...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Liberar recursos.
  void dispose() {
    disconnect();
    _hostLobbyUpdateController.close();
    _playerConnectedController.close();
    _questionStartedController.close();
    _playerAnswerConfirmationController.close();
    _hostAnswerUpdateController.close();
    _playerResultsController.close();
    _hostResultsController.close();
    _playerGameEndController.close();
    _hostGameEndController.close();
    _sessionClosedController.close();
    _playerLeftController.close();
    _hostLeftController.close();
    _hostReturnedController.close();
    _gameErrorController.close();
    _syncErrorController.close();
    _connectionErrorController.close();
  }
}
