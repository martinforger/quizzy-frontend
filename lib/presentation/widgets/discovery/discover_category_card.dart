import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';

class DiscoverCategoryCard extends StatelessWidget {
  const DiscoverCategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  final Category category;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final start = _hexToColor(category.gradientStart);
    final end = _hexToColor(category.gradientEnd);
    final icon = _iconForCategory(category.name.isNotEmpty
        ? category.name
        : category.icon);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [start, end]),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _iconForCategory(String icon) {
    switch (icon.toLowerCase()) {
      case 'art':
        return Icons.palette_rounded;
      case 'biology':
        return Icons.biotech_rounded;
      case 'chemistry':
        return Icons.science_rounded;
      case 'computer science':
      case 'computers':
      case 'technology':
        return Icons.memory_rounded;
      case 'math':
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'language':
      case 'spanish':
      case 'english':
        return Icons.translate_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'art history':
      case 'history':
        return Icons.auto_stories_rounded;
      case 'geography':
        return Icons.map_rounded;
      case 'science':
        return Icons.biotech_rounded;
      default:
        return Icons.category;
    }
  }
}
