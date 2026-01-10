import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/presentation/bloc/game_cubit.dart';
import 'package:quizzy/presentation/bloc/library/library_cubit.dart';
import 'package:quizzy/presentation/screens/game/game_screen.dart';
import 'package:quizzy/presentation/screens/my_library/widgets/library_item_tile.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/screens/multiplayer/host/host_lobby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizzy/injection_container.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.manageLocalAttemptUseCase,
    required this.getAttemptStateUseCase,
    required this.libraryCubit,
  });

  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;
  final LibraryCubit libraryCubit;

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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadSession();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _loadDataForTab(_tabController.index);
    }
  }

  void _loadDataForTab(int index) {
    switch (index) {
      case 1:
        widget.libraryCubit.loadMyCreations();
        break;
      case 2:
        widget.libraryCubit.loadFavorites();
        break;
      case 3:
        widget.libraryCubit.loadInProgress();
        break;
      case 4:
        widget.libraryCubit.loadCompleted();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      // backgroundColor uses theme default (AppColors.surface)
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                'Biblioteca',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              centerTitle: false,
              expandedHeight: 120.0,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorWeight: 4,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Explorar"),
                  Tab(text: "Creaciones"),
                  Tab(text: "Favoritos"),
                  Tab(text: "En Progreso"),
                  Tab(text: "Completados"),
                ],
              ),
            ),
          ];
        },
        body: BlocBuilder<LibraryCubit, LibraryState>(
          bloc: widget.libraryCubit,
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildExploreTab(),
                _buildLibraryList(
                  state,
                  (s) => s.creations,
                  allowFavToggle: false,
                ),
                _buildLibraryList(
                  state,
                  (s) => s.favorites,
                  allowFavToggle: true,
                  isFavList: true,
                ),
                _buildLibraryList(state, (s) => s.inProgress),
                _buildLibraryList(state, (s) => s.completed),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLibraryList(
    LibraryState state,
    List Function(LibraryState) selector, {
    bool allowFavToggle = false,
    bool isFavList = false,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }
    return _buildList(
      selector(state),
      allowFavToggle: allowFavToggle,
      isFavList: isFavList,
    );
  }

  Widget _buildList(
    List items, {
    bool allowFavToggle = false,
    bool isFavList = false,
  }) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay elementos'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return LibraryItemTile(
          item: item,
          isFavorite: isFavList,
          onFavoriteToggle: allowFavToggle
              ? () {
                  widget.libraryCubit.toggleFavorite(item.id, isFavList);
                }
              : null,
          onTap: () {
            _showGameOptions(context, item.id);
          },
        );
      },
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
              // Color implied by theme (white in dark mode)
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.white54),
          border: InputBorder.none,
          hintText: "Buscar kahoots...",
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  void _showGameOptions(BuildContext context, String quizId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocListener<MultiplayerGameCubit, MultiplayerGameState>(
          listener: (context, state) {
            if (state is HostLobbyState) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HostLobbyScreen()),
              );
            } else if (state is MultiplayerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Game Mode',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.blue,
                  ),
                  title: const Text('Play Solo'),
                  subtitle: const Text('Practice on your own'),
                  onTap: () {
                    Navigator.pop(context);
                    _startSoloGame(quizId);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.people,
                    size: 32,
                    color: Colors.purple,
                  ),
                  title: const Text('Host Party'),
                  subtitle: const Text('Play with friends live'),
                  onTap: () {
                    Navigator.pop(context);

                    final prefs = getIt<SharedPreferences>();
                    final token = prefs.getString('accessToken');

                    if (token == null || token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Debes iniciar sesión para ser Anfitrión",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    context.read<MultiplayerGameCubit>().createSessionAsHost(
                      quizId,
                      token,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startSoloGame(String quizId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => GameCubit(
            startAttemptUseCase: widget.startAttemptUseCase,
            submitAnswerUseCase: widget.submitAnswerUseCase,
            getSummaryUseCase: widget.getSummaryUseCase,
            manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
            getAttemptStateUseCase: widget.getAttemptStateUseCase,
          ),
          child: GameScreen(quizId: quizId),
        ),
      ),
    );
    // Refresh session info when returning
    _loadSession();
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
    _favScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _favController, curve: Curves.easeInOut));
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
      final current = widget.savedSession!['currentQuestionIndex'] as int? ?? 0;
      final total = widget.savedSession!['totalQuestions'] as int? ?? 1;
      if (total > 0) {
        hasProgress = true;
        progressValue = (current / total).clamp(0.0, 1.0);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white10,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.white24,
                          ),
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
                        color: Colors.black.withValues(alpha: 0.7),
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
                            color: Theme.of(
                              context,
                            ).cardColor.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.red : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
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
              // Progress Bar
              if (hasProgress)
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white10,
                  color: progressValue >= 1.0
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
                            color: Colors.white54,
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
                          backgroundColor: hasProgress
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
        builder: (context) => BlocProvider(
          create: (_) => GameCubit(
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
