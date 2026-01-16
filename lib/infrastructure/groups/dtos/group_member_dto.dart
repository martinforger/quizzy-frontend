import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/entities/group_member.dart';

/// DTO for GroupMember API responses.
class GroupMemberDto {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  GroupMemberDto({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  factory GroupMemberDto.fromJson(Map<String, dynamic> json) {
    // Try different field names for user name
    final name =
        json['name'] as String? ??
        json['username'] as String? ??
        json['displayName'] as String? ??
        json['email'] as String? ??
        'Unknown';

    return GroupMemberDto(
      id: json['userId'] as String? ?? json['id'] as String? ?? '',
      name: name,
      role: json['role'] as String? ?? 'member',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  GroupMember toDomain() {
    return GroupMember(
      id: id,
      name: name,
      role: GroupRoleExtension.fromString(role),
      avatarUrl: avatarUrl,
    );
  }
}
