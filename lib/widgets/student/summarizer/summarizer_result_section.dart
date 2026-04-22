import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerResultSection extends StatefulWidget {
  final bool isDark;

  const SummarizerResultSection({super.key, required this.isDark});

  @override
  State<SummarizerResultSection> createState() =>
      _SummarizerResultSectionState();
}

class _SummarizerResultSectionState extends State<SummarizerResultSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummarizerCubit, SummarizerState>(
      buildWhen: (previous, current) =>
          previous.currentSummary != current.currentSummary ||
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage ||
          previous.currentSummary?.isFavorite !=
              current.currentSummary?.isFavorite,
      builder: (context, state) {
        if (state.currentSummary != null) {
          return _buildSummaryResult(context, state.currentSummary!);
        }
        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF1E2939)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1E2939)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.summarize_outlined,
                size: 40,
                color: widget.isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.summarizerNoSummary,
              style: TextStyle(
                color: widget.isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.summarizerNoSummaryDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDark
                    ? const Color(0xFF99A1AF)
                    : const Color(0xFF4A5565),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryResult(BuildContext context, Summary summary) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF1E2939)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildResultHeader(context, summary, l10n),
            // Divider
            Container(
              height: 1,
              color: widget.isDark
                  ? const Color(0xFF1E2939)
                  : const Color(0xFFE5E7EB),
            ),
            // Content
            _buildResultContent(context, summary),
            // Actions
            _buildResultActions(context, summary, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(
    BuildContext context,
    Summary summary,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_rounded,
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
                  l10n.summarizerResult,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTypeName(summary.type, l10n),
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Favorite button
          IconButton(
            onPressed: () {
              context.read<SummarizerCubit>().toggleFavorite(summary.id);
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                summary.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(summary.isFavorite),
                color: summary.isFavorite
                    ? const Color(0xFFEF4444)
                    : (widget.isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, Summary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary.sourceFileName != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E2939)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      size: 16,
                      color: widget.isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        summary.sourceFileName!,
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF99A1AF)
                              : const Color(0xFF4A5565),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SelectableText(
              summary.content,
              style: TextStyle(
                color: widget.isDark
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF374151),
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions(
    BuildContext context,
    Summary summary,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF0A0F1A)
            : const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.copy_rounded,
              label: l10n.summarizerCopy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: summary.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.summarizerCopied),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.share_rounded,
              label: l10n.summarizerShare,
              onTap: () {
                // Share functionality
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.save_alt_rounded,
              label: l10n.summarizerSave,
              isPrimary: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.summarizerSaved),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF3B82F6)
                : (widget.isDark ? const Color(0xFF1E2939) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: widget.isDark
                        ? const Color(0xFF364153)
                        : const Color(0xFFE5E7EB),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (widget.isDark
                          ? const Color(0xFF99A1AF)
                          : const Color(0xFF4A5565)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : (widget.isDark
                            ? const Color(0xFF99A1AF)
                            : const Color(0xFF4A5565)),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeName(SummarizationType type, AppLocalizations l10n) {
    switch (type) {
      case SummarizationType.keyPoints:
        return l10n.summarizerKeyPoints;
      case SummarizationType.brief:
        return l10n.summarizerBrief;
      case SummarizationType.detailed:
        return l10n.summarizerDetailed;
      case SummarizationType.bulletPoints:
        return l10n.summarizerBulletPoints;
      case SummarizationType.mindMap:
        return l10n.summarizerMindMap;
    }
  }
}
