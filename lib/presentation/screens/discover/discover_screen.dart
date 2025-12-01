import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/entities/quiz_summary.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:quizzy/presentation/widgets/quizzy_logo.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, required this.controller});

  final DiscoveryController controller;

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<QuizTheme>>(
                    future: _themesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 36,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      if (snapshot.hasError) {
                        return _InlineError(
                          message: 'No pudimos cargar los temas',
                          onRetry: () => setState(() => _themesFuture = widget.controller.fetchThemes()),
                        );
                      }
                      final themes = snapshot.data ?? [];
                      if (themes.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: themes.map((theme) {
                          final isSelected = _selectedThemes.contains(theme.id);
                          return ChoiceChip(
                            label: Text(theme.name),
                            selected: isSelected,
                            onSelected: (_) => _onThemeToggled(theme.id),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                            backgroundColor: const Color(0xFF2A272D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }).toList(),
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
                    _SectionHeader(title: 'Categories', actionText: 'See all'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: FutureBuilder<List<Category>>(
                        future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _InlineError(
                        message: 'No pudimos cargar las categorías',
                        onRetry: () => setState(() => _categoriesFuture = widget.controller.fetchCategories()),
                      );
                    }
                    final categories = snapshot.data ?? [];
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _CategoryCard(category: categories[index]),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemCount: categories.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final hasQuery = _searchController.text.trim().isNotEmpty;
                        final isDefaultView = !hasQuery && _selectedThemes.isEmpty;
                        final quizzesToShow = isDefaultView ? _quizzes : _filteredQuizzes;
                        final isLoading = isDefaultView ? _isLoadingQuizzes : _isSearching;
                        final title = isDefaultView ? 'Featured Quizzes' : 'Results';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              title: title,
                              actionText: isDefaultView ? 'See all' : '',
                            ),
                            const SizedBox(height: 12),
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: _InlineError(
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
                                child: Center(child: Text('No quizzes found')),
                              )
                            else
                              Column(
                                children: quizzesToShow
                                    .map((quiz) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: _FeaturedCard(quiz: quiz),
                                        ))
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
    );
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
      final result = await widget.controller.searchQuizzes(
        query: trimmed.isEmpty ? null : trimmed,
        themes: _selectedThemes.toList(),
        page: 1,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _filteredQuizzes = result.items;
        _isSearching = false;
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
            Text('Discover', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Explora y encuentra nuevos quizzes', style: TextStyle(color: Colors.white70)),
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
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search for a quiz...',
        filled: true,
        fillColor: const Color(0xFF2A272D),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionText});

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(
          actionText,
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final start = _hexToColor(category.gradientStart);
    final end = _hexToColor(category.gradientEnd);
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [start, end]),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconForCategory(category.icon), color: Colors.white.withValues(alpha: 0.9), size: 26),
          const Spacer(),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.quiz});

  final QuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          _Thumb(quiz: quiz),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.tag.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.author,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.quiz});

  final QuizSummary quiz;

  @override
  Widget build(BuildContext context) {
    final color = quiz.tag.toLowerCase().contains('science')
        ? Colors.deepPurple
        : quiz.tag.toLowerCase().contains('history')
            ? Colors.orangeAccent
            : Colors.teal;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        image: quiz.thumbnailUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(quiz.thumbnailUrl),
                fit: BoxFit.cover,
                opacity: 0.9,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
      ),
      child: Center(
        child: Icon(Icons.play_arrow_rounded, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

IconData _iconForCategory(String icon) {
  switch (icon.toLowerCase()) {
    case 'science':
      return Icons.biotech_rounded;
    case 'history':
      return Icons.auto_stories_rounded;
    case 'geography':
      return Icons.map_rounded;
    default:
      return Icons.category;
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}
