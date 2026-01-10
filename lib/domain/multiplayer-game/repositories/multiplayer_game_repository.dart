import '../entities/session_entity.dart';
import '../entities/lobby_state_entity.dart';
import '../entities/multiplayer_slide_entity.dart';
import '../entities/results_entity.dart';
import '../entities/game_end_entity.dart';

/// Rol del usuario en la sesión multijugador.
enum MultiplayerRole { host, player }

/// Repositorio abstracto para el juego multijugador.
///
/// Define las operaciones HTTP y WebSocket necesarias para
/// el motor de juego en vivo.
abstract class MultiplayerGameRepository {
  // ============ HTTP Endpoints ============

  /// H4.1 - Crear una nueva sesión multijugador.
  /// POST /multiplayer-sessions
  Future<SessionEntity> createSession(String kahootId);

  /// H4.3 - Obtener PIN de sesión por token QR.
  /// GET /multiplayer-sessions/qr-token/:qrToken
  Future<String> getSessionPinByQrToken(String qrToken);

  // ============ WebSocket Connection ============

  /// Conectar al namespace /multiplayer-sessions con headers.
  Future<void> connect({
    required String pin,
    required MultiplayerRole role,
    required String jwt,
  });

  /// Desconectar del WebSocket.
  void disconnect();

  /// Estado de conexión.
  bool get isConnected;

  // ============ Client Events (Emit) ============

  /// Emitir client_ready después de suscribirse a los listeners.
  void emitClientReady();

  /// Jugador se une con nickname.
  void emitPlayerJoin(String nickname);

  /// Host inicia el juego.
  void emitHostStartGame();

  /// Jugador envía respuesta.
  void emitPlayerSubmitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  });

  /// Host avanza a la siguiente fase.
  void emitHostNextPhase();

  /// Host cierra la sesión.
  void emitHostEndSession();

  // ============ Server Events (Streams) ============

  /// HOST: Actualizaciones del lobby.
  Stream<HostLobbyStateEntity> get hostLobbyUpdates;

  /// PLAYER: Conexión exitosa al lobby.
  Stream<PlayerLobbyStateEntity> get playerConnectedToSession;

  /// TODOS: Nueva pregunta iniciada.
  Stream<MultiplayerQuestionEntity> get questionStarted;

  /// PLAYER: Confirmación de respuesta.
  Stream<AnswerConfirmationEntity> get playerAnswerConfirmation;

  /// HOST: Actualización de número de respuestas.
  Stream<int> get hostAnswerUpdate;

  /// PLAYER: Resultados personales de la pregunta.
  Stream<PlayerResultsEntity> get playerResults;

  /// HOST: Resultados globales de la pregunta.
  Stream<HostResultsEntity> get hostResults;

  /// PLAYER: Fin del juego (resumen personal).
  Stream<PlayerGameEndEntity> get playerGameEnd;

  /// HOST: Fin del juego (podio).
  Stream<HostGameEndEntity> get hostGameEnd;

  /// TODOS: Sesión cerrada.
  Stream<SessionClosedEntity> get sessionClosed;

  /// HOST: Jugador se desconectó.
  Stream<PlayerLeftEntity> get playerLeftSession;

  /// PLAYER: Host se desconectó.
  Stream<String> get hostLeftSession;

  /// PLAYER: Host regresó.
  Stream<String> get hostReturnedToSession;

  /// Errores del juego.
  Stream<GameErrorEntity> get gameErrors;

  /// Errores de sincronización.
  Stream<GameErrorEntity> get syncErrors;

  /// Errores de conexión.
  Stream<GameErrorEntity> get connectionErrors;
}
