import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/multiplayer-game/entities/lobby_state_entity.dart';
import 'package:quizzy/domain/multiplayer-game/entities/player_entity.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'host_question_screen.dart';

/// Pantalla del lobby para el HOST rediseñada.
class HostLobbyScreen extends StatelessWidget {
  const HostLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is HostQuestionState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HostQuestionScreen()),
          );
        } else if (state is MultiplayerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial) {
          // Fix bug: go back if session is closed or reset
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! HostLobbyState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final session = state.session;
          final players = state.players;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  context.read<MultiplayerGameCubit>().disconnect();
                },
              ),
              title: Column(
                children: [
                  const Text(
                    'LIVE LOBBY',
                    style: TextStyle(
                      color: AppColors.mpOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    session.quizTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 20),
                // Main Card (QR + PIN)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.mpCard,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // QR Code placeholder/preview
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.mpOrange.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: QrImageView(
                          data: session.qrToken,
                          version: QrVersions.auto,
                          size: 100,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.mpOrange,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GAME PIN',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPin(session.sessionPin),
                        style: const TextStyle(
                          color: AppColors.mpOrange,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SmallActionButton(
                            icon: Icons.copy,
                            label: 'Copy Link',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _SmallActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(delay: 200.ms),

                const SizedBox(height: 32),

                // Players Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Players',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.numberOfPlayers}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'RECEIVING CONNECTIONS',
                            style: TextStyle(
                              color: AppColors.accentTeal,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Players grid
                Expanded(
                  child: players.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.more_horiz,
                              color: Colors.white24,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'WAITING FOR FRIENDS...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            return _PlayerCard(player: players[index]);
                          },
                        ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Lock Lobby'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: players.isNotEmpty
                              ? () => context
                                    .read<MultiplayerGameCubit>()
                                    .startGame()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mpOrange,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start Game',
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
          );
        },
      ),
    );
  }

  String _formatPin(String pin) {
    if (pin.length < 6) return pin;
    return '${pin.substring(0, 3)} ${pin.substring(3)}';
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerLobbyInfo player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mpCard,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mpOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 16,
              color: AppColors.mpOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              player.nickname,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
