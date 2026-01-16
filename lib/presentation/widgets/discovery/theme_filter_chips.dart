import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/quiz_theme.dart';

class ThemeFilterChips extends StatelessWidget {
  const ThemeFilterChips({
    super.key,
    required this.themes,
    required this.selectedThemes,
    required this.onToggled,
  });

  final List<QuizTheme> themes;
  final Set<String> selectedThemes;
  final ValueChanged<String> onToggled;

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: themes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final theme = themes[index];
          final isSelected = selectedThemes.contains(theme.id);
          return ChoiceChip(
            label: Text(theme.name),
            selected: isSelected,
            onSelected: (_) => onToggled(theme.id),
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
            backgroundColor: const Color(0xFF2E2A32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.12),
            ),
          );
        },
      ),
    );
  }
}
