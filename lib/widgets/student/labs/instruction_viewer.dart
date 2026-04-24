import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/core/drive_file_model.dart';
import '../../../../models/core/lab_instruction_model.dart';
import '../shared/drive_file_preview_screen.dart';

class InstructionViewer extends StatelessWidget {
  final List<LabInstructionModel> instructions;
  final List<DriveFileModel> attachmentFiles;
  final bool isDark;

  const InstructionViewer({
    super.key,
    required this.instructions,
    this.attachmentFiles = const <DriveFileModel>[],
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (instructions.isEmpty && attachmentFiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.p14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withValues(alpha: 0.35)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(responsive.radius12),
        ),
        child: Text(
          'No instructions provided yet.',
          style: TextStyle(
            fontSize: responsive.fontSize13,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      );
    }

    final ordered = List<LabInstructionModel>.from(instructions)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final fileWidth = isTablet
            ? (constraints.maxWidth - responsive.p12) / 2
            : constraints.maxWidth;
        final attachedFiles = attachmentFiles
            .where((file) => file.fileName.trim().isNotEmpty)
            .toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attachedFiles.isNotEmpty) ...[
              Text(
                'Attached Materials',
                style: TextStyle(
                  fontSize: responsive.fontSize13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: responsive.p8),
              Wrap(
                spacing: responsive.p12,
                runSpacing: responsive.p12,
                children: attachedFiles
                    .map(
                      (file) => SizedBox(
                        width: fileWidth,
                        child: _InstructionFileCard(
                          file: file,
                          isDark: isDark,
                          onPreview: (selected) =>
                              _showPreview(context, selected),
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (ordered.isNotEmpty) SizedBox(height: responsive.p16),
            ],
            Wrap(
              spacing: responsive.p12,
              runSpacing: responsive.p12,
              children: ordered.map((instruction) {
                final hasText = (instruction.instructionText ?? '')
                    .trim()
                    .isNotEmpty;
                final hasFile = instruction.file != null;

                if (hasText && hasFile) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InstructionTextCard(
                          text: instruction.instructionText!.trim(),
                          isDark: isDark,
                        ),
                        SizedBox(height: responsive.p12),
                        SizedBox(
                          width: fileWidth,
                          child: _InstructionFileCard(
                            file: instruction.file!,
                            isDark: isDark,
                            onPreview: (file) => _showPreview(context, file),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (hasText) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: _InstructionTextCard(
                      text: instruction.instructionText!.trim(),
                      isDark: isDark,
                    ),
                  );
                }

                if (hasFile) {
                  return SizedBox(
                    width: fileWidth,
                    child: _InstructionFileCard(
                      file: instruction.file!,
                      isDark: isDark,
                      onPreview: (file) => _showPreview(context, file),
                    ),
                  );
                }

                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPreview(BuildContext context, DriveFileModel file) async {
    await openDriveFilePreviewScreen(context, file: file, isDark: isDark);
  }
}

class _InstructionTextCard extends StatelessWidget {
  final String text;
  final bool isDark;

  const _InstructionTextCard({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.35)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.radius12),
      ),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(
            fontSize: responsive.fontSize14,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            height: 1.4,
          ),
          strong: TextStyle(
            fontSize: responsive.fontSize14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          listBullet: TextStyle(
            fontSize: responsive.fontSize14,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}

class _InstructionFileCard extends StatelessWidget {
  final DriveFileModel file;
  final bool isDark;
  final ValueChanged<DriveFileModel> onPreview;

  const _InstructionFileCard({
    required this.file,
    required this.isDark,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.35)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                color: const Color(0xFF3B82F6),
                size: responsive.fontSize18,
              ),
              SizedBox(width: responsive.p8),
              Expanded(
                child: Text(
                  file.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: responsive.fontSize13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p10),
          Wrap(
            spacing: responsive.p8,
            runSpacing: responsive.p8,
            children: [
              _ActionButton(
                icon: Icons.open_in_new_rounded,
                label: 'Open',
                onTap: () => _openExternal(file.webViewLink),
              ),
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () => _openExternal(file.downloadUrl),
              ),
              _ActionButton(
                icon: Icons.visibility_rounded,
                label: 'Preview',
                onTap: () => onPreview(file),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExternal(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: responsive.fontSize14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        side: BorderSide(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.p10,
          vertical: responsive.p8,
        ),
        textStyle: TextStyle(
          fontSize: responsive.fontSize12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
