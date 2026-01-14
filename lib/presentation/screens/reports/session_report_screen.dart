import 'package:flutter/material.dart';
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                widget.title.isEmpty ? 'Sesion' : widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Jugadores',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...report.playerRanking.map(_RankingTile.new),
              const SizedBox(height: 16),
              Text(
                'Analisis por pregunta',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...report.questionAnalysis.map(_QuestionAnalysisTile.new),
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
        color: AppColors.card,
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
