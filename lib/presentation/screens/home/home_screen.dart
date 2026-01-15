import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/injection_container.dart';
import 'package:quizzy/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:quizzy/presentation/bloc/notifications/notifications_state.dart';
import 'package:quizzy/presentation/screens/notifications/notifications_screen.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:quizzy/presentation/screens/profile/profile_screen.dart';
import 'package:quizzy/presentation/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.profileController,
    required this.authController,
    required this.onLogout,
  });

  final ProfileController profileController;
  final AuthController authController;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = widget.profileController.getProfile();
    });
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          profileController: widget.profileController,
          authController: widget.authController,
          onLogout: widget.onLogout,
        ),
      ),
    );
    _loadProfile();
  }

  Future<void> _handleLogout() async {
    try {
      await widget.authController.logout();
    } catch (e) {
      debugPrint("Logout warning: $e");
    } finally {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surface,
            title: FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final String name;
                final String? avatarUrl;

                if (snapshot.hasData) {
                  name = snapshot.data!.name;
                  avatarUrl = snapshot.data!.avatarUrl;
                } else {
                  name = '...';
                  avatarUrl = null;
                }

                return GestureDetector(
                  onTap: _openProfile,
                  child: Row(
                    children: [
                      UserAvatar(avatarUrl: avatarUrl, radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hola, $name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              // Icono estilo Kahoot (Formas geométricas) con badge de notificación
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  bool hasUnread = false;
                  if (state is NotificationsLoaded) {
                    hasUnread = state.notifications.any((n) => !n.isRead);
                  }

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.category_rounded, color: AppColors.primary),
                        tooltip: 'Novedades',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(), // Cubit is now global
                            ),
                          );
                        },
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: _handleLogout,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Crear Quiz',
                          subtitle: 'Crea tu propio juego',
                          color: AppColors.primary,
                          icon: Icons.add_circle_outline,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          title: 'Hostear',
                          subtitle: 'Inicia un juego en vivo',
                          color: const Color(0xFFE21B3C),
                          icon: Icons.play_circle_outline,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Featured Banner
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF46178F),
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1534081333815-ae5019106622?auto=format&fit=crop&q=80&w=1000',
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.4,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DESTACADO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Desafío de la Semana',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pon a prueba tus conocimientos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Actividad Reciente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RecentActivityItem(
                    title: 'Historia del Arte',
                    subtitle: 'Jugado hace 2h • 80% Correcto',
                    icon: Icons.history_edu,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _RecentActivityItem(
                    title: 'Ciencia Básica',
                    subtitle: 'Jugado ayer • 95% Correcto',
                    icon: Icons.science,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  const _RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
