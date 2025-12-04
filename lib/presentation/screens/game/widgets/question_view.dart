import 'package:flutter/material.dart';
import '../../../../domain/solo-game/entities/slide_entity.dart';
import 'answer_grid.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuestionView extends StatelessWidget {
  final SlideEntity slide;
  final int currentScore;
  final int questionIndex;

  const QuestionView({
    super.key,
    required this.slide,
    required this.currentScore,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header: Question Count & Score
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$questionIndex', // Simplified, usually "1 of 10"
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Puntuación: $currentScore',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Question Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              slide.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
          ),

          const SizedBox(height: 20),

          // Media Placeholder (Image/Video)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: slide.mediaUrl != null
                    ? DecorationImage(
                        image: NetworkImage(slide.mediaUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: slide.mediaUrl == null
                  ? const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.grey),
                    )
                  : null,
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(),
          ),

          const SizedBox(height: 20),

          // Timer (Simplified)
          // In a real app, this would be animated.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: 1.0, // Full for now
              backgroundColor: Colors.grey[300],
              color: Colors.purple,
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 20),

          // Answer Grid
          Expanded(
            flex: 2,
            child: AnswerGrid(options: slide.options, slideId: slide.slideId),
          ),
        ],
      ),
    );
  }
}
