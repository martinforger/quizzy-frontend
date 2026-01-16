import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to assign a quiz to a group.
class AssignQuizUseCase {
  final GroupRepository _repository;

  AssignQuizUseCase(this._repository);

  Future<void> call({
    required String groupId,
    required String quizId,
    required DateTime availableFrom,
    required DateTime availableUntil,
    required String accessToken,
  }) {
    return _repository.assignQuiz(
      groupId: groupId,
      quizId: quizId,
      availableFrom: availableFrom,
      availableUntil: availableUntil,
      accessToken: accessToken,
    );
  }
}
