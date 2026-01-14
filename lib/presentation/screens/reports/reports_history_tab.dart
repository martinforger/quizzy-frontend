import 'package:flutter/material.dart';
import 'package:quizzy/domain/reports/entities/kahoot_result_summary.dart';
import 'package:quizzy/domain/reports/entities/reports_page.dart';
import 'package:quizzy/presentation/screens/reports/personal_result_screen.dart';
import 'package:quizzy/presentation/state/reports_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class ReportsHistoryTab extends StatefulWidget {
  const ReportsHistoryTab({super.key, required this.controller});

  final ReportsController controller;

  @override
  State<ReportsHistoryTab> createState() => _ReportsHistoryTabState();
}

class _ReportsHistoryTabState extends State<ReportsHistoryTab> {
  late Future<ReportsPage<KahootResultSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.getMyResults();
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
        const SnackBar(
          content: Text('No pudimos cargar los resultados'),
        ),
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
            return const Center(
              child: Text('No hay resultados todavia'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _ResultCard(
                result: result,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PersonalResultScreen(
                        controller: widget.controller,
                        gameId: result.gameId,
                        gameType: result.gameType,
                        title: result.title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
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
                      Text(
                        'Fecha: $date',
                        style: const TextStyle(color: AppColors.textMuted),
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
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
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
