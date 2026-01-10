import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/solo-game/entities/slide_entity.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'host_results_screen.dart';

/// Pantalla de pregunta para el HOST.
///
/// Muestra la pregunta, opciones, timer, y contador de respuestas recibidas.
class HostQuestionScreen extends StatefulWidget {
  const HostQuestionScreen({super.key});

  @override
  State<HostQuestionScreen> createState() => _HostQuestionScreenState();
}

class _HostQuestionScreenState extends State<HostQuestionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _initTimer(int seconds, int? remainingMs) {
    final totalMs = seconds * 1000;
    final startValue = remainingMs != null ? remainingMs / totalMs : 1.0;

    _timerController.duration = Duration(milliseconds: remainingMs ?? totalMs);
    _timerController.reverse(from: startValue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is HostQuestionState) {
          _initTimer(
            state.question.currentSlideData.timeLimitSeconds,
            state.question.timeRemainingMs,
          );
        } else if (state is HostResultsState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HostResultsScreen()),
          );
        }
      },
      builder: (context, state) {
        if (state is! HostQuestionState) {
          return const Center(child: CircularProgressIndicator());
        }

        final slide = state.question.currentSlideData;
        final submissionCount = state.submissionCount;

        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary, // Match Solo Game BG
          body: SafeArea(
            child: Column(
              children: [
                // Header: Position & Submission count in Pills
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
                          color: Colors.white.withOpacity(0.2), // Light pill
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.question.position}', // Simplified like "1/10"
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$submissionCount',
                              style: const TextStyle(
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Question Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Text(
                            slide.questionText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Onest',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -0.2, end: 0),
                ),

                const SizedBox(height: 20),

                // Media
                if (slide.mediaUrl != null)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(slide.mediaUrl!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(),
                  ),

                const SizedBox(height: 20),

                // Timer Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _timerController.value,
                          backgroundColor: Colors.white24,
                          color: _getTimerColor(_timerController.value),
                          minHeight: 12,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Answer Options Display (Host View)
                Expanded(
                  flex: 2,
                  child: _HostAnswerDisplay(options: slide.options),
                ),

                // Next Phase Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<MultiplayerGameCubit>().nextPhase();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Mostrar Resultados',
                        style: TextStyle(
                          fontFamily: 'Onest',
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
    );
  }

  Color _getTimerColor(double value) {
    if (value > 0.5) return const Color(0xFF6C63FF);
    if (value > 0.2) return Colors.orange;
    return Colors.red;
  }
}

/// Display de opciones para el Host (solo visualización).
class _HostAnswerDisplay extends StatelessWidget {
  final List<OptionEntity> options;

  const _HostAnswerDisplay({required this.options});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.blue, Colors.amber, Colors.green];
    final icons = [
      Icons.change_history,
      Icons.diamond,
      Icons.circle,
      Icons.square,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return Container(
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icons[index % icons.length],
                      color: Colors.white,
                      size: 24,
                    ),
                    if (option.text != null && option.text!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          option.text!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .slideY(
                begin: 1,
                end: 0,
                delay: Duration(milliseconds: 300 + (index * 100)),
                duration: 400.ms,
              )
              .fadeIn();
        },
      ),
    );
  }
}
