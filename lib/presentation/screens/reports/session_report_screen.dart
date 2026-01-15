import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/reports/entities/session_report.dart';
import 'package:quizzy/presentation/state/reports_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({
    super.key,
    required this.controller,
    required this.sessionId,
    required this.title,
  });

  final ReportsController controller;
  final String sessionId;
  final String title;

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  late Future<SessionReport> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.getSessionReport(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de sesion')),
      body: FutureBuilder<SessionReport>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Error al cargar reporte',
              onRetry: () {
                setState(() {
                  _future = widget.controller.getSessionReport(widget.sessionId);
                });
              },
            );
          }

          final report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final date = _formatDate(report.executionDate);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _SessionHero(
                title: widget.title.isEmpty ? 'Sesion' : widget.title,
                date: date,
                players: report.playerRanking.length,
              ).animate().fadeIn(duration: 320.ms),
              const SizedBox(height: 16),
              Text(
                'Jugadores',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...report.playerRanking.asMap().entries.map(
                    (entry) => _RankingTile(entry.value)
                        .animate()
                        .fadeIn(duration: 240.ms)
                        .slideX(
                          begin: 0.08,
                          end: 0,
                          delay: Duration(milliseconds: 50 * entry.key),
                        ),
                  ),
              const SizedBox(height: 20),
              Text(
                'Analisis por pregunta',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...report.questionAnalysis.asMap().entries.map(
                    (entry) => _QuestionAnalysisTile(entry.value)
                        .animate()
                        .fadeIn(duration: 240.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          delay: Duration(milliseconds: 60 * entry.key),
                        ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile(this.item);

  final PlayerRanking item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Text(
              '${item.position}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${item.score} pts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuestionAnalysisTile extends StatelessWidget {
  const _QuestionAnalysisTile(this.item);

  final QuestionAnalysis item;

  @override
  Widget build(BuildContext context) {
    final percentage = (item.correctPercentage * 100).clamp(0, 100);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card,
            AppColors.card.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta ${item.questionIndex + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            item.questionText,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: AppColors.accentTeal,
            ),
          ),
          const SizedBox(height: 6),
          Text('${percentage.toStringAsFixed(0)}% correctas'),
        ],
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

class _SessionHero extends StatelessWidget {
  const _SessionHero({
    required this.title,
    required this.date,
    required this.players,
  });

  final String title;
  final String date;
  final int players;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1F3A), Color(0xFF17141C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Reporte de sesión',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fecha $date · $players jugadores',
              style: const TextStyle(color: AppColors.textMuted),
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
