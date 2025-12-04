import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/solo-game/entities/slide_entity.dart';
import '../../../bloc/game_cubit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnswerGrid extends StatelessWidget {
  final List<OptionEntity> options;
  final String slideId;

  const AnswerGrid({super.key, required this.options, required this.slideId});

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
                    child:
                        _AnswerCard(
                              option: options[0],
                              color: Colors.red,
                              icon: Icons.change_history,
                              slideId: slideId,
                            )
                            .animate()
                            .slideY(
                              begin: 1,
                              end: 0,
                              delay: 300.ms,
                              duration: 400.ms,
                            )
                            .fadeIn(),
                  ),
                if (options.length > 1)
                  Expanded(
                    child:
                        _AnswerCard(
                              option: options[1],
                              color: Colors.blue,
                              icon: Icons.diamond,
                              slideId: slideId,
                            )
                            .animate()
                            .slideY(
                              begin: 1,
                              end: 0,
                              delay: 400.ms,
                              duration: 400.ms,
                            )
                            .fadeIn(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (options.length > 2)
                  Expanded(
                    child:
                        _AnswerCard(
                              option: options[2],
                              color: Colors.amber,
                              icon: Icons.circle,
                              slideId: slideId,
                            )
                            .animate()
                            .slideY(
                              begin: 1,
                              end: 0,
                              delay: 500.ms,
                              duration: 400.ms,
                            )
                            .fadeIn(),
                  ),
                if (options.length > 3)
                  Expanded(
                    child:
                        _AnswerCard(
                              option: options[3],
                              color: Colors.green,
                              icon: Icons.square,
                              slideId: slideId,
                            )
                            .animate()
                            .slideY(
                              begin: 1,
                              end: 0,
                              delay: 600.ms,
                              duration: 400.ms,
                            )
                            .fadeIn(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final OptionEntity option;
  final Color color;
  final IconData icon;
  final String slideId;

  const _AnswerCard({
    required this.option,
    required this.color,
    required this.icon,
    required this.slideId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final index = int.tryParse(option.index) ?? 0;
        context.read<GameCubit>().submitAnswer(slideId, [index], 10);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              if (option.text != null)
                Text(
                  option.text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
