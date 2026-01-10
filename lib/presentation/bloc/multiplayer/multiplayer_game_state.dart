import '../../../domain/multiplayer-game/entities/session_entity.dart';
import '../../../domain/multiplayer-game/entities/lobby_state_entity.dart';
import '../../../domain/multiplayer-game/entities/multiplayer_slide_entity.dart';
import '../../../domain/multiplayer-game/entities/results_entity.dart';
import '../../../domain/multiplayer-game/entities/game_end_entity.dart';
import '../../../domain/multiplayer-game/entities/player_entity.dart';
import '../../../domain/multiplayer-game/repositories/multiplayer_game_repository.dart';

/// Estados base para el juego multijugador.
abstract class MultiplayerGameState {}

/// Estado inicial - Sin conexión.
class MultiplayerInitial extends MultiplayerGameState {}

/// Estado de conexión en progreso.
class MultiplayerConnecting extends MultiplayerGameState {}

// ============ Estados del HOST ============

/// Host: Sesión creada, mostrando lobby.
class HostLobbyState extends MultiplayerGameState {
  final SessionEntity session;
  final List<PlayerLobbyInfo> players;
  final int numberOfPlayers;

  HostLobbyState({
    required this.session,
    required this.players,
    required this.numberOfPlayers,
  });

  HostLobbyState copyWith({
    List<PlayerLobbyInfo>? players,
    int? numberOfPlayers,
  }) {
    return HostLobbyState(
      session: session,
      players: players ?? this.players,
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
    );
  }
}

/// Host: Mostrando pregunta activa.
class HostQuestionState extends MultiplayerGameState {
  final MultiplayerQuestionEntity question;
  final int submissionCount;

  HostQuestionState({required this.question, this.submissionCount = 0});

  HostQuestionState copyWith({int? submissionCount}) {
    return HostQuestionState(
      question: question,
      submissionCount: submissionCount ?? this.submissionCount,
    );
  }
}

/// Host: Mostrando resultados de la pregunta.
class HostResultsState extends MultiplayerGameState {
  final HostResultsEntity results;

  HostResultsState(this.results);
}

/// Host: Fin del juego - Podio.
class HostGameEndState extends MultiplayerGameState {
  final HostGameEndEntity gameEnd;

  HostGameEndState(this.gameEnd);
}

// ============ Estados del PLAYER ============

/// Player: En el lobby esperando.
class PlayerLobbyState extends MultiplayerGameState {
  final String nickname;
  final bool connectedBefore;
  final bool nicknameSubmitted;

  PlayerLobbyState({
    required this.nickname,
    required this.connectedBefore,
    this.nicknameSubmitted = false,
  });

  PlayerLobbyState copyWith({String? nickname, bool? nicknameSubmitted}) {
    return PlayerLobbyState(
      nickname: nickname ?? this.nickname,
      connectedBefore: connectedBefore,
      nicknameSubmitted: nicknameSubmitted ?? this.nicknameSubmitted,
    );
  }
}

/// Player: Mostrando pregunta para responder.
class PlayerQuestionState extends MultiplayerGameState {
  final MultiplayerQuestionEntity question;
  final bool hasAnswered;

  PlayerQuestionState({required this.question, this.hasAnswered = false});

  PlayerQuestionState copyWith({bool? hasAnswered}) {
    return PlayerQuestionState(
      question: question,
      hasAnswered: hasAnswered ?? this.hasAnswered,
    );
  }
}

/// Player: Mostrando resultados personales.
class PlayerResultsState extends MultiplayerGameState {
  final PlayerResultsEntity results;

  PlayerResultsState(this.results);
}

/// Player: Fin del juego - Resumen personal.
class PlayerGameEndState extends MultiplayerGameState {
  final PlayerGameEndEntity gameEnd;

  PlayerGameEndState(this.gameEnd);
}

// ============ Estados Compartidos ============

/// Sesión cerrada.
class MultiplayerSessionClosed extends MultiplayerGameState {
  final String reason;
  final String message;

  MultiplayerSessionClosed({required this.reason, required this.message});
}

/// Error en el juego.
class MultiplayerError extends MultiplayerGameState {
  final String message;
  final String? code;

  MultiplayerError(this.message, {this.code});
}

/// Host se desconectó (para players).
class HostDisconnected extends MultiplayerGameState {
  final String message;

  HostDisconnected(this.message);
}
