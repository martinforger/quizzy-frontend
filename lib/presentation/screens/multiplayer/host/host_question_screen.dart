import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'host_results_screen.dart';

/// Pantalla de pregunta para el HOST rediseñada.
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
    if (seconds <= 0) return;

    final totalMs = seconds * 1000;
    final startValue = remainingMs != null ? remainingMs / totalMs : 1.0;

    _timerController.duration = Duration(milliseconds: remainingMs ?? totalMs);
    _timerController.reverse(from: startValue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
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
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! HostQuestionState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final slide = state.question.currentSlideData;
          final submissionCount = state.submissionCount;
          final current = state.question.position;
          final total = state.question.totalQuestions;
          final progress = total > 0 ? (current / total) * 100 : 0;

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUIZ QUESTION',
                              style: TextStyle(
                                color: AppColors.mpOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'Question $current ${total > 0 ? "of $total" : ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${progress.toInt()}% complete',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question Area with Timer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Timer
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: AnimatedBuilder(
                                animation: _timerController,
                                builder: (context, child) {
                                  return CircularProgressIndicator(
                                    value: _timerController.value,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white12,
                                    color: _getTimerColor(
                                      _timerController.value,
                                    ),
                                  );
                                },
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _timerController,
                              builder: (context, child) {
                                final seconds =
                                    (_timerController.value *
                                            (slide.timeLimitSeconds))
                                        .ceil();
                                return Text(
                                  '$seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            slide.questionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                  const SizedBox(height: 24),

                  // Media Container
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(32),
                        image: slide.mediaUrl != null
                            ? DecorationImage(
                                image: NetworkImage(slide.mediaUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: slide.mediaUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white10,
                                size: 80,
                              ),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Answers Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: slide.options.length,
                      itemBuilder: (context, index) {
                        final option = slide.options[index];
                        return _AnswerBox(
                          index: index,
                          text: option.text ?? '',
                        );
                      },
                    ),
                  ),

                  // Submissions Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentTeal.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people,
                                color: AppColors.accentTeal,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$submissionCount players answered',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<MultiplayerGameCubit>().nextPhase(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Show Results'),
                        ),
                      ],
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

  Color _getTimerColor(double value) {
    if (value > 0.5) return AppColors.accentTeal;
    if (value > 0.2) return AppColors.mpOrange;
    return AppColors.triangle;
  }
}

class _AnswerBox extends StatelessWidget {
  final int index;
  final String text;

  const _AnswerBox({required this.index, required this.text});

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

    return Container(
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          shapes[index % shapes.length],
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100)));
  }
}

// Custom Shape Icons
class _TriangleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _ShapePainter(shapeType: 'triangle'),
    );
  }
}

class _DiamondIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _ShapePainter(shapeType: 'diamond'),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
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
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
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
