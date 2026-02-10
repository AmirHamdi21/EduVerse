import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class TAAIMaterialGenerator extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onGeneratePDF;
  final VoidCallback? onGenerateTranscript;
  final VoidCallback? onGenerateStudyGuide;
  final VoidCallback? onClose;

  const TAAIMaterialGenerator({
    super.key,
    required this.isDark,
    this.onGeneratePDF,
    this.onGenerateTranscript,
    this.onGenerateStudyGuide,
    this.onClose,
  });

  static void show(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TAColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: TAColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.taUploadAIMaterialGenerator,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.taUploadAIMaterialSubtitle,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Options
            _AIGeneratorOption(
              isDark: isDark,
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFE74C3C),
              title: l10n.taUploadGenerateLabPDF,
              subtitle: l10n.taUploadGenerateLabPDFDesc,
              buttonText: l10n.taUploadGeneratePDF,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taUploadGeneratingPDF),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AIGeneratorOption(
              isDark: isDark,
              icon: Icons.closed_caption_rounded,
              iconColor: const Color(0xFF9B59B6),
              title: l10n.taUploadVideoTranscript,
              subtitle: l10n.taUploadVideoTranscriptDesc,
              buttonText: l10n.taUploadGenerateTranscript,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taUploadGeneratingTranscript),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AIGeneratorOption(
              isDark: isDark,
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFF2ECC71),
              title: l10n.taUploadCreateStudyGuide,
              subtitle: l10n.taUploadCreateStudyGuideDesc,
              buttonText: l10n.taUploadGenerateGuide,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.taUploadGeneratingGuide),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _AIGeneratorOption extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onTap;

  const _AIGeneratorOption({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.scaffoldColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
