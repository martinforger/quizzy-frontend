import 'package:flutter/material.dart';
import '../../../../domain/solo-game/entities/slide_entity.dart';
import 'answer_grid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/presentation/bloc/game_cubit.dart';

class QuestionView extends StatefulWidget {
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
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    // Setup timer
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.slide.timeLimitSeconds),
    );

    // Start timer (countdown from 1.0 to 0.0)
    _timerController.reverse(from: 1.0);

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _onTimeExpired();
      }
    });
  }

  @override
  void didUpdateWidget(QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slide.slideId != widget.slide.slideId) {
      // Reset timer for new question
      _timerController.duration = Duration(
        seconds: widget.slide.timeLimitSeconds,
      );
      _timerController.reverse(from: 1.0);
    }
  }

  void _onTimeExpired() {
    // Auto-submit empty answer (incorrect)
    if (mounted) {
      // Avoid double submission if user taps at the last moment
      // We can check if the widget is still active or block inputs.
      // GameCubit handles logic, but let's just trigger it.
      context.read<GameCubit>().submitAnswer(
        widget.slide.slideId,
        [], // Empty options = wrong
        widget.slide.timeLimitSeconds, // Took full time
      );
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

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
                    '${widget.questionIndex}', // Simplified, usually "1 of 10"
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Puntuación: ${widget.currentScore}',
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
              widget.slide.questionText,
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
          if (widget.slide.mediaUrl != null)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.slide.mediaUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(),
            ),

          const SizedBox(height: 20),

          // Timer Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _timerController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _timerController.value,
                  backgroundColor: Colors.grey[300],
                  color: _getTimerColor(_timerController.value),
                  minHeight: 8,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Answer Grid
          Expanded(
            flex: 2,
            child: AnswerGrid(
              options: widget.slide.options,
              slideId: widget.slide.slideId,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(double value) {
    if (value > 0.5) return Colors.purple;
    if (value > 0.2) return Colors.orange;
    return Colors.red;
  }
}
