import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class DiscoverFeaturedCard extends StatelessWidget {
  const DiscoverFeaturedCard({
    super.key,
    required this.quiz,
    required this.index,
    this.onTap,
    this.onFavoriteToggle,
  });

  final QuizSummary quiz;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeColor = colorScheme.primary.withOpacity(0.12);

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Row(
                    children: [
                      _Thumb(quiz: quiz),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        quiz.tag.toUpperCase(),
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (quiz.playCount != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${quiz.playCount} P',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  quiz.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                quiz.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (onFavoriteToggle != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFavoriteToggle,
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    quiz.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: quiz.isFavorite ? Colors.amber : Colors.grey[400],
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
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
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: Container(
        width: 132,
        height: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
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
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
