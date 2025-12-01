import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/game_cubit.dart';
import '../../bloc/game_state.dart';
import 'widgets/question_view.dart';
import 'widgets/feedback_overlay.dart';
import 'widgets/summary_view.dart';
import 'start_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GameCubit, GameState>(
        listener: (context, state) {
          if (state is GameError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GameInProgress) {
            return QuestionView(
              slide: state.currentSlide,
              currentScore: state.currentScore,
              questionIndex: state.currentQuestionIndex,
            );
          } else if (state is GameAnswerFeedback) {
            return FeedbackOverlay(state: state);
          } else if (state is GameFinished) {
            return SummaryView(summary: state.summary);
          } else if (state is GameInitial) {
            return const StartScreen();
          }

          // Default fallback
          return const Center(child: Text("Esperando para comenzar..."));
        },
      ),
    );
  }
}
