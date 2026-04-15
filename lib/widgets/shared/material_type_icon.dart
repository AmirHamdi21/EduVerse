import 'package:flutter/material.dart';

/// T011: Utility widget mapping backend `materialType` / `organizationType`
/// enum strings to distinct Flutter visual icons with contextual coloring.
///
/// Usage:
/// ```dart
/// MaterialTypeIcon(type: 'video', isDark: true)
/// MaterialTypeIcon(type: 'document', isDark: false, size: 28)
/// ```
class MaterialTypeIcon extends StatelessWidget {
  final String type;
  final bool isDark;
  final double size;

  const MaterialTypeIcon({
    super.key,
    required this.type,
    this.isDark = false,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(config.icon, color: config.color, size: size),
    );
  }

  _MaterialConfig _getConfig() {
    switch (type.toLowerCase()) {
      case 'video':
        return _MaterialConfig(
          icon: Icons.play_circle_outline_rounded,
          color: const Color(0xFFE53E3E),
        );
      case 'document':
      case 'slide':
        return _MaterialConfig(
          icon: Icons.description_outlined,
          color: const Color(0xFF3182CE),
        );
      case 'quiz':
        return _MaterialConfig(
          icon: Icons.quiz_outlined,
          color: const Color(0xFF805AD5),
        );
      case 'lecture':
        return _MaterialConfig(
          icon: Icons.school_outlined,
          color: const Color(0xFF2B6CB0),
        );
      case 'lab':
        return _MaterialConfig(
          icon: Icons.science_outlined,
          color: const Color(0xFF38A169),
        );
      case 'section':
        return _MaterialConfig(
          icon: Icons.groups_outlined,
          color: const Color(0xFFDD6B20),
        );
      case 'tutorial':
        return _MaterialConfig(
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF319795),
        );
      case 'link':
        return _MaterialConfig(
          icon: Icons.link_rounded,
          color: const Color(0xFF667EEA),
        );
      default:
        return _MaterialConfig(
          icon: Icons.insert_drive_file_outlined,
          color: const Color(0xFF718096),
        );
    }
  }
}

class _MaterialConfig {
  final IconData icon;
  final Color color;

  const _MaterialConfig({required this.icon, required this.color});
}
