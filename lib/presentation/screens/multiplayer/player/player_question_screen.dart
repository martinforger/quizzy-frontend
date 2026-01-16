import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'player_results_screen.dart';

/// Pantalla de pregunta para el JUGADOR rediseñada.
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
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial ||
            state is HostDisconnected) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! PlayerQuestionState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final slide = state.question.currentSlideData;
          final hasAnswered = state.hasAnswered;
          final current = state.question.position;
          final total = state.question.totalQuestions;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Column(
                children: [
                  const Text(
                    'ELIGE LA RESPUESTA CORRECTA',
                    style: TextStyle(
                      color: AppColors.mpOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Pregunta $current ${total > 0 ? "de $total" : ""}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: total > 0 ? current / total : 0,
                        backgroundColor: Colors.white10,
                        color: AppColors.accentTeal,
                        minHeight: 6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Question Text
                  if (!hasAnswered)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        slide.questionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                    ),

                  const SizedBox(height: 32),

                  if (hasAnswered)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.accentTeal,
                              size: 100,
                            ).animate().scale(curve: Curves.elasticOut),
                            const SizedBox(height: 24),
                            const Text(
                              '¡RESPUESTA ENVIADA!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Espera a que termine el tiempo...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 32),
                          itemCount: slide.options.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final option = slide.options[index];
                            return _OptionButton(
                              index: index,
                              text: option.text ?? '',
                              onPressed: () {
                                context
                                    .read<MultiplayerGameCubit>()
                                    .submitAnswer(
                                      questionId: slide.slideId,
                                      answerIds: [option.index],
                                      timeElapsedMs: 0,
                                    );
                              },
                            );
                          },
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
}

class _OptionButton extends StatelessWidget {
  final int index;
  final String text;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.index,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.triangle,
      AppColors.diamond,
      AppColors.circle,
      AppColors.square,
    ];
    final shapes = [
      _TriangleIcon(),
      _DiamondIcon(),
      _CircleIcon(),
      _SquareIcon(),
    ];

    return Material(
          color: colors[index % colors.length],
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              constraints: const BoxConstraints(minHeight: 70),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  shapes[index % shapes.length],
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white24,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2, end: 0);
  }
}

// Custom Shape Icons
class _TriangleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 32),
      painter: _ShapePainter(shapeType: 'triangle'),
    );
  }
}

class _DiamondIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 32),
      painter: _ShapePainter(shapeType: 'diamond'),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SquareIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String shapeType;

  _ShapePainter({required this.shapeType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (shapeType == 'triangle') {
      final path = Path();
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    } else if (shapeType == 'diamond') {
      final path = Path();
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(0, size.height / 2);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
