import 'package:flutter/material.dart';

import '../../../models/core/course_structure_model.dart';
import 'course_management_colors.dart';

class StructureItemCard extends StatelessWidget {
  final CourseStructureModel item;
  final int materialCount;
  final bool isDark;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StructureItemCard({
    super.key,
    required this.item,
    required this.materialCount,
    required this.isDark,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CMColors.borderColor(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CMColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${item.weekNumber}',
                style: const TextStyle(
                  color: CMColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CMColors.textSub(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: CMColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$materialCount material${materialCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: CMColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _ActionIcon(
                icon: Icons.keyboard_arrow_up_rounded,
                color: CMColors.primary,
                onTap: onMoveUp,
              ),
              _ActionIcon(
                icon: Icons.keyboard_arrow_down_rounded,
                color: CMColors.primary,
                onTap: onMoveDown,
              ),
              _ActionIcon(
                icon: Icons.edit_outlined,
                color: CMColors.teal,
                onTap: onEdit,
              ),
              _ActionIcon(
                icon: Icons.delete_outline_rounded,
                color: CMColors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionIcon({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(child: Icon(icon, size: 18, color: color)),
      ),
    );
  }
}
