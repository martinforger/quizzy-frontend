import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to create a new group.
class CreateGroupUseCase {
  final GroupRepository _repository;

  CreateGroupUseCase(this._repository);

  Future<Group> call({required String name, required String accessToken}) {
    return _repository.createGroup(name: name, accessToken: accessToken);
  }
}
