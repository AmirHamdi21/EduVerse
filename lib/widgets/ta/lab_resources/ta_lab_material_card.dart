import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

enum TAMaterialType { pdf, video, document, code, image, link }

enum TAMaterialAITag { lowClarity, suggestUpdate, outdated, popular, verified }

class TALabMaterialItem {
  final String id;
  final String name;
  final TAMaterialType type;
  final int views;
  final int downloads;
  final int completionPercent;
  final List<TAMaterialAITag> aiTags;
  final DateTime uploadedAt;
  final String uploadedBy;
  final int fileSize; // in KB

  const TALabMaterialItem({
    required this.id,
    required this.name,
    required this.type,
    required this.views,
    required this.downloads,
    required this.completionPercent,
    this.aiTags = const [],
    required this.uploadedAt,
    required this.uploadedBy,
    this.fileSize = 0,
  });
}

class TALabMaterialCard extends StatelessWidget {
  final TALabMaterialItem material;
  final bool isDark;
  final VoidCallback? onView;
  final VoidCallback? onDownload;
  final VoidCallback? onReplace;
  final VoidCallback? onDelete;

  const TALabMaterialCard({
    super.key,
    required this.material,
    required this.isDark,
    this.onView,
    this.onDownload,
    this.onReplace,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasWarningTag()
              ? TAColors.warning.withValues(alpha: 0.4)
              : TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File type icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Material details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.visibility_outlined,
                          value: '${material.views}',
                          label: l10n.taLabResViews,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          icon: Icons.download_outlined,
                          value: '${material.downloads}',
                          label: l10n.taLabResDownloads,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          icon: Icons.check_circle_outline,
                          value: '${material.completionPercent}%',
                          label: l10n.taLabResComplete,
                          color: _getCompletionColor(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // AI Tags
          if (material.aiTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: material.aiTags.map((tag) => _buildAITag(tag, l10n)).toList(),
            ),
          ],
          const SizedBox(height: 14),
          // Actions row
          Row(
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: l10n.taLabResView,
                onTap: onView,
                color: TAColors.primary,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.download_rounded,
                label: l10n.taLabResDownload,
                onTap: onDownload,
                color: TAColors.success,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.swap_horiz_rounded,
                label: l10n.taLabResReplace,
                onTap: onReplace,
                color: TAColors.warning,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: l10n.delete,
                onTap: onDelete,
                color: TAColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: color ?? TAColors.textTertiaryColor(isDark),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? TAColors.textSecondaryColor(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAITag(TAMaterialAITag tag, AppLocalizations l10n) {
    final Color color;
    final IconData icon;
    final String label;

    switch (tag) {
      case TAMaterialAITag.lowClarity:
        color = TAColors.warning;
        icon = Icons.auto_awesome;
        label = l10n.taLabResAILowClarity;
        break;
      case TAMaterialAITag.suggestUpdate:
        color = TAColors.info;
        icon = Icons.auto_awesome;
        label = l10n.taLabResAISuggestUpdate;
        break;
      case TAMaterialAITag.outdated:
        color = TAColors.error;
        icon = Icons.auto_awesome;
        label = l10n.taLabResAIOutdated;
        break;
      case TAMaterialAITag.popular:
        color = TAColors.success;
        icon = Icons.trending_up_rounded;
        label = 'Popular';
        break;
      case TAMaterialAITag.verified:
        color = TAColors.primary;
        icon = Icons.verified_rounded;
        label = 'Verified';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case TAMaterialType.video:
        return Icons.play_circle_rounded;
      case TAMaterialType.document:
        return Icons.description_rounded;
      case TAMaterialType.code:
        return Icons.code_rounded;
      case TAMaterialType.image:
        return Icons.image_rounded;
      case TAMaterialType.link:
        return Icons.link_rounded;
    }
  }

  Color _getTypeColor() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return Colors.red;
      case TAMaterialType.video:
        return Colors.purple;
      case TAMaterialType.document:
        return Colors.blue;
      case TAMaterialType.code:
        return Colors.green;
      case TAMaterialType.image:
        return Colors.orange;
      case TAMaterialType.link:
        return Colors.teal;
    }
  }

  String _getTypeLabel() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return 'PDF';
      case TAMaterialType.video:
        return 'Video';
      case TAMaterialType.document:
        return 'Doc';
      case TAMaterialType.code:
        return 'Code';
      case TAMaterialType.image:
        return 'Image';
      case TAMaterialType.link:
        return 'Link';
    }
  }

  Color _getCompletionColor() {
    if (material.completionPercent >= 80) return TAColors.success;
    if (material.completionPercent >= 50) return TAColors.warning;
    return TAColors.error;
  }

  bool _hasWarningTag() {
    return material.aiTags.any((tag) =>
        tag == TAMaterialAITag.lowClarity ||
        tag == TAMaterialAITag.suggestUpdate ||
        tag == TAMaterialAITag.outdated);
  }
}
