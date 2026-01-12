import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:quizzy/presentation/bloc/notifications/notifications_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is NotificationsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text('No tienes notificaciones nuevas', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationCard(notification: notification);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationCard({required this.notification});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead
            ? BorderSide.none
            : BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () {
          context.read<NotificationsCubit>().markAsRead(notification.id);
          // TODO: Funcionalidad de navegación basada en notification.type y resourceId (H9.1)
          if (notification.type == 'quiz_assigned' || notification.type == 'quiz_completed') {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Navegando al detalle del Quizz...')),
             );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeTitle(notification.type),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'quiz_assigned':
        return Colors.blue;
      case 'quiz_completed':
        return Colors.green;
      case 'alert':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'quiz_assigned':
        return Icons.assignment_outlined;
      case 'quiz_completed':
        return Icons.check_circle_outlined;
      case 'alert':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
  
  String _getTypeTitle(String type) {
     switch (type) {
      case 'quiz_assigned':
        return 'Nuevo Quizz Asignado';
      case 'quiz_completed':
        return 'Quizz Completado';
      case 'alert':
        return 'Novedad';
      default:
        return 'Notificación';
    }
  }
}
