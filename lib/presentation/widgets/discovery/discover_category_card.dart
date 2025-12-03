import 'package:flutter/material.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';

class DiscoverCategoryCard extends StatelessWidget {
  const DiscoverCategoryCard({super.key, required this.category});

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
}
