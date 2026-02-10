import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TAAIReplyAssistant extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onGenerateReply;
  final VoidCallback? onExplainIssue;
  final Function(String)? onSendReply;

  const TAAIReplyAssistant({
    super.key,
    required this.isDark,
    this.onGenerateReply,
    this.onExplainIssue,
    this.onSendReply,
  });

  @override
  State<TAAIReplyAssistant> createState() => _TAAIReplyAssistantState();
}

class _TAAIReplyAssistantState extends State<TAAIReplyAssistant> {
  final TextEditingController _replyController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Assistant Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TAColors.primary.withValues(alpha: widget.isDark ? 0.2 : 0.1),
                    TAColors.primary.withValues(alpha: widget.isDark ? 0.1 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: TAColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.taNotifAIReplyAssistant,
                    style: TextStyle(
                      color: TAColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: TAColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Expanded AI Actions
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAIActionButton(
                    icon: Icons.smart_toy_outlined,
                    label: l10n.taNotifGenerateReply,
                    onTap: widget.onGenerateReply,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAIActionButton(
                    icon: Icons.lightbulb_outline_rounded,
                    label: l10n.taNotifExplainIssue,
                    onTap: widget.onExplainIssue,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // Reply Input
          Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? TAColors.darkSurface.withValues(alpha: 0.5)
                  : TAColors.surfaceColor(widget.isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: 3,
                    minLines: 1,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(widget.isDark),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.taNotifTypeReply,
                      hintStyle: TextStyle(
                        color: TAColors.textTertiaryColor(widget.isDark),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: TAColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        if (_replyController.text.isNotEmpty) {
                          widget.onSendReply?.call(_replyController.text);
                          _replyController.clear();
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? TAColors.darkSurface.withValues(alpha: 0.5)
                : TAColors.surfaceColor(widget.isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: TAColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(widget.isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
