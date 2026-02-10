import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';
import 'ta_material_card.dart';

class TAFilePreviewModal extends StatelessWidget {
  final TAMaterialItem material;
  final bool isDark;
  final VoidCallback? onClose;
  final VoidCallback? onDownload;
  final VoidCallback? onSummarize;
  final VoidCallback? onGenerateQuiz;
  final VoidCallback? onCreateFlashcards;
  final VoidCallback? onGenerateNotes;

  const TAFilePreviewModal({
    super.key,
    required this.material,
    required this.isDark,
    this.onClose,
    this.onDownload,
    this.onSummarize,
    this.onGenerateQuiz,
    this.onCreateFlashcards,
    this.onGenerateNotes,
  });

  static void show(BuildContext context, TAMaterialItem material, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => TAFilePreviewModal(
          material: material,
          isDark: isDark,
          onClose: () => Navigator.pop(context),
          onDownload: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading ${material.name}...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onSummarize: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generating summary...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onGenerateQuiz: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generating quiz questions...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onCreateFlashcards: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Creating flashcards...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onGenerateNotes: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generating notes...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TAColors.borderColor(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        material.size,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          // Preview Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: TAColors.scaffoldColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTypeIcon(),
                      size: 64,
                      color: TAColors.textTertiaryColor(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.taUploadPreviewArea,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      material.name,
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // AI Enhancement Tools
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TAColors.scaffoldColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: TAColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.taUploadAIEnhancementTools,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAIToolChip(
                      icon: Icons.summarize_rounded,
                      label: l10n.taUploadSummarize,
                      onTap: onSummarize,
                    ),
                    _buildAIToolChip(
                      icon: Icons.quiz_rounded,
                      label: l10n.taUploadQuiz,
                      onTap: onGenerateQuiz,
                    ),
                    _buildAIToolChip(
                      icon: Icons.style_rounded,
                      label: l10n.taUploadFlashcards,
                      onTap: onCreateFlashcards,
                    ),
                    _buildAIToolChip(
                      icon: Icons.note_alt_rounded,
                      label: l10n.taUploadNotes,
                      onTap: onGenerateNotes,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: TAColors.borderColor(isDark)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(l10n.taUploadDownload),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TAColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIToolChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TAColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TAColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: TAColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 12,
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
        return Icons.videocam_rounded;
      case TAMaterialType.code:
        return Icons.code_rounded;
      case TAMaterialType.image:
        return Icons.image_rounded;
      case TAMaterialType.document:
        return Icons.description_rounded;
      case TAMaterialType.archive:
        return Icons.folder_zip_rounded;
      case TAMaterialType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return const Color(0xFFE74C3C);
      case TAMaterialType.video:
        return const Color(0xFF9B59B6);
      case TAMaterialType.code:
        return const Color(0xFF3498DB);
      case TAMaterialType.image:
        return const Color(0xFF2ECC71);
      case TAMaterialType.document:
        return const Color(0xFFF39C12);
      case TAMaterialType.archive:
        return const Color(0xFF1ABC9C);
      case TAMaterialType.other:
        return const Color(0xFF95A5A6);
    }
  }
}
