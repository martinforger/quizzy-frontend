import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/game_cubit.dart';
import '../../bloc/game_state.dart';
import 'widgets/question_view.dart';
import 'widgets/feedback_overlay.dart';
import 'widgets/summary_view.dart';
import 'start_screen.dart';

class GameScreen extends StatelessWidget {
  final String quizId;

  const GameScreen({super.key, this.quizId = "kahoot-demo-id"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              Navigator.of(context).pop(); // Or show confirmation dialog
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
            return StartScreen(quizId: quizId);
          }

          // Default fallback
          return const Center(child: Text("Esperando para comenzar..."));
        },
      ),
    );
  }
}
