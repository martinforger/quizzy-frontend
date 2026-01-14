import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/notifications/usecases/get_notifications_use_case.dart';
import 'package:quizzy/application/notifications/usecases/mark_notification_read_use_case.dart';
import 'package:quizzy/domain/auth/repositories/auth_repository.dart';
import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final AuthRepository authRepository;

  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.authRepository,
  }) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        emit(const NotificationsError('Not authenticated'));
        return;
      }
      final notifications = await getNotificationsUseCase(accessToken: token);
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update or reload? Let's reload for simplicity or update local list.
    // For now, simple fire and forget + reload.
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        // Handle error: not authenticated
        return;
      }
      await markNotificationReadUseCase(id, accessToken: token);
      // We could update the state locally to mark as read without network call
      if (state is NotificationsLoaded) {
        final currentList = (state as NotificationsLoaded).notifications;
        final updatedList = currentList.map((n) {
          if (n.id == id) {
            // Assuming NotificationItem has a copyWith or we create new one
            // If NotificationItem is immutable and doesn't have copyWith, we might need to check definition.
            // Let's assume it doesn't have copyWith for now and verify later.
            return n; // Placeholder, actually we want to change isRead status
          }
          return n;
        }).toList();
        // Trigger reload to be sure
        loadNotifications();
      }
    } catch (e) {
      // Handle error
    }
  }
}
