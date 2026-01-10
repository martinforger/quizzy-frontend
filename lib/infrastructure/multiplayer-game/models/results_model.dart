import '../../../domain/multiplayer-game/entities/results_entity.dart';
import '../../../domain/multiplayer-game/entities/player_entity.dart';

/// Modelo para parsear player_results.
class PlayerResultsModel extends PlayerResultsEntity {
  PlayerResultsModel({
    required super.isCorrect,
    required super.pointsEarned,
    required super.totalScore,
    required super.rank,
    required super.previousRank,
    required super.streak,
    required super.correctAnswerIds,
    required super.message,
    required super.progress,
  });

  factory PlayerResultsModel.fromJson(Map<String, dynamic> json) {
    final correctIds =
        (json['correctAnswerIds'] as List<dynamic>?)
            ?.map((id) => id.toString())
            .toList() ??
        [];

    final progressData = json['progress'] as Map<String, dynamic>? ?? {};

    return PlayerResultsModel(
      isCorrect: json['isCorrect'] as bool? ?? false,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      previousRank: json['previousRank'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      correctAnswerIds: correctIds,
      message: json['message'] as String? ?? '',
      progress: ProgressInfoModel.fromJson(progressData),
    );
  }
}

/// Modelo para parsear host_results.
class HostResultsModel extends HostResultsEntity {
  HostResultsModel({
    required super.state,
    required super.correctAnswerId,
    required super.leaderboard,
    required super.stats,
    required super.progress,
  });

  factory HostResultsModel.fromJson(Map<String, dynamic> json) {
    final correctIds =
        (json['correctAnswerId'] as List<dynamic>?)
            ?.map((id) => id.toString())
            .toList() ??
        [];

    final leaderboardList =
        (json['leaderboard'] as List<dynamic>?)
            ?.map((p) => PlayerEntityModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    final statsData = json['stats'] as Map<String, dynamic>? ?? {};
    final progressData = json['progress'] as Map<String, dynamic>? ?? {};

    return HostResultsModel(
      state: json['state'] as String? ?? 'results',
      correctAnswerId: correctIds,
      leaderboard: leaderboardList,
      stats: AnswerStatsModel.fromJson(statsData),
      progress: ProgressInfoModel.fromJson(progressData),
    );
  }
}

/// Modelo para PlayerEntity desde JSON.
class PlayerEntityModel extends PlayerEntity {
  PlayerEntityModel({
    required super.playerId,
    required super.nickname,
    required super.score,
    required super.rank,
    required super.previousRank,
  });

  factory PlayerEntityModel.fromJson(Map<String, dynamic> json) {
    return PlayerEntityModel(
      playerId: json['playerId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      previousRank: json['previousRank'] as int? ?? 0,
    );
  }
}

/// Modelo para ProgressInfo.
class ProgressInfoModel extends ProgressInfo {
  ProgressInfoModel({
    required super.current,
    required super.total,
    super.isLastSlide,
  });

  factory ProgressInfoModel.fromJson(Map<String, dynamic> json) {
    return ProgressInfoModel(
      current: json['current'] as int? ?? 1,
      total: json['total'] as int? ?? 1,
      isLastSlide: json['isLastSlide'] as bool?,
    );
  }
}

/// Modelo para AnswerStats.
class AnswerStatsModel extends AnswerStats {
  AnswerStatsModel({required super.totalAnswers, required super.distribution});

  factory AnswerStatsModel.fromJson(Map<String, dynamic> json) {
    final distMap = <String, int>{};
    final distribution = json['distribution'] as Map<String, dynamic>? ?? {};
    distribution.forEach((key, value) {
      distMap[key] = value as int? ?? 0;
    });

    return AnswerStatsModel(
      totalAnswers: json['totalAnswers'] as int? ?? 0,
      distribution: distMap,
    );
  }
}
