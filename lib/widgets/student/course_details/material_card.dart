import 'package:flutter/material.dart';

import '../../../models/materials/course_material_model.dart';

class MaterialCard extends StatelessWidget {
  final CourseMaterialModel material;
  final bool isDark;
  final VoidCallback? onTap;

  const MaterialCard({
    super.key,
    required this.material,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF101828);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF667085);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(type: material.materialType, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (material.description != null &&
                          material.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            material.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _StatChip(
                            label: 'Views ${material.viewCount ?? 0}',
                            icon: Icons.visibility_outlined,
                            isDark: isDark,
                          ),
                          _StatChip(
                            label: 'Downloads ${material.downloadCount ?? 0}',
                            icon: Icons.download_outlined,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (material.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      material.thumbnailUrl!,
                      width: 72,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: subtitleColor,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final bool isDark;

  const _TypeBadge({required this.type, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final upper = type.toUpperCase();
    final color = _resolveColor(upper);

    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          upper,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _resolveColor(String type) {
    switch (type) {
      case 'VIDEO':
        return const Color(0xFFE11D48);
      case 'DOCUMENT':
        return const Color(0xFF0369A1);
      case 'LINK':
        return const Color(0xFF7C3AED);
      case 'TEXT':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF475569);
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
