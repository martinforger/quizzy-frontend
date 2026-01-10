import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/presentation/bloc/game_cubit.dart';
import 'package:quizzy/presentation/screens/game/game_screen.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/screens/multiplayer/host/host_lobby_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.manageLocalAttemptUseCase,
    required this.getAttemptStateUseCase,
  });

  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Map<String, Map<String, dynamic>>? _savedSessions;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  // Reload session when coming back to screen
  void _loadSession() async {
    final sessions = await widget.manageLocalAttemptUseCase
        .getAllGameSessions();
    if (mounted) {
      setState(() {
        _savedSessions = sessions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is HostLobbyState) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const HostLobbyScreen()));
        } else if (state is MultiplayerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LibraryGameCard(
              title: "Mock Kahoot Demo",
              description:
                  "Prueba la funcionalidad del juego con este quiz de demostración.",
              imageUrl:
                  "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?auto=format&fit=crop&q=80&w=1000",
              quizId: "kahoot-demo-id",
              startAttemptUseCase: widget.startAttemptUseCase,
              submitAnswerUseCase: widget.submitAnswerUseCase,
              getSummaryUseCase: widget.getSummaryUseCase,
              manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
              getAttemptStateUseCase: widget.getAttemptStateUseCase,
              savedSession: _savedSessions?['kahoot-demo-id'],
              onGameStarted: _loadSession,
            ),
            _LibraryGameCard(
              title: "Patrones de Diseño",
              description:
                  "Pon a prueba tus conocimientos sobre patrones de diseño de software.",
              imageUrl:
                  "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=1000",
              quizId: "quiz-design-patterns",
              startAttemptUseCase: widget.startAttemptUseCase,
              submitAnswerUseCase: widget.submitAnswerUseCase,
              getSummaryUseCase: widget.getSummaryUseCase,
              manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
              getAttemptStateUseCase: widget.getAttemptStateUseCase,
              savedSession: _savedSessions?['quiz-design-patterns'],
              onGameStarted: _loadSession,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryGameCard extends StatelessWidget {
  const _LibraryGameCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.quizId,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.manageLocalAttemptUseCase,
    required this.getAttemptStateUseCase,
    this.savedSession,
    this.onGameStarted,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String quizId;
  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;
  final Map<String, dynamic>? savedSession;
  final VoidCallback? onGameStarted;

  @override
  Widget build(BuildContext context) {
    bool hasProgress = false;
    double progressValue = 0.0;

    if (savedSession != null && savedSession!['quizId'] == quizId) {
      final current = savedSession!['currentQuestionIndex'] as int? ?? 0;
      final total = savedSession!['totalQuestions'] as int? ?? 1;
      if (total > 0) {
        hasProgress = true;
        progressValue = (current / total).clamp(0.0, 1.0);
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => GameCubit(
                  startAttemptUseCase: startAttemptUseCase,
                  submitAnswerUseCase: submitAnswerUseCase,
                  getSummaryUseCase: getSummaryUseCase,
                  manageLocalAttemptUseCase: manageLocalAttemptUseCase,
                  getAttemptStateUseCase: getAttemptStateUseCase,
                ),
                child: GameScreen(quizId: quizId),
              ),
            ),
          );
          onGameStarted?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey),
              ),
            ),
            if (hasProgress)
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[300],
                color: progressValue >= 1.0
                    ? Colors.green
                    : Theme.of(context).primaryColor,
                minHeight: 6,
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (_) => GameCubit(
                                  startAttemptUseCase: startAttemptUseCase,
                                  submitAnswerUseCase: submitAnswerUseCase,
                                  getSummaryUseCase: getSummaryUseCase,
                                  manageLocalAttemptUseCase:
                                      manageLocalAttemptUseCase,
                                  getAttemptStateUseCase:
                                      getAttemptStateUseCase,
                                ),
                                child: GameScreen(quizId: quizId),
                              ),
                            ),
                          );
                          onGameStarted?.call();
                        },
                        icon: Icon(
                          hasProgress
                              ? Icons.play_arrow
                              : Icons.play_arrow_outlined,
                        ),
                        label: Text(hasProgress ? "Continuar" : "Jugar Solo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      // Host Button
                      FilledButton.icon(
                        onPressed: () {
                          // TODO: Get real JWT
                          const dummyJwt = "host-jwt-123";
                          context
                              .read<MultiplayerGameCubit>()
                              .createSessionAsHost(quizId, dummyJwt);
                        },
                        icon: const Icon(Icons.cast_connected),
                        label: const Text("Host Live"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (hasProgress && progressValue >= 1.0)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Completado",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
