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

  Future<Map<String, dynamic>?> getGameSession() {
    return _repository.getLocalGameSession();
  }

  // Helper legacy or convenience
  Future<String?> getAttemptId() async {
    final session = await _repository.getLocalGameSession();
    return session?['attemptId'];
  }

  Future<void> clearAttemptId() {
    return _repository.clearLocalGameSession();
  }
}
