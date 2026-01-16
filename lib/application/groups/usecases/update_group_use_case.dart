import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to update group information.
class UpdateGroupUseCase {
  final GroupRepository _repository;

  UpdateGroupUseCase(this._repository);

  Future<Group> call({
    required String groupId,
    String? name,
    String? description,
    required String accessToken,
  }) {
    return _repository.updateGroup(
      groupId: groupId,
      name: name,
      description: description,
      accessToken: accessToken,
    );
  }
}
