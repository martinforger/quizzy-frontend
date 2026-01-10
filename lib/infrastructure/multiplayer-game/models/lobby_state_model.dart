import '../../../domain/multiplayer-game/entities/lobby_state_entity.dart';
import '../../../domain/multiplayer-game/entities/player_entity.dart';

/// Modelo para parsear host_lobby_update.
class HostLobbyStateModel extends HostLobbyStateEntity {
  HostLobbyStateModel({
    required super.state,
    required super.players,
    required super.numberOfPlayers,
  });

  factory HostLobbyStateModel.fromJson(Map<String, dynamic> json) {
    final playersList =
        (json['players'] as List<dynamic>?)
            ?.map(
              (p) => PlayerLobbyInfoModel.fromJson(p as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return HostLobbyStateModel(
      state: json['state'] as String? ?? 'lobby',
      players: playersList,
      numberOfPlayers: json['numberOfPlayers'] as int? ?? playersList.length,
    );
  }
}

/// Modelo para info de jugador en lobby.
class PlayerLobbyInfoModel extends PlayerLobbyInfo {
  PlayerLobbyInfoModel({required super.playerId, required super.nickname});

  factory PlayerLobbyInfoModel.fromJson(Map<String, dynamic> json) {
    return PlayerLobbyInfoModel(
      playerId: json['playerId'] as String,
      nickname: json['nickname'] as String,
    );
  }
}

/// Modelo para parsear player_connected_to_session.
class PlayerLobbyStateModel extends PlayerLobbyStateEntity {
  PlayerLobbyStateModel({
    required super.state,
    required super.nickname,
    required super.score,
    required super.connectedBefore,
  });

  factory PlayerLobbyStateModel.fromJson(Map<String, dynamic> json) {
    return PlayerLobbyStateModel(
      state: json['state'] as String? ?? 'lobby',
      nickname: json['nickname'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      connectedBefore: json['connectedBefore'] as bool? ?? false,
    );
  }
}
