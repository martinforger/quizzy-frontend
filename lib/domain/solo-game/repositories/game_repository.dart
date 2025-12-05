import "../entities/attempt_entity.dart";
import "../entities/summary_entity.dart";

abstract class GameRepository {
  Future<AttemptEntity> startNewAttempt(String kahootId);
  Future<AttemptEntity> getAttemptState(String attemptId);

  Future<AttemptEntity> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndices,
    required int timeElapsed,
  });

  Future<SummaryEntity> getSummary(String attemptId);

  // Local Persistence
  Future<void> saveLocalGameSession({
    required String quizId,
    required String attemptId,
    required int currentQuestionIndex,
    required int totalQuestions,
  });

  Future<Map<String, dynamic>?> getLocalGameSession();

  Future<void> clearLocalGameSession();
}
