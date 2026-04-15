import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerTypeSelector extends StatelessWidget {
  final bool isDark;

  const SummarizerTypeSelector({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.summarizerType,
            style: TextStyle(
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<SummarizerCubit, SummarizerState>(
            buildWhen: (previous, current) =>
                previous.selectedType != current.selectedType,
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF101828) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF364153)
                        : const Color(0xFFD1D5DC),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _showTypePicker(context, state.selectedType, l10n),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getTypeGradient(state.selectedType),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getTypeIcon(state.selectedType),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTypeName(state.selectedType, l10n),
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFF3F4F6)
                                        : const Color(0xFF101828),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _getTypeDescription(state.selectedType, l10n),
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark
                                ? const Color(0xFF99A1AF)
                                : const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTypePicker(
    BuildContext context,
    SummarizationType currentType,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TypePickerSheet(
        isDark: isDark,
        currentType: currentType,
        onTypeSelected: (type) {
          context.read<SummarizerCubit>().setSummarizationType(type);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  List<Color> _getTypeGradient(SummarizationType type) {
    switch (type) {
      case SummarizationType.keyPoints:
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case SummarizationType.brief:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case SummarizationType.detailed:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case SummarizationType.bulletPoints:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case SummarizationType.mindMap:
        return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
    }
  }

  IconData _getTypeIcon(SummarizationType type) {
    switch (type) {
      case SummarizationType.keyPoints:
        return Icons.auto_awesome_rounded;
      case SummarizationType.brief:
        return Icons.short_text_rounded;
      case SummarizationType.detailed:
        return Icons.article_rounded;
      case SummarizationType.bulletPoints:
        return Icons.format_list_bulleted_rounded;
      case SummarizationType.mindMap:
        return Icons.account_tree_rounded;
    }
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

  String _getTypeDescription(SummarizationType type, AppLocalizations l10n) {
    switch (type) {
      case SummarizationType.keyPoints:
        return l10n.summarizerKeyPointsDesc;
      case SummarizationType.brief:
        return l10n.summarizerBriefDesc;
      case SummarizationType.detailed:
        return l10n.summarizerDetailedDesc;
      case SummarizationType.bulletPoints:
        return l10n.summarizerBulletPointsDesc;
      case SummarizationType.mindMap:
        return l10n.summarizerMindMapDesc;
    }
  }
}

class _TypePickerSheet extends StatelessWidget {
  final bool isDark;
  final SummarizationType currentType;
  final Function(SummarizationType) onTypeSelected;

  const _TypePickerSheet({
    required this.isDark,
    required this.currentType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF364153) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.summarizerSelectType,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Options
          ...SummarizationType.values.map(
            (type) =>
                _buildTypeOption(context, type, type == currentType, l10n),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    SummarizationType type,
    bool isSelected,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTypeSelected(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1E2939) : const Color(0xFFF0F9FF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: const Color(0xFF3B82F6))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _getTypeGradient(type)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeGradient(
                        type,
                      ).first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(_getTypeIcon(type), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(type, l10n),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFF101828),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTypeDescription(type, l10n),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getTypeGradient(SummarizationType type) {
    switch (type) {
      case SummarizationType.keyPoints:
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case SummarizationType.brief:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case SummarizationType.detailed:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case SummarizationType.bulletPoints:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case SummarizationType.mindMap:
        return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
    }
  }

  IconData _getTypeIcon(SummarizationType type) {
    switch (type) {
      case SummarizationType.keyPoints:
        return Icons.auto_awesome_rounded;
      case SummarizationType.brief:
        return Icons.short_text_rounded;
      case SummarizationType.detailed:
        return Icons.article_rounded;
      case SummarizationType.bulletPoints:
        return Icons.format_list_bulleted_rounded;
      case SummarizationType.mindMap:
        return Icons.account_tree_rounded;
    }
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

  String _getTypeDescription(SummarizationType type, AppLocalizations l10n) {
    switch (type) {
      case SummarizationType.keyPoints:
        return l10n.summarizerKeyPointsDesc;
      case SummarizationType.brief:
        return l10n.summarizerBriefDesc;
      case SummarizationType.detailed:
        return l10n.summarizerDetailedDesc;
      case SummarizationType.bulletPoints:
        return l10n.summarizerBulletPointsDesc;
      case SummarizationType.mindMap:
        return l10n.summarizerMindMapDesc;
    }
  }
}
