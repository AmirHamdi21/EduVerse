import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class TAUploadArea extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onUploadTap;
  final VoidCallback? onAIGenerateTap;
  final Function(List<String>)? onFilesDropped;

  const TAUploadArea({
    super.key,
    required this.isDark,
    this.onUploadTap,
    this.onAIGenerateTap,
    this.onFilesDropped,
  });

  @override
  State<TAUploadArea> createState() => _TAUploadAreaState();
}

class _TAUploadAreaState extends State<TAUploadArea> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Drag & Drop Area
          GestureDetector(
            onTap: widget.onUploadTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _isDragOver
                    ? TAColors.primary.withValues(alpha: 0.08)
                    : TAColors.cardColor(widget.isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isDragOver
                      ? TAColors.primary
                      : TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
                  width: _isDragOver ? 2 : 1,
                  style: _isDragOver ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: DragTarget<List<String>>(
                onWillAcceptWithDetails: (details) {
                  setState(() => _isDragOver = true);
                  return true;
                },
                onAcceptWithDetails: (details) {
                  setState(() => _isDragOver = false);
                  widget.onFilesDropped?.call(details.data);
                },
                onLeave: (data) {
                  setState(() => _isDragOver = false);
                },
                builder: (context, candidateData, rejectedData) {
                  return Column(
                    children: [
                      // Cloud icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: TAColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: TAColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.taUploadDragDrop,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(widget.isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.taUploadSupportedFormats,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(widget.isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onUploadTap,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: Text(l10n.taUploadMaterials),
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
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onAIGenerateTap,
                  icon: Icon(Icons.auto_awesome, size: 18, color: TAColors.primary),
                  label: Text(l10n.taUploadAIGenerate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: TAColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
