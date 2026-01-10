import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizzy/injection_container.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/widgets/discovery/discover_category_card.dart';
import 'package:quizzy/presentation/widgets/discovery/discover_featured_card.dart';
import 'package:quizzy/presentation/widgets/discovery/discover_inline_error.dart';
import 'package:quizzy/presentation/widgets/discovery/discover_search_bar.dart';
import 'package:quizzy/presentation/widgets/discovery/discover_section_header.dart';
import 'package:quizzy/presentation/widgets/discovery/theme_filter_chips.dart';
import 'package:quizzy/presentation/widgets/quizzy_logo.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/presentation/bloc/game_cubit.dart';
import 'package:quizzy/presentation/screens/game/game_screen.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_state.dart';
import 'package:quizzy/presentation/screens/multiplayer/host/host_lobby_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.controller,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.manageLocalAttemptUseCase,
    required this.getAttemptStateUseCase,
  });

  final DiscoveryController controller;
  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late Future<List<Category>> _categoriesFuture;
  late Future<List<QuizTheme>> _themesFuture;
  List<QuizSummary> _quizzes = [];
  List<QuizSummary> _filteredQuizzes = [];
  final Set<String> _selectedThemes = {};
  bool _isLoadingQuizzes = true;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = widget.controller.fetchCategories();
    _themesFuture = widget.controller.fetchThemes();
    _loadFeaturedQuizzes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DiscoverSearchBar(
                      controller: _searchController,
                      onChanged: _onQueryChanged,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<QuizTheme>>(
                      future: _themesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 36,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return DiscoverInlineError(
                            message: 'No pudimos cargar los temas',
                            onRetry: () {
                              setState(() {
                                _themesFuture = widget.controller.fetchThemes();
                              });
                            },
                          );
                        }
                        final themes = snapshot.data ?? [];
                        return ThemeFilterChips(
                          themes: themes,
                          selectedThemes: _selectedThemes,
                          onToggled: _onThemeToggled,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async {
                    setState(() {
                      _categoriesFuture = widget.controller.fetchCategories();
                      _themesFuture = widget.controller.fetchThemes();
                      _errorMessage = null;
                    });
                    await Future.wait([
                      _categoriesFuture,
                      _themesFuture,
                      _loadFeaturedQuizzes(),
                    ]);
                    await _refreshSearchIfNeeded();
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      100 + MediaQuery.of(context).padding.bottom,
                    ),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      const DiscoverSectionHeader(
                        title: 'Categories',
                        actionText: 'See all',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: FutureBuilder<List<Category>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return DiscoverInlineError(
                                message: 'No pudimos cargar las categorias',
                                onRetry: () {
                                  setState(() {
                                    _categoriesFuture = widget.controller
                                        .fetchCategories();
                                  });
                                },
                              );
                            }
                            final categories = snapshot.data ?? [];
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) =>
                                  DiscoverCategoryCard(
                                    category: categories[index],
                                  ),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemCount: categories.length,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Builder(
                        builder: (context) {
                          final hasQuery = _searchController.text
                              .trim()
                              .isNotEmpty;
                          final isDefaultView =
                              !hasQuery && _selectedThemes.isEmpty;
                          final quizzesToShow = isDefaultView
                              ? _quizzes
                              : _filteredQuizzes;
                          final isLoading = isDefaultView
                              ? _isLoadingQuizzes
                              : _isSearching;
                          final title = isDefaultView
                              ? 'Featured Quizzes'
                              : 'Results';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DiscoverSectionHeader(
                                title: title,
                                actionText: isDefaultView ? 'See all' : '',
                              ),
                              const SizedBox(height: 12),
                              if (isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: DiscoverInlineError(
                                    message: _errorMessage!,
                                    onRetry: () {
                                      if (isDefaultView) {
                                        _loadFeaturedQuizzes();
                                      } else {
                                        _runSearch();
                                      }
                                    },
                                  ),
                                )
                              else if (quizzesToShow.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text('No quizzes found'),
                                  ),
                                )
                              else
                                Column(
                                  children: quizzesToShow
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: DiscoverFeaturedCard(
                                            quiz: entry.value,
                                            index: entry.key + 1,
                                            onTap: () =>
                                                _navigateToGame(entry.value.id),
                                            onFavoriteToggle: () =>
                                                _toggleFavorite(entry.value),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(QuizSummary quiz) async {
    // Optimistic update
    setState(() {
      final updatedQuiz = quiz.copyWith(isFavorite: !quiz.isFavorite);

      // Update in _quizzes
      final index = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (index != -1) {
        _quizzes[index] = updatedQuiz;
      }

      // Update in _filteredQuizzes
      final filteredIndex = _filteredQuizzes.indexWhere((q) => q.id == quiz.id);
      if (filteredIndex != -1) {
        _filteredQuizzes[filteredIndex] = updatedQuiz;
      }
    });

    try {
      await widget.controller.toggleFavorite(quiz.id, quiz.isFavorite);
    } catch (e) {
      // Revert if failed
      if (!mounted) return;
      setState(() {
        // Revert in _quizzes
        final index = _quizzes.indexWhere((q) => q.id == quiz.id);
        if (index != -1) {
          _quizzes[index] = quiz; // quiz has original state
        }

        // Revert in _filteredQuizzes
        final filteredIndex = _filteredQuizzes.indexWhere(
          (q) => q.id == quiz.id,
        );
        if (filteredIndex != -1) {
          _filteredQuizzes[filteredIndex] = quiz;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
      });
    }
  }

  Future<void> _loadFeaturedQuizzes() async {
    setState(() {
      _isLoadingQuizzes = true;
      _errorMessage = null;
    });
    try {
      final quizzes = await widget.controller.fetchFeaturedQuizzes();
      if (!mounted) return;
      setState(() {
        _quizzes = quizzes;
        if (_selectedThemes.isEmpty && _searchController.text.trim().isEmpty) {
          _filteredQuizzes = quizzes;
        }
        _isLoadingQuizzes = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoadingQuizzes = false;
        _errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingQuizzes = false;
        _errorMessage = 'No pudimos cargar los destacados';
      });
    }
  }

  Future<void> _runSearch({String? query}) async {
    final trimmed = query?.trim() ?? _searchController.text.trim();
    final hasFilters = _selectedThemes.isNotEmpty;
    if (trimmed.isEmpty && !hasFilters) {
      setState(() {
        _filteredQuizzes = List.of(_quizzes);
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.controller.searchQuizSummaries(
        query: trimmed.isEmpty ? null : trimmed,
        themes: _selectedThemes.toList(),
        page: 1,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _filteredQuizzes = result;
        _isSearching = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = 'No se pudieron cargar los resultados';
      });
    }
  }

  Future<void> _refreshSearchIfNeeded() {
    final trimmed = _searchController.text.trim();
    final hasFilters = _selectedThemes.isNotEmpty;
    if (trimmed.isEmpty && !hasFilters) return Future.value();
    return _runSearch(query: trimmed);
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _runSearch(query: query);
    });
  }

  void _onThemeToggled(String themeId) {
    setState(() {
      if (_selectedThemes.contains(themeId)) {
        _selectedThemes.remove(themeId);
      } else {
        _selectedThemes.add(themeId);
      }
    });
    _runSearch();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              'Explora y encuentra nuevos quizzes',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: const QuizzyLogo(size: 38),
        ),
      ],
    );
  }

  void _navigateToGame(String quizId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Game Mode',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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
  }
}
