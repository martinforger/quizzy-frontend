import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/multiplayer-game/entities/player_entity.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

/// Pantalla de fin del juego para el HOST rediseñada.
class HostGameEndScreen extends StatefulWidget {
  const HostGameEndScreen({super.key});

  @override
  State<HostGameEndScreen> createState() => _HostGameEndScreenState();
}

class _HostGameEndScreenState extends State<HostGameEndScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
          if (state is! HostGameEndState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final gameEnd = state.gameEnd;
          final podium = gameEnd.finalPodium;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            body: Stack(
              children: [
                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      AppColors.mpOrange,
                      AppColors.accentTeal,
                      AppColors.triangle,
                      AppColors.diamond,
                    ],
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      Column(
                        children: [
                          const Text(
                            'GAME OVER',
                            style: TextStyle(
                              color: AppColors.mpOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ).animate().fadeIn(),
                          const SizedBox(height: 8),
                          const Text(
                            'Final Results',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Podium
                      Expanded(child: _Podium(podium: podium)),

                      const SizedBox(height: 40),

                      // Actions
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<MultiplayerGameCubit>()
                                      .endSession();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Cerrar'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<MultiplayerGameCubit>()
                                      .endSession();
                                  // The listener will handle the pop
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mpOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<PlayerEntity> podium;

  const _Podium({required this.podium});

  @override
  Widget build(BuildContext context) {
    if (podium.isEmpty) return const SizedBox();

    final first = podium[0];
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (second != null)
            Expanded(
              child:
                  _PodiumPillar(
                    player: second,
                    position: 2,
                    heightFactor: 0.6,
                    color: const Color(0xFFC0C0C0),
                  ).animate().slideY(
                    begin: 1.0,
                    end: 0,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          const SizedBox(width: 12),
          // 1st Place
          Expanded(
            child:
                _PodiumPillar(
                  player: first,
                  position: 1,
                  heightFactor: 0.85,
                  color: const Color(0xFFFFD700),
                ).animate().slideY(
                  begin: 1.0,
                  end: 0,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                ),
          ),
          const SizedBox(width: 12),
          // 3rd Place
          if (third != null)
            Expanded(
              child:
                  _PodiumPillar(
                    player: third,
                    position: 3,
                    heightFactor: 0.45,
                    color: const Color(0xFFCD7F32),
                  ).animate().slideY(
                    begin: 1.0,
                    end: 0,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  ),
            ),
        ],
      ),
    );
  }
}

class _PodiumPillar extends StatelessWidget {
  final PlayerEntity player;
  final int position;
  final double heightFactor;
  final Color color;

  const _PodiumPillar({
    required this.player,
    required this.position,
    required this.heightFactor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Trophy/Icon for winner
        if (position == 1)
          const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 48)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds)
              .shake(hz: 2, curve: Curves.easeInOut),

        const SizedBox(height: 8),

        CircleAvatar(
          radius: position == 1 ? 36 : 28,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
            style: TextStyle(
              color: color,
              fontSize: position == 1 ? 28 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          player.nickname,
          style: TextStyle(
            color: Colors.white,
            fontWeight: position == 1 ? FontWeight.w900 : FontWeight.bold,
            fontSize: position == 1 ? 18 : 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        Text(
          '${player.score} pts',
          style: TextStyle(
            color: AppColors.accentTeal,
            fontWeight: FontWeight.bold,
            fontSize: position == 1 ? 16 : 12,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          height: 300 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.4)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
