import '../../../domain/groups/entities/group_invitation.dart';
import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to create an invitation link.
class CreateInvitationUseCase {
  final GroupRepository _repository;

  CreateInvitationUseCase(this._repository);

  Future<GroupInvitation> call({
    required String groupId,
    String expiresIn = '7d',
    required String accessToken,
  }) {
    return _repository.createInvitation(
      groupId: groupId,
      expiresIn: expiresIn,
      accessToken: accessToken,
    );
  }
}
