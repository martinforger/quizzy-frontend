import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

/// Pantalla de fin del juego para el JUGADOR rediseñada.
class PlayerGameEndScreen extends StatelessWidget {
  const PlayerGameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is MultiplayerInitial) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerGameEndState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final gameEnd = state.gameEnd;
          final rank = gameEnd.rank;
          final isPodium = rank <= 3;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    const Text(
                      'CONGRATULATIONS!',
                      style: TextStyle(
                        color: AppColors.mpOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: 8),

                    const Text(
                      'Game Finished',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const Spacer(),

                    // Rank Trophy
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: isPodium
                                ? AppColors.mpOrange.withOpacity(0.1)
                                : Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ).animate().scale(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'YOUR RANK',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              '#$rank',
                              style: TextStyle(
                                color: isPodium
                                    ? AppColors.mpOrange
                                    : Colors.white,
                                fontSize: 84,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Stats row
                    Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _EndStat(
                                label: 'TOTAL SCORE',
                                value: '${gameEnd.totalScore}',
                                icon: Icons.stars,
                              ),
                              Container(
                                width: 1,
                                height: 48,
                                color: Colors.white10,
                              ),
                              _EndStat(
                                label: 'ACCURACY',
                                value: '85%', // Mocked for now
                                icon: Icons.timer,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 48),

                    // Back to Start
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<MultiplayerGameCubit>().disconnect();
                          // The listener will handle the pop
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mpOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Back to Start',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 24),
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

class _EndStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _EndStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.mpOrange.withOpacity(0.5), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
