import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/game_cubit.dart';
import '../../../bloc/game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedbackOverlay extends StatelessWidget {
  final GameAnswerFeedback state;

  const FeedbackOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state.wasCorrect
        ? const Color(0xFF66BF39)
        : const Color(0xFFFF3355);
    final text = state.wasCorrect ? "Correcto!!" : "Fallaste 😔";
    final icon = state.wasCorrect ? Icons.check_circle : Icons.cancel;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 100)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shake(),
            const SizedBox(height: 16),
            Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            if (state.wasCorrect)
              Text(
                "+${state.pointsEarned}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().scale(
                delay: 300.ms,
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
            const SizedBox(height: 8),
            Text(
              "Puntuación total: ${state.totalScore}",
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                if (state.nextSlide != null) {
                  context.read<GameCubit>().nextQuestion(state.nextSlide);
                } else {
                  context.read<GameCubit>().loadSummary();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                state.nextSlide != null ? "Siguiente" : "Ver Resumen",
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
