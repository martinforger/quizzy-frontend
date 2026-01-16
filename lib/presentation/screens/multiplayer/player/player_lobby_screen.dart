import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'player_question_screen.dart';

/// Pantalla del lobby para el JUGADOR rediseñada.
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

  void _submitNickname() {
    if (_nicknameController.text.trim().isNotEmpty) {
      context.read<MultiplayerGameCubit>().joinWithNickname(
        _nicknameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is PlayerQuestionState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PlayerQuestionScreen()),
          );
        } else if (state is MultiplayerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial ||
            state is HostDisconnected) {
          // Fix bug: go back if session is closed or host DC
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerLobbyState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final hasNickname = state.nicknameSubmitted;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  context.read<MultiplayerGameCubit>().disconnect();
                },
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!hasNickname) ...[
                          // Nickname Entry
                          const Text(
                            '¡CASI LISTO!',
                            style: TextStyle(
                              color: AppColors.mpOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ).animate().fadeIn(),
                          const SizedBox(height: 12),
                          const Text(
                            'Ingresa tu apodo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 32),
                          TextField(
                                controller: _nicknameController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tu nombre aquí...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => _submitNickname(),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitNickname,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mpOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                '¡ENTRAR!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                        ] else ...[
                          // Waiting State
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.accentTeal,
                            size: 100,
                          ).animate().scale(curve: Curves.elasticOut),
                          const SizedBox(height: 24),
                          const Text(
                            '¡ESTÁS DENTRO!',
                            style: TextStyle(
                              color: AppColors.mpOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 12),
                          Text(
                            state.nickname,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 48),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Text(
                                  'Esperando al anfitrión...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 600.ms),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
