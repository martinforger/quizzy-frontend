/// Represents the role of a user within a study group.
enum GroupRole { admin, member }

/// Extension to parse GroupRole from string.
extension GroupRoleExtension on GroupRole {
  String get value {
    switch (this) {
      case GroupRole.admin:
        return 'admin';
      case GroupRole.member:
        return 'member';
    }
  }

  static GroupRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return GroupRole.admin;
      case 'member':
      default:
        return GroupRole.member;
    }
  }
}

/// Represents a study group.
class Group {
  final String id;
  final String name;
  final GroupRole role;
  final int memberCount;
  final DateTime createdAt;
  final String? description;
  final String? adminId;

  Group({
    required this.id,
    required this.name,
    required this.role,
    required this.memberCount,
    required this.createdAt,
    this.description,
    this.adminId,
  });

  /// Returns true if the current user is the admin of this group.
  bool get isAdmin => role == GroupRole.admin;

  Group copyWith({
    String? id,
    String? name,
    GroupRole? role,
    int? memberCount,
    DateTime? createdAt,
    String? description,
    String? adminId,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
    );
  }
}
