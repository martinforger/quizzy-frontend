import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/groups/usecases/create_group_use_case.dart';
import '../../../application/groups/usecases/delete_group_use_case.dart';
import '../../../application/groups/usecases/get_groups_use_case.dart';
import '../../../application/groups/usecases/join_group_use_case.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import 'groups_state.dart';

/// Cubit for managing the groups list.
class GroupsCubit extends Cubit<GroupsState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final AuthRepository authRepository;

  GroupsCubit({
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.deleteGroupUseCase,
    required this.joinGroupUseCase,
    required this.authRepository,
  }) : super(GroupsInitial());

  /// Load all groups for the current user.
  Future<void> loadGroups() async {
    emit(GroupsLoading());
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(const GroupsError('Not authenticated'));
        return;
      }
      final groups = await getGroupsUseCase(accessToken: token);
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  /// Create a new group.
  Future<void> createGroup(String name) async {
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(const GroupsError('Not authenticated'));
        return;
      }
      final group = await createGroupUseCase(name: name, accessToken: token);
      emit(GroupCreated(group));
      // Reload groups to reflect the new group
      await loadGroups();
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  /// Delete a group.
  Future<void> deleteGroup(String groupId) async {
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(const GroupsError('Not authenticated'));
        return;
      }
      await deleteGroupUseCase(groupId: groupId, accessToken: token);
      emit(GroupDeleted(groupId));
      // Reload groups to reflect the deletion
      await loadGroups();
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  /// Join a group using an invitation token.
  Future<void> joinGroup(String invitationToken) async {
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(const GroupsError('Not authenticated'));
        return;
      }
      final group = await joinGroupUseCase(
        invitationToken: invitationToken,
        accessToken: token,
      );
      emit(GroupJoined(group));
      // Reload groups to reflect the new group
      await loadGroups();
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }
}
