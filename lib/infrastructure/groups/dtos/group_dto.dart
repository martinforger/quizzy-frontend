import '../../../domain/groups/entities/group.dart';

/// DTO for Group API responses.
class GroupDto {
  final String id;
  final String name;
  final String role;
  final int memberCount;
  final DateTime createdAt;
  final String? description;
  final String? adminId;

  GroupDto({
    required this.id,
    required this.name,
    required this.role,
    required this.memberCount,
    required this.createdAt,
    this.description,
    this.adminId,
  });

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    return GroupDto(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'member',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      adminId: json['adminId'] as String?,
    );
  }

  Group toDomain() {
    return Group(
      id: id,
      name: name,
      role: GroupRoleExtension.fromString(role),
      memberCount: memberCount,
      createdAt: createdAt,
      description: description,
      adminId: adminId,
    );
  }
}
