import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/domain/library/entities/library_item.dart';

class LibraryItemTile extends StatelessWidget {
  const LibraryItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  final LibraryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section with Status Badge
              Stack(
                children: [
                  Container(
                    height: 140, // Taller image for better impact
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: item.coverImageId != null
                          ? DecorationImage(
                              image: NetworkImage(item.coverImageId!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.coverImageId == null
                        ? Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          )
                        : null,
                  ),
                  if (item.status != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.status!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title ?? 'Sin título',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                                    child: Text(
                                      (item.author?.name ?? 'U')[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.author?.name ?? 'Autor desconocido',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (onFavoriteToggle != null)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onFavoriteToggle,
                              borderRadius: BorderRadius.circular(50),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: isFavorite 
                                      ? Colors.amber 
                                      : Colors.grey[400],
                                  size: 32,
                                )
                                .animate(target: isFavorite ? 1 : 0)
                                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms)
                                .then()
                                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 200.ms),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200], height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                             color: Colors.grey[100],
                             borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildStat(
                            context, 
                            Icons.play_circle_fill_rounded, 
                            '${item.playCount ?? 0} plays',
                            theme.primaryColor
                          ),
                        ),
                        const Spacer(),
                        if (item.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.category!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildStat(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
