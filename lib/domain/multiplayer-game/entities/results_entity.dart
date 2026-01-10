import 'player_entity.dart';

/// Información de progreso de la partida.
class ProgressInfo {
  final int current;
  final int total;
  final bool? isLastSlide;

  ProgressInfo({required this.current, required this.total, this.isLastSlide});
}

/// Estadísticas de respuestas para el host.
class AnswerStats {
  final int totalAnswers;
  final Map<String, int> distribution;

  AnswerStats({required this.totalAnswers, required this.distribution});
}

/// Resultados de una pregunta para el jugador.
class PlayerResultsEntity {
  final bool isCorrect;
  final int pointsEarned;
  final int totalScore;
  final int rank;
  final int previousRank;
  final int streak;
  final List<String> correctAnswerIds;
  final String message;
  final ProgressInfo progress;

  PlayerResultsEntity({
    required this.isCorrect,
    required this.pointsEarned,
    required this.totalScore,
    required this.rank,
    required this.previousRank,
    required this.streak,
    required this.correctAnswerIds,
    required this.message,
    required this.progress,
  });
}

/// Resultados de una pregunta para el host.
class HostResultsEntity {
  final String state;
  final List<String> correctAnswerId;
  final List<PlayerEntity> leaderboard;
  final AnswerStats stats;
  final ProgressInfo progress;

  HostResultsEntity({
    required this.state,
    required this.correctAnswerId,
    required this.leaderboard,
    required this.stats,
    required this.progress,
  });
}
