import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to remove a member from group (admin) or leave group (self).
class RemoveMemberUseCase {
  final GroupRepository _repository;

  RemoveMemberUseCase(this._repository);

  Future<void> call({
    required String groupId,
    required String memberId,
    required String accessToken,
  }) {
    return _repository.removeMember(
      groupId: groupId,
      memberId: memberId,
      accessToken: accessToken,
    );
  }
}
