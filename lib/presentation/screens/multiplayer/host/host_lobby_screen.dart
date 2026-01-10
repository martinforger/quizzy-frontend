import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../domain/multiplayer-game/entities/player_entity.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'host_question_screen.dart';

/// Pantalla del lobby para el HOST.
///
/// Muestra el PIN, código QR, y lista de jugadores conectados.
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
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! HostLobbyState) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = state.session;
          final players = state.players;

          return Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                session.quizTitle,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    context.read<MultiplayerGameCubit>().disconnect();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // PIN Display
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4834D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'PIN del Juego',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatPin(session.sessionPin),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: session.qrToken,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Players count
                  Text(
                    '${state.numberOfPlayers} jugadores conectados',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),

                  const SizedBox(height: 16),

                  // Players list
                  Expanded(
                    child: players.isEmpty
                        ? const Center(
                            child: Text(
                              'Esperando jugadores...',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              return _PlayerTile(player: player, index: index);
                            },
                          ),
                  ),

                  // Start Game Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: players.isNotEmpty
                            ? () {
                                context
                                    .read<MultiplayerGameCubit>()
                                    .startGame();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9A5),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Juego',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  String _formatPin(String pin) {
    // Format PIN with spaces for readability (e.g., "123 456 789")
    final buffer = StringBuffer();
    for (int i = 0; i < pin.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(pin[i]);
    }
    return buffer.toString();
  }
}

class _PlayerTile extends StatelessWidget {
  final PlayerLobbyInfo player;
  final int index;

  const _PlayerTile({required this.player, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors[index % colors.length].withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors[index % colors.length],
            child: Text(
              player.nickname.isNotEmpty
                  ? player.nickname[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
        ],
      ),
    );
  }
}
