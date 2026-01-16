import 'group.dart';

/// Represents a member of a study group.
class GroupMember {
  final String id;
  final String name;
  final GroupRole role;
  final String? avatarUrl;

  GroupMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  /// Returns true if this member is the admin of the group.
  bool get isAdmin => role == GroupRole.admin;
}
