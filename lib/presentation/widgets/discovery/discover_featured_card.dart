import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class DiscoverFeaturedCard extends StatelessWidget {
  const DiscoverFeaturedCard({super.key, required this.quiz});

  final QuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          _Thumb(quiz: quiz),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.tag.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.author,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.quiz});

  final QuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    final tag = quiz.tag.toLowerCase();
    final color = tag.contains('science')
        ? Colors.deepPurple
        : tag.contains('history')
            ? Colors.orangeAccent
            : Colors.teal;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        image: quiz.thumbnailUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(quiz.thumbnailUrl),
                fit: BoxFit.cover,
                opacity: 0.9,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
      ),
      child: Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}
