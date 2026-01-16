import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to join a group via invitation token.
class JoinGroupUseCase {
  final GroupRepository _repository;

  JoinGroupUseCase(this._repository);

  Future<Group> call({
    required String invitationToken,
    required String accessToken,
  }) {
    return _repository.joinGroup(
      invitationToken: invitationToken,
      accessToken: accessToken,
    );
  }
}
