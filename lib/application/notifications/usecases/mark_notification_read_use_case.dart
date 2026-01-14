import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<NotificationItem> call(String id, {required String accessToken}) {
    return _repository.markAsRead(id, accessToken: accessToken);
  }
}
