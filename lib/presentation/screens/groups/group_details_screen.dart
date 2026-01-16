import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/entities/group_quiz.dart';
import '../../bloc/groups/group_details_cubit.dart';
import '../../bloc/groups/group_details_state.dart';
import '../../theme/app_theme.dart';
import 'manage_group_screen.dart';

/// Screen showing details of a specific group with tabs.
class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInviteDialog() {
    context.read<GroupDetailsCubit>().createInvitation(widget.group.id);
  }

  void _navigateToManage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<GroupDetailsCubit>(),
          child: ManageGroupScreen(group: widget.group),
        ),
      ),
    );
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
        if (state.invitation != null) {
          _showInvitationBottomSheet(state.invitation!.invitationLink);
          context.read<GroupDetailsCubit>().clearInvitation();
        }
      },
      builder: (context, state) {
        final group = state.group ?? widget.group;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Detalles del Grupo'),
            actions: [
              if (group.isAdmin)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _navigateToManage,
                ),
            ],
          ),
          body: Column(
            children: [
              // Group Header
              _GroupHeader(group: group, onInvite: _showInviteDialog),
              // Tab Bar
              Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Pruebas'),
                    Tab(text: 'Clasificación'),
                    Tab(text: 'Miembros'),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _QuizzesTab(
                      quizzes: state.quizzes,
                      isLoading: state.isLoading,
                    ),
                    _LeaderboardTab(
                      entries: state.leaderboard,
                      isLoading: state.isLoading,
                    ),
                    _MembersTab(
                      members: state.members,
                      isLoading: state.isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvitationBottomSheet(String link) {
    // Extract token from URL (e.g., https://example.com/groups/join?token=ABC123 -> ABC123)
    String token = link;
    final uri = Uri.tryParse(link);
    if (uri != null && uri.queryParameters.containsKey('token')) {
      token = uri.queryParameters['token']!;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Enlace de Invitación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparte este código con tus amigos',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      token,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Código copiado al portapapeles'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Listo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final Group group;
  final VoidCallback onInvite;

  const _GroupHeader({required this.group, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Group Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getGroupColor(group.name),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getGroupColor(group.name).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            group.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${group.memberCount} Members',
                style: TextStyle(color: Colors.grey[500]),
              ),
              if (group.isAdmin) ...[
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(
                  'Created by You',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (group.isAdmin)
            ElevatedButton.icon(
              onPressed: onInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Invitar Amigos'),
            ),
        ],
      ),
    );
  }

  Color _getGroupColor(String name) {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF0984E3),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _QuizzesTab extends StatelessWidget {
  final List<GroupQuiz> quizzes;
  final bool isLoading;

  const _QuizzesTab({required this.quizzes, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Aún no hay pruebas asignadas',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    final pending = quizzes.where((q) => !q.isCompleted).toList();
    final completed = quizzes.where((q) => q.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Próximas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${pending.length} Nuevas',
                style: const TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((quiz) => _QuizCard(quiz: quiz, isPending: true)),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.history, color: Colors.grey[500], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Completadas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...completed.map((quiz) => _QuizCard(quiz: quiz, isPending: false)),
        ],
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  final GroupQuiz quiz;
  final bool isPending;

  const _QuizCard({required this.quiz, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPending) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PENDIENTE',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Vence ${_formatDate(quiz.availableUntil)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.quiz, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!isPending && quiz.userResult != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'COMPLETED',
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isPending && quiz.userResult != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${quiz.userResult!.score}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'PUNTOS',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to play quiz
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Jugar Ahora'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'Ver Respuestas',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    if (diff.inDays < 7) return 'en ${diff.inDays} días';
    return '${date.day}/${date.month}';
  }
}

class _LeaderboardTab extends StatelessWidget {
  final List entries;
  final bool isLoading;

  const _LeaderboardTab({required this.entries, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Aún no hay clasificación',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: index < 3 ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[700],
                child: Text(entry.name[0].toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${entry.completedQuizzes} Pruebas',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.totalPoints}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'PTS',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MembersTab extends StatelessWidget {
  final List members;
  final bool isLoading;

  const _MembersTab({required this.members, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Aún no hay miembros',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[700],
                child: Text(member.name[0].toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      member.isAdmin ? 'Administrador' : 'Miembro',
                      style: TextStyle(
                        color: member.isAdmin
                            ? AppColors.primary
                            : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
