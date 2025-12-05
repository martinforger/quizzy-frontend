import 'package:quizzy/domain/solo-game/repositories/game_repository.dart';

class ManageLocalAttemptUseCase {
  final GameRepository _repository;

  ManageLocalAttemptUseCase(this._repository);

  Future<void> saveGameSession({
    required String quizId,
    required String attemptId,
    required int currentQuestionIndex,
    required int totalQuestions,
  }) {
    return _repository.saveLocalGameSession(
      quizId: quizId,
      attemptId: attemptId,
      currentQuestionIndex: currentQuestionIndex,
      totalQuestions: totalQuestions,
    );
  }

  Future<Map<String, dynamic>?> getGameSession(String quizId) {
    return _repository.getLocalGameSession(quizId);
  }

  Future<Map<String, Map<String, dynamic>>> getAllGameSessions() {
    return _repository.getAllLocalGameSessions();
  }

  // Helper legacy or convenience
  Future<String?> getAttemptId(String quizId) async {
    final session = await _repository.getLocalGameSession(quizId);
    return session?['attemptId'];
  }

  Future<void> clearAttemptId(String quizId) {
    return _repository.clearLocalGameSession(quizId);
  }
}
