import '../../../domain/multiplayer-game/entities/game_end_entity.dart';
import 'results_model.dart';

/// Modelo para parsear host_game_end.
class HostGameEndModel extends HostGameEndEntity {
  HostGameEndModel({
    required super.state,
    required super.finalPodium,
    required super.winner,
    required super.totalParticipants,
  });

  factory HostGameEndModel.fromJson(Map<String, dynamic> json) {
    final podiumList =
        (json['finalPodium'] as List<dynamic>?)
            ?.map((p) => PlayerEntityModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final winnerData = json['winner'] as Map<String, dynamic>? ?? {};

    return HostGameEndModel(
      state: json['state'] as String? ?? 'end',
      finalPodium: podiumList,
      winner: PlayerEntityModel.fromJson(winnerData),
      totalParticipants: json['totalParticipants'] as int? ?? 0,
    );
  }
}

/// Modelo para parsear player_game_end.
class PlayerGameEndModel extends PlayerGameEndEntity {
  PlayerGameEndModel({
    required super.state,
    required super.rank,
    required super.totalScore,
    required super.isPodium,
    required super.isWinner,
    required super.finalStreak,
  });

  factory PlayerGameEndModel.fromJson(Map<String, dynamic> json) {
    return PlayerGameEndModel(
      state: json['state'] as String? ?? 'end',
      rank: json['rank'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      isPodium: json['isPodium'] as bool? ?? false,
      isWinner: json['isWinner'] as bool? ?? false,
      finalStreak: json['finalStreak'] as int? ?? 0,
    );
  }
}

/// Modelo para parsear session_closed.
class SessionClosedModel extends SessionClosedEntity {
  SessionClosedModel({required super.reason, required super.message});

  factory SessionClosedModel.fromJson(Map<String, dynamic> json) {
    return SessionClosedModel(
      reason: json['reason'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'La sesión ha sido cerrada',
    );
  }
}

/// Modelo para parsear player_left_session.
class PlayerLeftModel extends PlayerLeftEntity {
  PlayerLeftModel({
    required super.oderId,
    required super.nickname,
    required super.message,
  });

  factory PlayerLeftModel.fromJson(Map<String, dynamic> json) {
    return PlayerLeftModel(
      oderId: json['userId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      message: json['message'] as String? ?? 'Un jugador se ha desconectado',
    );
  }
}

/// Modelo para parsear errores del juego.
class GameErrorModel extends GameErrorEntity {
  GameErrorModel({required super.code, required super.message});

  factory GameErrorModel.fromJson(Map<String, dynamic> json) {
    return GameErrorModel(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'Error desconocido',
    );
  }
}
