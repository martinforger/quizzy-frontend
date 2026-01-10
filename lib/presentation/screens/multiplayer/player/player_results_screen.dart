import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'player_question_screen.dart';
import 'player_game_end_screen.dart';

/// Pantalla de resultados para el JUGADOR.
///
/// Muestra feedback inmediato (Correcto/Incorrecto), puntaje y streak.
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
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerResultsState) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = state.results;
          final isCorrect = results.isCorrect;

          return Scaffold(
            backgroundColor: isCorrect
                ? const Color(0xFF00D9A5)
                : const Color(0xFFFF6B6B),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // Status Icon
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_rounded : Icons.close_rounded,
                        size: 80,
                        color: isCorrect
                            ? const Color(0xFF00D9A5)
                            : const Color(0xFFFF6B6B),
                      ),
                    ).animate().scale(
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                    const SizedBox(height: 32),

                    // Message
                    Text(
                          isCorrect ? '¡Correcto!' : '¡Incorrecto!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    Text(
                      results.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(
                          label: 'Puntos',
                          value: '+${results.pointsEarned}',
                          icon: Icons.star,
                        ),
                        _StatBox(
                          label: 'Racha',
                          value: '${results.streak} 🔥',
                          icon: Icons.local_fire_department,
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),

                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Estás en el puesto ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            '#${results.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
