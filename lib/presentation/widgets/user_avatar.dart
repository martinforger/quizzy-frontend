import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http') || (kIsWeb && avatarUrl!.startsWith('blob:'))) {
        imageProvider = NetworkImage(avatarUrl!);
      } else if (avatarUrl!.startsWith('assets/')) {
        imageProvider = AssetImage(avatarUrl!);
      } else if (!kIsWeb) {
        // Assume file path from gallery/camera on Mobile/Desktop
        try {
          File file = File(avatarUrl!);
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          }
        } catch (_) {}
      } else {
         // Fallback for Web if it's not http/blob/asset
         // Try to load as network image (relative path or other web-supported format)
         imageProvider = NetworkImage(avatarUrl!);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[700],
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Icon(Icons.person, color: Colors.white, size: radius)
            : null,
      ),
    );
  }
}
