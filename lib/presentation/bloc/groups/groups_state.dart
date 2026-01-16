import 'package:equatable/equatable.dart';
import '../../../domain/groups/entities/group.dart';

/// Base state for the groups list.
abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class GroupsInitial extends GroupsState {}

/// Loading state while fetching groups.
class GroupsLoading extends GroupsState {}

/// State when groups have been loaded successfully.
class GroupsLoaded extends GroupsState {
  final List<Group> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

/// Error state when loading fails.
class GroupsError extends GroupsState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State after successfully creating a group.
class GroupCreated extends GroupsState {
  final Group group;

  const GroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

/// State after successfully joining a group.
class GroupJoined extends GroupsState {
  final Group group;

  const GroupJoined(this.group);

  @override
  List<Object?> get props => [group];
}

/// State after successfully deleting a group.
class GroupDeleted extends GroupsState {
  final String groupId;

  const GroupDeleted(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
