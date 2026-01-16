/// Represents an invitation link to join a group.
class GroupInvitation {
  final String groupId;
  final String invitationLink;
  final DateTime expiresAt;

  GroupInvitation({
    required this.groupId,
    required this.invitationLink,
    required this.expiresAt,
  });

  /// Returns true if the invitation has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Extracts the token from the invitation link.
  String get token => invitationLink;
}
