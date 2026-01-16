import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'host_question_screen.dart';
import 'host_game_end_screen.dart';

/// Pantalla de resultados de la pregunta para el HOST rediseñada.
class HostResultsScreen extends StatelessWidget {
  const HostResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is HostQuestionState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HostQuestionScreen()),
          );
        } else if (state is HostGameEndState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HostGameEndScreen()),
          );
        } else if (state is MultiplayerSessionClosed ||
            state is MultiplayerInitial) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! HostResultsState) {
            return const Scaffold(
              backgroundColor: AppColors.mpBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.mpOrange),
              ),
            );
          }

          final results = state.results;
          final distribution = results.stats.distribution;
          final keys = distribution.keys.toList()..sort();

          final maxCount = distribution.isEmpty
              ? 1
              : distribution.values.reduce((a, b) => a > b ? a : b);
          if (maxCount == 0) {} // handle no responses?

          return Scaffold(
            backgroundColor: AppColors.mpBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'QUESTION RESULTS',
                style: TextStyle(
                  color: AppColors.mpOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Bar Chart
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(4, (index) {
                          final key = index.toString();
                          final count = distribution[key] ?? 0;
                          final isCorrect = results.correctAnswerId.contains(
                            key,
                          );

                          return _ResultBar(
                            index: index,
                            count: count,
                            total: maxCount == 0 ? 1 : maxCount,
                            isCorrect: isCorrect,
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Correct Answer Reveal
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.mpCard,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'CORRECT ANSWER ID',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          results.correctAnswerId.join(', '),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 40),

                  // Footer Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(
                          label: 'TOTAL ANSWERS',
                          value: '${results.stats.totalAnswers}',
                        ),
                      ],
                    ),
                  ),

                  // Next Action
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.read<MultiplayerGameCubit>().nextPhase(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mpOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next Question',
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
}

class _ResultBar extends StatelessWidget {
  final int index;
  final int count;
  final int total;
  final bool isCorrect;

  const _ResultBar({
    required this.index,
    required this.count,
    required this.total,
    required this.isCorrect,
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

    final double heightFactor = total > 0
        ? (count / total).clamp(0.05, 1.0)
        : 0.05;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 200 * heightFactor,
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            borderRadius: BorderRadius.circular(8),
          ),
          child: isCorrect
              ? const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 24),
                )
              : null,
        ).animate().scaleY(
          alignment: Alignment.bottomCenter,
          duration: 800.ms,
          curve: Curves.easeOutBack,
        ),
        const SizedBox(height: 12),
        shapes[index % shapes.length],
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom Shape Icons (same as Question Screen)
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
