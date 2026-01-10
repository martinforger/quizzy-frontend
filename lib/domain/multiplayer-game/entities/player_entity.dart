/// Representa un jugador en una sesión multijugador.
class PlayerEntity {
  final String playerId;
  final String nickname;
  final int score;
  final int rank;
  final int previousRank;

  PlayerEntity({
    required this.playerId,
    required this.nickname,
    this.score = 0,
    this.rank = 0,
    this.previousRank = 0,
  });
}

/// Info reducida del jugador para el lobby.
class PlayerLobbyInfo {
  final String playerId;
  final String nickname;

  PlayerLobbyInfo({required this.playerId, required this.nickname});
}
