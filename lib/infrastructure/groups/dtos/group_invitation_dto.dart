import '../../../domain/groups/entities/group_invitation.dart';

/// DTO for GroupInvitation API responses.
class GroupInvitationDto {
  final String groupId;
  final String invitationLink;
  final DateTime expiresAt;

  GroupInvitationDto({
    required this.groupId,
    required this.invitationLink,
    required this.expiresAt,
  });

  factory GroupInvitationDto.fromJson(Map<String, dynamic> json) {
    return GroupInvitationDto(
      groupId: json['groupId'] as String,
      invitationLink: json['invitationLink'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  GroupInvitation toDomain() {
    return GroupInvitation(
      groupId: groupId,
      invitationLink: invitationLink,
      expiresAt: expiresAt,
    );
  }
}
