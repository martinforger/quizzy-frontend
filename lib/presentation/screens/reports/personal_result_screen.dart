import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/reports/entities/personal_result.dart';
import 'package:quizzy/presentation/state/reports_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class PersonalResultScreen extends StatefulWidget {
  const PersonalResultScreen({
    super.key,
    required this.controller,
    required this.gameId,
    required this.gameType,
    required this.title,
  });

  final ReportsController controller;
  final String gameId;
  final String gameType;
  final String title;

  @override
  State<PersonalResultScreen> createState() => _PersonalResultScreenState();
}

class _PersonalResultScreenState extends State<PersonalResultScreen> {
  late Future<PersonalResult> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.getPersonalResult(
      gameType: widget.gameType,
      gameId: widget.gameId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMulti = widget.gameType.toLowerCase().contains('multi');

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: FutureBuilder<PersonalResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Error al cargar resultado',
              onRetry: () {
                setState(() {
                  _future = widget.controller.getPersonalResult(
                    gameType: widget.gameType,
                    gameId: widget.gameId,
                  );
                });
              },
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final avgSeconds = result.averageTimeMs / 1000.0;
          final scoreLabel = '${result.finalScore} pts';
          final heroImage = _extractHeroImage(result);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _HeroHeader(
                title: widget.title.isEmpty ? 'Kahoot' : widget.title,
                imageUrl: heroImage,
                subtitle: isMulti ? 'Multiplayer' : 'Singleplayer',
              ).animate().fadeIn(duration: 320.ms),
              const SizedBox(height: 16),
              _StatsRow(
                score: scoreLabel,
                correct: '${result.correctAnswers}/${result.totalQuestions}',
                avgTime: '${avgSeconds.toStringAsFixed(1)}s',
                ranking: result.rankingPosition != null
                    ? '#${result.rankingPosition}'
                    : null,
              ).animate().fadeIn(duration: 320.ms, delay: 80.ms),
              const SizedBox(height: 20),
              Text(
                'Preguntas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...result.questionResults.asMap().entries.map(
                    (entry) => _QuestionResultCard(entry.value)
                        .animate()
                        .fadeIn(duration: 260.ms)
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2333), Color(0xFF18151C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.medium,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.score,
    required this.correct,
    required this.avgTime,
    this.ranking,
  });

  final String score;
  final String correct;
  final String avgTime;
  final String? ranking;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatChip(label: 'Score', value: score),
        _StatChip(label: 'Correctas', value: correct),
        _StatChip(label: 'Promedio', value: avgTime),
        if (ranking != null) _StatChip(label: 'Ranking', value: ranking!),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuestionResultCard extends StatelessWidget {
  const _QuestionResultCard(this.item);

  final QuestionResult item;

  @override
  Widget build(BuildContext context) {
    final isCorrect = item.isCorrect;
    final color = isCorrect ? Colors.green : Colors.redAccent;
    final mediaUrl = _firstMediaUrl(item.answerMediaUrls);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mediaUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                mediaUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.white10,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white30,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pregunta ${item.questionIndex + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(item.timeTakenMs / 1000).toStringAsFixed(1)}s',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.questionText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (item.answerTexts.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.answerTexts
                  .map((text) => _AnswerChip(label: text))
                  .toList(),
            ),
          if (item.answerMediaUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.answerMediaUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = item.answerMediaUrls[index];
                  final isUrl = url.startsWith('http');
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: isUrl
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white30,
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
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

String? _extractHeroImage(PersonalResult result) {
  for (final item in result.questionResults) {
    final url = _firstMediaUrl(item.answerMediaUrls);
    if (url != null) {
      return url;
    }
  }
  return null;
}

String? _firstMediaUrl(List<String> urls) {
  for (final url in urls) {
    if (url.startsWith('http')) {
      return url;
    }
  }
  return null;
}
