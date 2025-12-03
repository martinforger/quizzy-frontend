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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: themes.map((theme) {
        final isSelected = selectedThemes.contains(theme.id);
        return ChoiceChip(
          label: Text(theme.name),
          selected: isSelected,
          onSelected: (_) => onToggled(theme.id),
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
  }
}
