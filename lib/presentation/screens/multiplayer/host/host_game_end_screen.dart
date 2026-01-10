import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../../domain/multiplayer-game/entities/player_entity.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Pantalla de fin del juego para el HOST.
///
/// Muestra el podio final con los 3 mejores jugadores.
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
    return BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
      builder: (context, state) {
        if (state is! HostGameEndState) {
          return const Center(child: CircularProgressIndicator());
        }

        final gameEnd = state.gameEnd;
        final podium = gameEnd.finalPodium;
        final winner = gameEnd.winner;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      '🎉 ¡Fin del Juego! 🎉',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 16),

                    Text(
                      '${gameEnd.totalParticipants} participantes',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Podium
                    Expanded(
                      child: _Podium(podium: podium, winner: winner),
                    ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context
                                    .read<MultiplayerGameCubit>()
                                    .endSession();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Cerrar Sesión'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<MultiplayerGameCubit>()
                                    .endSession();
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Volver al Inicio'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Color(0xFF6C63FF),
                    Color(0xFF00D9A5),
                    Color(0xFFFFD700),
                    Color(0xFFFF6B6B),
                    Color(0xFF4ECDC4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Podium extends StatelessWidget {
  final List<PlayerEntity> podium;
  final PlayerEntity winner;

  const _Podium({required this.podium, required this.winner});

  @override
  Widget build(BuildContext context) {
    // Ensure we have at least placeholder data for podium positions
    final first = podium.isNotEmpty ? podium[0] : null;
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second Place
          Expanded(
            child: second != null
                ? _PodiumPosition(
                    player: second,
                    position: 2,
                    height: 140,
                    color: const Color(0xFFC0C0C0),
                  ).animate().slideY(
                    begin: 1,
                    end: 0,
                    delay: 300.ms,
                    duration: 600.ms,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          // First Place
          Expanded(
            child: first != null
                ? _PodiumPosition(
                    player: first,
                    position: 1,
                    height: 180,
                    color: const Color(0xFFFFD700),
                  ).animate().slideY(
                    begin: 1,
                    end: 0,
                    delay: 100.ms,
                    duration: 600.ms,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          // Third Place
          Expanded(
            child: third != null
                ? _PodiumPosition(
                    player: third,
                    position: 3,
                    height: 100,
                    color: const Color(0xFFCD7F32),
                  ).animate().slideY(
                    begin: 1,
                    end: 0,
                    delay: 500.ms,
                    duration: 600.ms,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _PodiumPosition extends StatelessWidget {
  final PlayerEntity player;
  final int position;
  final double height;
  final Color color;

  const _PodiumPosition({
    required this.player,
    required this.position,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Medal
        Text(medals[position - 1], style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        // Avatar
        CircleAvatar(
          radius: 32,
          backgroundColor: color.withValues(alpha: 0.3),
          child: Text(
            player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Name
        Text(
          player.nickname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Score
        Text(
          '${player.score} pts',
          style: const TextStyle(
            color: Color(0xFF00D9A5),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
