import '../../../domain/groups/entities/group_quiz.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to get quizzes assigned to a group.
class GetGroupQuizzesUseCase {
  final GroupRepository _repository;

  GetGroupQuizzesUseCase(this._repository);

  Future<List<GroupQuiz>> call({
    required String groupId,
    required String accessToken,
  }) {
    return _repository.getGroupQuizzes(
      groupId: groupId,
      accessToken: accessToken,
    );
  }
}
