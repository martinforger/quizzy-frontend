import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'player_question_screen.dart';

/// Pantalla del lobby para el JUGADOR.
///
/// Muestra estado de espera y permite configurar nickname.
class PlayerLobbyScreen extends StatefulWidget {
  const PlayerLobbyScreen({super.key});

  @override
  State<PlayerLobbyScreen> createState() => _PlayerLobbyScreenState();
}

class _PlayerLobbyScreenState extends State<PlayerLobbyScreen> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is PlayerLobbyState &&
            state.nickname.isNotEmpty &&
            _nicknameController.text.isEmpty) {
          _nicknameController.text = state.nickname;
        } else if (state is PlayerQuestionState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PlayerQuestionScreen()),
          );
        } else if (state is MultiplayerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is! PlayerLobbyState) {
          return const Center(child: CircularProgressIndicator());
        }

        final isJoined = state.nicknameSubmitted;

        return Scaffold(
          backgroundColor: const Color(0xFF4834D4), // Purple theme for player
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                context.read<MultiplayerGameCubit>().disconnect();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Title
                  const Text(
                    'Quizzy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'FredokaOne', // Assuming font exists or fallback
                    ),
                  ).animate().scale(duration: 500.ms),

                  const SizedBox(height: 48),

                  if (!isJoined) ...[
                    // Nickname Input
                    Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
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
                              const Text(
                                'Elige un Nickname',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2d3436),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nicknameController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Ej. SuperPlayer',
                                  filled: true,
                                  fillColor: const Color(0xFFf1f2f6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_nicknameController.text.length >= 3) {
                                      context
                                          .read<MultiplayerGameCubit>()
                                          .joinWithNickname(
                                            _nicknameController.text,
                                          );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'El nickname debe tener al menos 3 caracteres',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00D9A5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    '¡Listo, vamos!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .slideY(begin: 0.2, end: 0, duration: 400.ms)
                        .fadeIn(),
                  ] else ...[
                    // Waiting State
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '¡Estás dentro, ${state.nickname}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Mira la pantalla del anfitrión',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const CircularProgressIndicator(color: Colors.white),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
