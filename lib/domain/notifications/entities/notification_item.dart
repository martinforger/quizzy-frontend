class NotificationItem {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? resourceId;

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.resourceId,
  });
}
