import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TALabCopilotWidget extends StatefulWidget {
  final bool isDark;
  final Function(String tool)? onToolTap;
  final Function(String query)? onAskAI;

  const TALabCopilotWidget({
    super.key,
    required this.isDark,
    this.onToolTap,
    this.onAskAI,
  });

  @override
  State<TALabCopilotWidget> createState() => _TALabCopilotWidgetState();
}

class _TALabCopilotWidgetState extends State<TALabCopilotWidget> {
  final TextEditingController _queryController = TextEditingController();
  String? _aiResponse;
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCopilotHeader(l10n),
          const SizedBox(height: 20),
          _buildToolsGrid(l10n),
          const SizedBox(height: 20),
          _buildAskAISection(l10n),
        ],
      ),
    );
  }

  Widget _buildCopilotHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: TAColors.aiGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.taLabCopilotTitle,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(widget.isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.taLabCopilotSubtitle,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(widget.isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(AppLocalizations l10n) {
    final tools = [
      _TALabTool(
        id: 'generate_hints',
        icon: Icons.lightbulb_outline_rounded,
        label: l10n.taLabGenerateHints,
        color: TAColors.warning,
      ),
      _TALabTool(
        id: 'explain_steps',
        icon: Icons.menu_book_rounded,
        label: l10n.taLabExplainSteps,
        color: TAColors.info,
      ),
      _TALabTool(
        id: 'clarify_questions',
        icon: Icons.help_outline_rounded,
        label: l10n.taLabClarifyQuestions,
        color: TAColors.teal,
      ),
      _TALabTool(
        id: 'sample_output',
        icon: Icons.code_rounded,
        label: l10n.taLabSampleOutput,
        color: TAColors.secondary,
      ),
      _TALabTool(
        id: 'evaluate_answers',
        icon: Icons.fact_check_outlined,
        label: l10n.taLabEvaluateAnswers,
        color: TAColors.success,
      ),
      _TALabTool(
        id: 'rewrite_instructions',
        icon: Icons.edit_note_rounded,
        label: l10n.taLabRewriteInstructions,
        color: TAColors.primary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) => _buildToolCard(tools[index]),
      ),
    );
  }

  Widget _buildToolCard(_TALabTool tool) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onToolTap?.call(tool.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark
                ? TAColors.darkSurface.withValues(alpha: 0.5)
                : TAColors.surfaceColor(widget.isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tool.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tool.color.withValues(
                    alpha: widget.isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tool.icon, color: tool.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                tool.label,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAskAISection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taLabAskAI,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _queryController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: l10n.taLabAskAIPlaceholder,
              hintStyle: TextStyle(
                color: TAColors.textTertiaryColor(widget.isDark),
                fontSize: 13,
              ),
              filled: true,
              fillColor: widget.isDark
                  ? TAColors.darkSurface.withValues(alpha: 0.5)
                  : TAColors.surfaceColor(widget.isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: TAColors.primary),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleAskAI,
              icon: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(l10n.taLabGenerateResponse),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_aiResponse != null) ...[
            const SizedBox(height: 16),
            _buildAIResponse(l10n),
          ],
        ],
      ),
    );
  }

  void _handleAskAI() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _aiResponse =
          'Based on Lab 3 objectives, here\'s a suggested approach: '
          'Students should implement the producer-consumer pattern using semaphores. '
          'Key concepts include mutex locks for critical sections and proper synchronization...';
    });

    widget.onAskAI?.call(_queryController.text);
  }

  Widget _buildAIResponse(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.primary.withValues(alpha: widget.isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 16,
                  color: TAColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.taLabAIResponse,
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiResponse!,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildResponseAction(
                icon: Icons.copy_rounded,
                label: l10n.taLabCopy,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildResponseAction(
                icon: Icons.share_rounded,
                label: l10n.taLabShare,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseAction({
    required IconData icon,
    required String label,
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
            color: TAColors.cardColor(widget.isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TAColors.borderColor(widget.isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: TAColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TALabTool {
  final String id;
  final IconData icon;
  final String label;
  final Color color;

  _TALabTool({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
  });
}
