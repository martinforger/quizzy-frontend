import '../../../domain/groups/repositories/group_repository.dart';

/// Use case to transfer admin rights to another member.
class TransferAdminUseCase {
  final GroupRepository _repository;

  TransferAdminUseCase(this._repository);

  Future<void> call({
    required String groupId,
    required String newAdminId,
    required String accessToken,
  }) {
    return _repository.transferAdmin(
      groupId: groupId,
      newAdminId: newAdminId,
      accessToken: accessToken,
    );
  }
}
