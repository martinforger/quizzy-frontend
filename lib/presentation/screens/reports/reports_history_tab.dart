import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/presentation/screens/reports/personal_result_screen.dart';
import 'package:quizzy/presentation/screens/reports/session_report_screen.dart';
import 'package:quizzy/presentation/state/reports_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class ReportsHistoryTab extends StatefulWidget {
  const ReportsHistoryTab({super.key, required this.controller});

  final ReportsController controller;

  @override
  State<ReportsHistoryTab> createState() => _ReportsHistoryTabState();
}

class _ReportsHistoryTabState extends State<ReportsHistoryTab>
    with SingleTickerProviderStateMixin {
  late Future<ReportsPage<KahootResultSummary>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.getMyResults();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.controller.getMyResults();
    });
    try {
      await _future;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos cargar los resultados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<ReportsPage<KahootResultSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = _mapError(snapshot.error);
            return _ErrorState(message: message, onRetry: _reload);
          }

          final page = snapshot.data;
          final results = page?.results ?? [];

          if (results.isEmpty) {
            return _EmptyState(onRetry: _reload).animate().fadeIn();
          }

          final personalResults = results
              .where((r) => !_isHostResult(r.gameType))
              .toList();
          final hostResults = results
              .where((r) => _isHostResult(r.gameType))
              .toList();

          return Column(
            children: [
              _ResultsHeader(
                total: results.length,
                personal: personalResults.length,
                sessions: hostResults.length,
              ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.1, end: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.card,
                        AppColors.card.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.soft,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accentTeal],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Personales'),
                      Tab(text: 'Sesiones'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ResultsList(
                      results: personalResults,
                      controller: widget.controller,
                      onRetry: _reload,
                    ),
                    _ResultsList(
                      results: hostResults,
                      controller: widget.controller,
                      onRetry: _reload,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.total,
    required this.personal,
    required this.sessions,
  });

  final int total;
  final int personal;
  final int sessions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A151D),
              AppColors.card.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.medium,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total: $total · Personales: $personal · Sesiones: $sessions',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Historial',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.controller,
    required this.onRetry,
  });

  final List<KahootResultSummary> results;
  final ReportsController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return _EmptyState(onRetry: onRetry).animate().fadeIn(duration: 300.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _ResultCard(
              result: result,
              onTap: () {
                final isHost = _isHostResult(result.gameType);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isHost
                        ? SessionReportScreen(
                            controller: controller,
                            sessionId: result.gameId,
                            title: result.title,
                          )
                        : PersonalResultScreen(
                            controller: controller,
                            gameId: result.gameId,
                            gameType: result.gameType,
                            title: result.title,
                          ),
                  ),
                );
              },
            )
            .animate()
            .fadeIn(duration: 280.ms)
            .slideY(
              begin: 0.08,
              end: 0,
              delay: Duration(milliseconds: 60 * index),
            );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.onTap});

  final KahootResultSummary result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(result.completionDate);
    final isMulti = result.gameType.toLowerCase().contains('multi');
    final isHost = _isHostResult(result.gameType);
    final typeLabel = isHost
        ? 'Sesion (Host)'
        : (isMulti ? 'Multiplayer' : 'Singleplayer');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.card, AppColors.card.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isMulti ? AppColors.accentTeal : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isMulti ? Icons.people_rounded : Icons.person_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title.isEmpty ? 'Kahoot' : result.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              typeLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${result.finalScore} pts',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (result.rankingPosition != null)
                      Text(
                        '#${result.rankingPosition}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '${date.year}-$mm-$dd';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: Colors.white54,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay resultados todavia',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Juega un kahoot para ver tu historial aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Actualizar')),
          ],
        ),
      ),
    );
  }
}

String _mapError(Object? error) {
  final raw = error?.toString().toLowerCase() ?? '';
  if (raw.contains('401')) {
    return 'Necesitas iniciar sesión para ver resultados';
  }
  if (raw.contains('404')) {
    return 'No hay resultados disponibles todavía';
  }
  return 'Error al cargar resultados';
}

bool _isHostResult(String gameType) {
  final normalized = gameType.toLowerCase();
  return normalized.contains('host');
}
