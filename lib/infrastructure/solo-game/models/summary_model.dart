import '../../../domain/solo-game/entities/summary_entity.dart';

class SummaryModel extends SummaryEntity {
  SummaryModel({
    required String attemptId,
    required int finalScore,
    required int totalCorrect,
    required int totalQuestions,
    required int accuracyPercentage,
  }) : super(
         attemptId: attemptId,
         finalScore: finalScore,
         totalCorrect: totalCorrect,
         totalQuestions: totalQuestions,
         accuracyPercentage: accuracyPercentage,
       );

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      attemptId: json['attemptId'] ?? '',
      finalScore: (json['finalScore'] ?? 0) as int,
      totalCorrect: (json['totalCorrect'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      accuracyPercentage: (json['accuracyPercentage'] ?? 0) as int,
    );
  }
}
