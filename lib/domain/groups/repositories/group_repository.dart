import '../entities/group.dart';
import '../entities/group_invitation.dart';
import '../entities/group_member.dart';
import '../entities/group_quiz.dart';
import '../entities/leaderboard_entry.dart';

/// Repository interface for group operations.
abstract class GroupRepository {
  /// Get all groups for the current user.
  Future<List<Group>> getGroups({required String accessToken});

  /// Create a new group.
  Future<Group> createGroup({
    required String name,
    required String accessToken,
  });

  /// Update group information (name, description).
  Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    required String accessToken,
  });

  /// Delete a group (admin only).
  Future<void> deleteGroup({
    required String groupId,
    required String accessToken,
  });

  /// Remove a member from group (admin) or leave group (self).
  Future<void> removeMember({
    required String groupId,
    required String memberId,
    required String accessToken,
  });

  /// Transfer admin rights to another member.
  Future<void> transferAdmin({
    required String groupId,
    required String newAdminId,
    required String accessToken,
  });

  /// Generate an invitation link for the group.
  Future<GroupInvitation> createInvitation({
    required String groupId,
    String expiresIn = '7d',
    required String accessToken,
  });

  /// Join a group using an invitation token.
  Future<Group> joinGroup({
    required String invitationToken,
    required String accessToken,
  });

  /// Assign a quiz to the group.
  Future<void> assignQuiz({
    required String groupId,
    required String quizId,
    required DateTime availableFrom,
    required DateTime availableUntil,
    required String accessToken,
  });

  /// Get all quizzes assigned to a group with user status.
  Future<List<GroupQuiz>> getGroupQuizzes({
    required String groupId,
    required String accessToken,
  });

  /// Get the group leaderboard.
  Future<List<LeaderboardEntry>> getGroupLeaderboard({
    required String groupId,
    required String accessToken,
  });

  /// Get the leaderboard for a specific quiz in the group.
  Future<List<LeaderboardEntry>> getQuizLeaderboard({
    required String groupId,
    required String quizId,
    required String accessToken,
  });

  /// Get all members of a group.
  Future<List<GroupMember>> getGroupMembers({
    required String groupId,
    required String accessToken,
  });
}
