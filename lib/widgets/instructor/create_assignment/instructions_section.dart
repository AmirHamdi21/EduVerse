import 'package:flutter/material.dart';
import 'create_assignment_colors.dart';

class InstructionsSection extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color? accentColor;

  const InstructionsSection({
    super.key,
    required this.controller,
    required this.isDark,
    this.accentColor,
  });

  @override
  State<InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection> {
  bool _isBold = false;
  bool _isItalic = false;

  Color get _accent => widget.accentColor ?? CreateAssignmentColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rich Text Editor Area
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: widget.isDark
                ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
                : CreateAssignmentColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CreateAssignmentColors.borderColor(widget.isDark),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            maxLines: null,
            minLines: 5,
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
            ),
            decoration: InputDecoration(
              hintText: 'Enter detailed instructions for students...',
              hintStyle: TextStyle(
                color: CreateAssignmentColors.textTertiaryColor(widget.isDark),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Formatting Toolbar
        _buildFormattingToolbar(),
      ],
    );
  }

  Widget _buildFormattingToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFormatButton(
            icon: Icons.format_bold_rounded,
            label: 'Bold',
            isActive: _isBold,
            onTap: () => setState(() => _isBold = !_isBold),
          ),
          const SizedBox(width: 8),
          _buildFormatButton(
            icon: Icons.format_italic_rounded,
            label: 'Italic',
            isActive: _isItalic,
            onTap: () => setState(() => _isItalic = !_isItalic),
          ),
          const SizedBox(width: 8),
          _buildFormatButton(
            icon: Icons.format_list_bulleted_rounded,
            label: 'List',
            isActive: false,
            onTap: () => _insertList(),
          ),
          const SizedBox(width: 8),
          _buildFormatButton(
            icon: Icons.code_rounded,
            label: 'Code',
            isActive: false,
            onTap: () => _insertCode(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? _accent.withValues(alpha: 0.1)
                : (widget.isDark
                      ? CreateAssignmentColors.darkSurface.withValues(
                          alpha: 0.5,
                        )
                      : CreateAssignmentColors.surface),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? _accent.withValues(alpha: 0.3)
                  : CreateAssignmentColors.borderColor(widget.isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? _accent
                    : CreateAssignmentColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? _accent
                      : CreateAssignmentColors.textSecondaryColor(
                          widget.isDark,
                        ),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertList() {
    final text = widget.controller.text;
    final newText = '$text\n• ';
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: newText.length,
    );
  }

  void _insertCode() {
    final text = widget.controller.text;
    final newText = '$text\n```\n\n```';
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: newText.length - 4,
    );
  }
}
