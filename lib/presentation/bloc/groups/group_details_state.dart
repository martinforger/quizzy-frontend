import 'package:equatable/equatable.dart';
import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/entities/group_invitation.dart';
import '../../../domain/groups/entities/group_member.dart';
import '../../../domain/groups/entities/group_quiz.dart';
import '../../../domain/groups/entities/leaderboard_entry.dart';

/// State for group details screen.
class GroupDetailsState extends Equatable {
  final Group? group;
  final List<GroupQuiz> quizzes;
  final List<LeaderboardEntry> leaderboard;
  final List<GroupMember> members;
  final bool isLoading;
  final String? error;
  final GroupInvitation? invitation;

  const GroupDetailsState({
    this.group,
    this.quizzes = const [],
    this.leaderboard = const [],
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.invitation,
  });

  GroupDetailsState copyWith({
    Group? group,
    List<GroupQuiz>? quizzes,
    List<LeaderboardEntry>? leaderboard,
    List<GroupMember>? members,
    bool? isLoading,
    String? error,
    GroupInvitation? invitation,
    bool clearError = false,
    bool clearInvitation = false,
  }) {
    return GroupDetailsState(
      group: group ?? this.group,
      quizzes: quizzes ?? this.quizzes,
      leaderboard: leaderboard ?? this.leaderboard,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      invitation: clearInvitation ? null : (invitation ?? this.invitation),
    );
  }

  @override
  List<Object?> get props => [
    group,
    quizzes,
    leaderboard,
    members,
    isLoading,
    error,
    invitation,
  ];
}
