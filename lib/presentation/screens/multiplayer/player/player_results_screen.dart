import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'player_question_screen.dart';
import 'player_game_end_screen.dart';

/// Pantalla de resultados de la pregunta para el JUGADOR rediseñada.
class PlayerResultsScreen extends StatelessWidget {
  const PlayerResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is PlayerQuestionState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PlayerQuestionScreen()),
          );
        } else if (state is PlayerGameEndState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PlayerGameEndScreen()),
          );
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial ||
            state is HostDisconnected) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerResultsState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final results = state.results;
          final isCorrect = results.isCorrect;
          final bgColor = isCorrect ? AppColors.accentTeal : AppColors.triangle;

          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // Patterns/Shapes in background (subtle)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(painter: _PatternPainter()),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 80,
                          ),
                        ).animate().scale(
                          curve: Curves.elasticOut,
                          duration: 800.ms,
                        ),

                        const SizedBox(height: 32),

                        // Main Text
                        Text(
                              isCorrect ? '¡CORRECTO!' : '¡OUCH!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 8),

                        Text(
                          isCorrect
                              ? '¡Sigue así, vas por buen camino!'
                              : 'No te preocupes, ¡la próxima será mejor!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 48),

                        // Points Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isCorrect ? '+${results.pointsEarned}' : '0',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'PUNTOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms).scale(),

                        const SizedBox(height: 64),

                        // Waiting message
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Mira la pantalla principal...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ).animate().fadeIn(delay: 1000.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw some random circles/shapes
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
