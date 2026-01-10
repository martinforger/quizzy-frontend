import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Pantalla de fin de juego para el JUGADOR.
///
/// Muestra su posición final y resumen.
class PlayerGameEndScreen extends StatelessWidget {
  const PlayerGameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
      builder: (context, state) {
        if (state is! PlayerGameEndState) {
          return const Center(child: CircularProgressIndicator());
        }

        final gameEnd = state.gameEnd;
        final isPodium = gameEnd.isPodium;

        return Scaffold(
          backgroundColor: const Color(0xFF4834D4),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Juego Terminado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Rank Display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isPodium
                              ? const Color(0xFFFFD700).withOpacity(0.5)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Puesto',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '#${gameEnd.rank}',
                          style: TextStyle(
                            color: const Color(0xFF4834D4),
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            shadows: isPodium
                                ? [
                                    const Shadow(
                                      color: Color(0xFFFFD700),
                                      blurRadius: 20,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 48),

                  // Final Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Puntaje Final',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${gameEnd.totalScore} pts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<MultiplayerGameCubit>().disconnect();
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4834D4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Volver al Inicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
