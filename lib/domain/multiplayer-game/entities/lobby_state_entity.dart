import 'player_entity.dart';

/// Estado del lobby para el host.
class HostLobbyStateEntity {
  final String state;
  final List<PlayerLobbyInfo> players;
  final int numberOfPlayers;

  HostLobbyStateEntity({
    required this.state,
    required this.players,
    required this.numberOfPlayers,
  });
}

/// Estado del lobby para el jugador.
class PlayerLobbyStateEntity {
  final String state;
  final String nickname;
  final int score;
  final bool connectedBefore;

  PlayerLobbyStateEntity({
    required this.state,
    required this.nickname,
    required this.score,
    required this.connectedBefore,
  });
}
