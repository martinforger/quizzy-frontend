import '../../../domain/groups/entities/group_member.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to get all members of a group.
class GetGroupMembersUseCase {
  final GroupRepository _repository;

  GetGroupMembersUseCase(this._repository);

  Future<List<GroupMember>> call({
    required String groupId,
    required String accessToken,
  }) {
    return _repository.getGroupMembers(
      groupId: groupId,
      accessToken: accessToken,
    );
  }
}
