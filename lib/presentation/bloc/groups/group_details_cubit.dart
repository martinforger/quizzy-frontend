import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/groups/usecases/create_invitation_use_case.dart';
import '../../../application/groups/usecases/get_group_leaderboard_use_case.dart';
import '../../../application/groups/usecases/get_group_members_use_case.dart';
import '../../../application/groups/usecases/get_group_quizzes_use_case.dart';
import '../../../application/groups/usecases/remove_member_use_case.dart';
import '../../../application/groups/usecases/transfer_admin_use_case.dart';
import '../../../application/groups/usecases/update_group_use_case.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/groups/entities/group.dart';
import 'group_details_state.dart';

/// Cubit for managing individual group details.
class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  final GetGroupQuizzesUseCase getGroupQuizzesUseCase;
  final GetGroupLeaderboardUseCase getGroupLeaderboardUseCase;
  final GetGroupMembersUseCase getGroupMembersUseCase;
  final UpdateGroupUseCase updateGroupUseCase;
  final RemoveMemberUseCase removeMemberUseCase;
  final TransferAdminUseCase transferAdminUseCase;
  final CreateInvitationUseCase createInvitationUseCase;
  final AuthRepository authRepository;

  GroupDetailsCubit({
    required this.getGroupQuizzesUseCase,
    required this.getGroupLeaderboardUseCase,
    required this.getGroupMembersUseCase,
    required this.updateGroupUseCase,
    required this.removeMemberUseCase,
    required this.transferAdminUseCase,
    required this.createInvitationUseCase,
    required this.authRepository,
  }) : super(const GroupDetailsState());

  /// Initialize with a group.
  void setGroup(Group group) {
    emit(state.copyWith(group: group, clearError: true));
  }

  /// Load all data for the group.
  Future<void> loadAll(String groupId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }

      // Load all data in parallel
      final results = await Future.wait([
        getGroupQuizzesUseCase(groupId: groupId, accessToken: token),
        getGroupLeaderboardUseCase(groupId: groupId, accessToken: token),
        getGroupMembersUseCase(groupId: groupId, accessToken: token),
      ]);

      emit(
        state.copyWith(
          quizzes: results[0] as dynamic,
          leaderboard: results[1] as dynamic,
          members: results[2] as dynamic,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load quizzes for the group.
  Future<void> loadQuizzes(String groupId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      final quizzes = await getGroupQuizzesUseCase(
        groupId: groupId,
        accessToken: token,
      );
      emit(state.copyWith(quizzes: quizzes, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load leaderboard for the group.
  Future<void> loadLeaderboard(String groupId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      final leaderboard = await getGroupLeaderboardUseCase(
        groupId: groupId,
        accessToken: token,
      );
      emit(state.copyWith(leaderboard: leaderboard, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Load members for the group.
  Future<void> loadMembers(String groupId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      final members = await getGroupMembersUseCase(
        groupId: groupId,
        accessToken: token,
      );
      emit(state.copyWith(members: members, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Update group information.
  Future<void> updateGroup(
    String groupId, {
    String? name,
    String? description,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      final updated = await updateGroupUseCase(
        groupId: groupId,
        name: name,
        description: description,
        accessToken: token,
      );
      emit(state.copyWith(group: updated, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Remove a member from the group.
  Future<void> removeMember(String groupId, String memberId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      await removeMemberUseCase(
        groupId: groupId,
        memberId: memberId,
        accessToken: token,
      );
      // Reload members
      await loadMembers(groupId);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Transfer admin rights to another member.
  Future<void> transferAdmin(String groupId, String newAdminId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      await transferAdminUseCase(
        groupId: groupId,
        newAdminId: newAdminId,
        accessToken: token,
      );
      // Reload members to reflect role changes
      await loadMembers(groupId);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Create an invitation link.
  Future<void> createInvitation(
    String groupId, {
    String expiresIn = '7d',
  }) async {
    emit(
      state.copyWith(isLoading: true, clearError: true, clearInvitation: true),
    );
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(state.copyWith(isLoading: false, error: 'Not authenticated'));
        return;
      }
      final invitation = await createInvitationUseCase(
        groupId: groupId,
        expiresIn: expiresIn,
        accessToken: token,
      );
      emit(state.copyWith(invitation: invitation, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Clear the invitation.
  void clearInvitation() {
    emit(state.copyWith(clearInvitation: true));
  }
}
