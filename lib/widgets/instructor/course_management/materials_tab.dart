import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';
import 'course_management_colors.dart';

/// Redesigned materials tab with modern file cards
class MaterialsTab extends StatelessWidget {
  final List<MaterialModel> materials;
  final bool isDark;
  final AppLocalizations l10n;

  const MaterialsTab({
    super.key,
    required this.materials,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return _MaterialCard(
          material: materials[index],
          isDark: isDark,
          index: index,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CMColors.success.withValues(alpha: 0.1),
                  CMColors.success.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: CMColors.success.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No materials yet',
            style: TextStyle(
              color: CMColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload files for your students',
            style: TextStyle(
              color: CMColors.textSub(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final bool isDark;
  final int index;

  const _MaterialCard({
    required this.material,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = _getTypeConfig(material.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CMColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CMColors.borderColor(isDark),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // File type icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: typeConfig.gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: typeConfig.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    typeConfig.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: TextStyle(
                          color: CMColors.text(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeConfig.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              material.type.toUpperCase(),
                              style: TextStyle(
                                color: typeConfig.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (material.fileSize.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              material.fileSize,
                              style: TextStyle(
                                color: CMColors.textMutedColor(isDark),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(
                      icon: Icons.edit_outlined,
                      color: CMColors.primary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),
                    _buildIconButton(
                      icon: Icons.delete_outline_rounded,
                      color: CMColors.error,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return _TypeConfig(
          Icons.picture_as_pdf_rounded,
          CMColors.error,
          const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF87171)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 'video':
        return _TypeConfig(
          Icons.play_circle_rounded,
          CMColors.primary,
          CMColors.primaryGradient,
        );
      case 'doc':
      case 'docx':
        return _TypeConfig(
          Icons.description_rounded,
          CMColors.accent,
          CMColors.accentGradient,
        );
      default:
        return _TypeConfig(
          Icons.insert_drive_file_rounded,
          CMColors.teal,
          CMColors.successGradient,
        );
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  _TypeConfig(this.icon, this.color, this.gradient);
}
