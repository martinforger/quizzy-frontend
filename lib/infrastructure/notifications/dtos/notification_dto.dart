import 'package:quizzy/domain/notifications/entities/notification_item.dart';

class NotificationDto {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? resourceId;

  NotificationDto({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.resourceId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resourceId: json['resourceId'] as String?,
    );
  }

  NotificationItem toDomain() {
    return NotificationItem(
      id: id,
      type: type,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      resourceId: resourceId,
    );
  }
}
