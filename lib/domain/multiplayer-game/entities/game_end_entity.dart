import 'player_entity.dart';

/// Fin del juego para el host.
class HostGameEndEntity {
  final String state;
  final List<PlayerEntity> finalPodium;
  final PlayerEntity winner;
  final int totalParticipants;

  HostGameEndEntity({
    required this.state,
    required this.finalPodium,
    required this.winner,
    required this.totalParticipants,
  });
}

/// Fin del juego para el jugador.
class PlayerGameEndEntity {
  final String state;
  final int rank;
  final int totalScore;
  final bool isPodium;
  final bool isWinner;
  final int finalStreak;

  PlayerGameEndEntity({
    required this.state,
    required this.rank,
    required this.totalScore,
    required this.isPodium,
    required this.isWinner,
    required this.finalStreak,
  });
}

/// Evento de sesión cerrada.
class SessionClosedEntity {
  final String reason;
  final String message;

  SessionClosedEntity({required this.reason, required this.message});
}

/// Evento de jugador desconectado (para el host).
class PlayerLeftEntity {
  final String oderId;
  final String nickname;
  final String message;

  PlayerLeftEntity({
    required this.oderId,
    required this.nickname,
    required this.message,
  });
}

/// Evento de error del juego.
class GameErrorEntity {
  final String code;
  final String message;

  GameErrorEntity({required this.code, required this.message});
}
