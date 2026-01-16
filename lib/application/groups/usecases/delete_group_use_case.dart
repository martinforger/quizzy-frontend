import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to delete a group.
class DeleteGroupUseCase {
  final GroupRepository _repository;

  DeleteGroupUseCase(this._repository);

  Future<void> call({required String groupId, required String accessToken}) {
    return _repository.deleteGroup(groupId: groupId, accessToken: accessToken);
  }
}
