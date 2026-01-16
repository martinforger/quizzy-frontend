import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to get all groups for the current user.
class GetGroupsUseCase {
  final GroupRepository _repository;

  GetGroupsUseCase(this._repository);

  Future<List<Group>> call({required String accessToken}) {
    return _repository.getGroups(accessToken: accessToken);
  }
}
