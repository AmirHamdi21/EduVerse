import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/core/drive_file_model.dart';
import '../../../../models/core/lab_instruction_model.dart';

class InstructionViewer extends StatelessWidget {
  final List<LabInstructionModel> instructions;
  final bool isDark;

  const InstructionViewer({
    super.key,
    required this.instructions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (instructions.isEmpty) {
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

        return Wrap(
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
        );
      },
    );
  }

  Future<void> _showPreview(BuildContext context, DriveFileModel file) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InstructionPreviewSheet(file: file, isDark: isDark),
    );
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

class _InstructionPreviewSheet extends StatefulWidget {
  final DriveFileModel file;
  final bool isDark;

  const _InstructionPreviewSheet({required this.file, required this.isDark});

  @override
  State<_InstructionPreviewSheet> createState() =>
      _InstructionPreviewSheetState();
}

class _InstructionPreviewSheetState extends State<_InstructionPreviewSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.file.iframeUrl));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: responsive.p12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(responsive.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.fileName,
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: responsive.p6),
                Text(
                  'Large files (>50MB) may take longer to preview.',
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    color: widget.isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(responsive.radius12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _hasError
                        ? _buildErrorState(context)
                        : WebViewWidget(controller: _controller),
                  ),
                  if (_isLoading && !_hasError)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
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

  Widget _buildErrorState(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.p20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFEF4444),
              size: responsive.fontSize40,
            ),
            SizedBox(height: responsive.p10),
            Text(
              'Preview unavailable',
              style: TextStyle(
                fontSize: responsive.fontSize16,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: responsive.p8),
            TextButton.icon(
              onPressed: _openInDrive,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in Drive'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInDrive() async {
    final uri = Uri.tryParse(widget.file.webViewLink);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
