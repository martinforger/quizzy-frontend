import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/presentation/bloc/game_cubit.dart';
import 'package:quizzy/presentation/screens/game/game_screen.dart';

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

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  Map<String, Map<String, dynamic>>? _savedSessions;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSession() async {
    final sessions = await widget.manageLocalAttemptUseCase.getAllGameSessions();
    if (mounted) {
      setState(() {
        _savedSessions = sessions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                'Biblioteca',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
              centerTitle: false,
              expandedHeight: 120.0,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                controller: _tabController,
                indicatorWeight: 4,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Explorar"),
                  Tab(text: "Recientes"),
                  Tab(text: "Favoritos"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Explorar (Existing content enhanced)
            _buildExploreTab(),
            // Tab 2: Recientes (Placeholder UI)
            _buildEmptyState(
              icon: Icons.history_edu,
              title: "Sin actividad reciente",
              message: "Tus juegos jugados recientemente aparecerán aquí.",
            ),
            // Tab 3: Favoritos (Placeholder UI)
            _buildEmptyState(
              icon: Icons.favorite_border_rounded,
              title: "Aún no tienes favoritos",
              message: "Guarda los kahoots que más te gusten para encontrarlos rápido.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            "Recomendado para ti",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _LibraryGameCard(
          title: "Mock Kahoot Demo",
          description: "Prueba la funcionalidad del juego con este quiz.",
          imageUrl:
              "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?auto=format&fit=crop&q=80&w=1000",
          quizId: "kahoot-demo-id",
          questionsCount: 10,
          category: "General",
          startAttemptUseCase: widget.startAttemptUseCase,
          submitAnswerUseCase: widget.submitAnswerUseCase,
          getSummaryUseCase: widget.getSummaryUseCase,
          manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
          getAttemptStateUseCase: widget.getAttemptStateUseCase,
          savedSession: _savedSessions?['kahoot-demo-id'],
          onGameStarted: _loadSession,
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
        const SizedBox(height: 16),
        _LibraryGameCard(
          title: "Patrones de Diseño",
          description: "Pon a prueba tus conocimientos sobre patrones.",
          imageUrl:
              "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=1000",
          quizId: "quiz-design-patterns",
          questionsCount: 15,
          category: "Software",
          startAttemptUseCase: widget.startAttemptUseCase,
          submitAnswerUseCase: widget.submitAnswerUseCase,
          getSummaryUseCase: widget.getSummaryUseCase,
          manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
          getAttemptStateUseCase: widget.getAttemptStateUseCase,
          savedSession: _savedSessions?['quiz-design-patterns'],
          onGameStarted: _loadSession,
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          hintText: "Buscar kahoots...",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

class _LibraryGameCard extends StatefulWidget {
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
    this.questionsCount = 10,
    this.category = "Unknown",
    this.savedSession,
    this.onGameStarted,
    this.isFavorite = false,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String quizId;
  final int questionsCount;
  final String category;
  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;
  final Map<String, dynamic>? savedSession;
  final VoidCallback? onGameStarted;
  final bool isFavorite;

  @override
  State<_LibraryGameCard> createState() => _LibraryGameCardState();
}

class _LibraryGameCardState extends State<_LibraryGameCard>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _favController;
  late Animation<double> _favScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _favScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _favController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      _favController.forward().then((_) => _favController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasProgress = false;
    double progressValue = 0.0;

    if (widget.savedSession != null &&
        widget.savedSession!['quizId'] == widget.quizId) {
      final current =
          widget.savedSession!['currentQuestionIndex'] as int? ?? 0;
      final total = widget.savedSession!['totalQuestions'] as int? ?? 1;
      if (total > 0) {
        hasProgress = true;
        progressValue = (current / total).clamp(0.0, 1.0);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToGame(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Badge & Favorite
              Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${widget.questionsCount} Preguntas",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: ScaleTransition(
                        scale: _favScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.red : Colors.grey[700],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Progress Bar
              if (hasProgress)
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey[100],
                  color:
                      progressValue >= 1.0
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                  minHeight: 4,
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.more_horiz,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToGame(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor:
                              hasProgress
                                  ? (progressValue >= 1.0
                                      ? Colors.green
                                      : Theme.of(context).primaryColor)
                                  : Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          hasProgress
                              ? (progressValue >= 1.0
                                  ? "Ver Resultados"
                                  : "Continuar")
                              : "Jugar",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Future<void> _navigateToGame(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create:
                  (_) => GameCubit(
                    startAttemptUseCase: widget.startAttemptUseCase,
                    submitAnswerUseCase: widget.submitAnswerUseCase,
                    getSummaryUseCase: widget.getSummaryUseCase,
                    manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
                    getAttemptStateUseCase: widget.getAttemptStateUseCase,
                  ),
              child: GameScreen(quizId: widget.quizId),
            ),
      ),
    );
    // Refresh session info when returning
    widget.onGameStarted?.call();
  }
}
