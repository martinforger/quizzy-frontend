import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'player_results_screen.dart';

/// Pantalla de pregunta para el JUGADOR.
///
/// Muestra las opciones de respuesta (Grid) para que el jugador participe.
class PlayerQuestionScreen extends StatelessWidget {
  const PlayerQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is PlayerResultsState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PlayerResultsScreen()),
          );
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerQuestionState) {
            return const Center(child: CircularProgressIndicator());
          }

          final question = state.question;
          final hasAnswered = state.hasAnswered;

          return Scaffold(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary, // Match Solo Game
            body: SafeArea(
              child: Column(
                children: [
                  // Header: Position & Status
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${question.position}',
                            style: const TextStyle(
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Jugando',
                            style: TextStyle(
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: hasAnswered
                        ? _WaitingForOthersView()
                        : _ActiveQuestionView(
                            slide: question
                                .currentSlideData, // Pass full slide for Text/Media
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

class _ActiveQuestionView extends StatelessWidget {
  final dynamic slide; // Using dynamic or SlideEntity to access text/media

  const _ActiveQuestionView({required this.slide});

  @override
  Widget build(BuildContext context) {
    // We access properties safely
    final String questionText = slide.questionText;
    final String? mediaUrl = slide.mediaUrl;
    final List<dynamic> options = slide.options;
    final String slideId = slide.slideId;

    return Column(
      children: [
        // Question Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Onest',
              fontSize: 20, // Slightly smaller for mobile players
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
        ),

        const SizedBox(height: 16),

        // Media (Optional for player, but requested to look like Solo Game)
        if (mediaUrl != null)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(mediaUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
          )
        else
          const Spacer(),

        const SizedBox(height: 16),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Selecciona respuesta',
            style: TextStyle(
              fontFamily: 'Onest',
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          flex: 3,
          child: _MultiplayerAnswerGrid(options: options, slideId: slideId),
        ),
      ],
    );
  }
}

class _WaitingForOthersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9A5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9A5).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.check, size: 60, color: Colors.white),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          const Text(
            'Respuesta enviada',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2d3436),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Esperando a que todos respondan...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MultiplayerAnswerGrid extends StatelessWidget {
  final List<dynamic> options;
  final String slideId;

  const _MultiplayerAnswerGrid({required this.options, required this.slideId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (options.isNotEmpty)
                  Expanded(
                    child: _AnswerButton(
                      option: options[0],
                      color: Colors.red,
                      icon: Icons.change_history,
                      slideId: slideId,
                    ),
                  ),
                if (options.length > 1)
                  Expanded(
                    child: _AnswerButton(
                      option: options[1],
                      color: Colors.blue,
                      icon: Icons.diamond,
                      slideId: slideId,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (options.length > 2)
                  Expanded(
                    child: _AnswerButton(
                      option: options[2],
                      color: Colors.amber,
                      icon: Icons.circle,
                      slideId: slideId,
                    ),
                  ),
                if (options.length > 3)
                  Expanded(
                    child: _AnswerButton(
                      option: options[3],
                      color: Colors.green,
                      icon: Icons.square,
                      slideId: slideId,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final dynamic option;
  final Color color;
  final IconData icon;
  final String slideId;

  const _AnswerButton({
    required this.option,
    required this.color,
    required this.icon,
    required this.slideId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final index = int.tryParse(option.index.toString()) ?? 0;
        context.read<MultiplayerGameCubit>().submitAnswer(
          questionId: slideId,
          answerIds: [index.toString()],
          timeElapsedMs: 5000, // Using dummy time or calculate real time
        );
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 48),
            if (option.text != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  option.text!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
