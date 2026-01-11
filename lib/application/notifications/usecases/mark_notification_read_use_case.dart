import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<NotificationItem> call(String id) {
    return _repository.markAsRead(id);
  }
}
