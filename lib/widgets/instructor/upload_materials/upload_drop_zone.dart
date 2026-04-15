import 'package:flutter/material.dart';
import 'upload_materials_colors.dart';

/// Drop zone widget for file uploads
class UploadDropZone extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDragEnter;
  final VoidCallback? onDragExit;
  final bool isCompact;

  const UploadDropZone({
    super.key,
    required this.isDark,
    required this.onTap,
    this.onDragEnter,
    this.onDragExit,
    this.isCompact = false,
  });

  @override
  State<UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<UploadDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(widget.isCompact ? 20 : 32),
        decoration: BoxDecoration(
          color: UploadMaterialsColors.dropZoneColor(
            widget.isDark,
            _isDragOver,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: UploadMaterialsColors.dropZoneBorder(
              widget.isDark,
              _isDragOver,
            ),
            width: _isDragOver ? 2 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.isCompact ? 56 : 72,
              height: widget.isCompact ? 56 : 72,
              decoration: BoxDecoration(
                gradient: UploadMaterialsColors.uploadGradient,
                borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
                boxShadow: [
                  BoxShadow(
                    color: UploadMaterialsColors.uploadGreen.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white,
                size: widget.isCompact ? 28 : 36,
              ),
            ),
            SizedBox(height: widget.isCompact ? 12 : 20),
            Text(
              'Drag & drop files here',
              style: TextStyle(
                color: UploadMaterialsColors.textPrimaryColor(widget.isDark),
                fontSize: widget.isCompact ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'or click to browse',
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
                fontSize: widget.isCompact ? 12 : 14,
              ),
            ),
            if (!widget.isCompact) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? UploadMaterialsColors.darkSurface
                      : UploadMaterialsColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Supports: PDF, DOC, PPT, XLS, MP4, MP3, Images & more',
                  style: TextStyle(
                    color: UploadMaterialsColors.textTertiaryColor(
                      widget.isDark,
                    ),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Upload type button widget
class UploadTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const UploadTypeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: UploadMaterialsColors.borderColor(isDark),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header widget
class UploadSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;

  const UploadSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: UploadMaterialsColors.textSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
