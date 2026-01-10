import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/multiplayer-game/entities/player_entity.dart';
import '../../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../../bloc/multiplayer/multiplayer_game_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'host_question_screen.dart';
import 'host_game_end_screen.dart';

/// Pantalla de resultados para el HOST.
///
/// Muestra la respuesta correcta, distribución de respuestas, y leaderboard.
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
        }
      },
      child: BlocBuilder<MultiplayerGameCubit, MultiplayerGameState>(
        builder: (context, state) {
          if (state is! HostResultsState) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = state.results;
          final progress = results.progress;

          return Scaffold(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary, // Match Solo Game
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Resultados',
                          style: TextStyle(
                            fontFamily: 'Onest',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                          child: Text(
                            '${progress.current} / ${progress.total}',
                            style: const TextStyle(
                              fontFamily: 'Onest',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Answer Distribution
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribución de Respuestas',
                          style: TextStyle(
                            fontFamily: 'Onest',
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnswerDistribution(
                          distribution: results.stats.distribution,
                          correctIds: results.correctAnswerId,
                          totalAnswers: results.stats.totalAnswers,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 16),

                  // Leaderboard Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Top 5 Jugadores',
                        style: TextStyle(
                          fontFamily: 'Onest',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Leaderboard
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.leaderboard.length,
                      itemBuilder: (context, index) {
                        final player = results.leaderboard[index];
                        return _LeaderboardTile(player: player, index: index)
                            .animate()
                            .slideX(
                              begin: 1,
                              end: 0,
                              delay: Duration(milliseconds: 100 * index),
                              duration: 400.ms,
                            )
                            .fadeIn();
                      },
                    ),
                  ),

                  // Next Button
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
                          backgroundColor: progress.isLastSlide == true
                              ? const Color(0xFF00D9A5)
                              : const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          progress.isLastSlide == true
                              ? 'Ver Podio Final'
                              : 'Siguiente Pregunta',
                          style: const TextStyle(
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
      ),
    );
  }
}

class _AnswerDistribution extends StatelessWidget {
  final Map<String, int> distribution;
  final List<String> correctIds;
  final int totalAnswers;

  const _AnswerDistribution({
    required this.distribution,
    required this.correctIds,
    required this.totalAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.blue, Colors.amber, Colors.green];

    final sortedKeys = distribution.keys.toList()..sort();

    return Column(
      children: sortedKeys.asMap().entries.map((entry) {
        final index = entry.key;
        final key = entry.value;
        final count = distribution[key] ?? 0;
        final percentage = totalAnswers > 0 ? count / totalAnswers : 0.0;
        final isCorrect = correctIds.contains(key);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(8),
                  border: isCorrect
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: Center(
                  child: isCorrect
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final PlayerEntity player;
  final int index;

  const _LeaderboardTile({required this.player, required this.index});

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final isTopThree = index < 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isTopThree
            ? LinearGradient(
                colors: [
                  _getMedalColor(index).withValues(alpha: 0.3),
                  _getMedalColor(index).withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isTopThree ? null : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              isTopThree ? medals[index] : '#${player.rank}',
              style: TextStyle(
                fontFamily: 'Onest',
                fontSize: isTopThree ? 24 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.nickname,
                  style: const TextStyle(
                    fontFamily: 'Onest',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (player.previousRank != player.rank)
                  Row(
                    children: [
                      Icon(
                        player.rank < player.previousRank
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: player.rank < player.previousRank
                            ? Colors.green
                            : Colors.red,
                        size: 14,
                      ),
                      Text(
                        '${(player.previousRank - player.rank).abs()} posiciones',
                        style: TextStyle(
                          fontFamily: 'Onest',
                          color: player.rank < player.previousRank
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Score
          Text(
            '${player.score} pts',
            style: const TextStyle(
              fontFamily: 'Onest',
              color: Color(0xFF00D9A5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}
