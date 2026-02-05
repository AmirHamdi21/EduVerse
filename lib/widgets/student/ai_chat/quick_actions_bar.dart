import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/ai_chat/ai_chat_state.dart';

class QuickActionsBar extends StatelessWidget {
  final List<QuickAction> quickActions;
  final Function(String) onActionTap;

  const QuickActionsBar({
    super.key,
    required this.quickActions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    if (quickActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: quickActions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildActionChip(action, isDark),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionChip(QuickAction action, bool isDark) {
    return GestureDetector(
      onTap: () => onActionTap(action.prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForType(action.iconType),
              size: 16,
              color: const Color(0xFF2B7FFF),
            ),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFD1D5DC) : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String iconType) {
    switch (iconType) {
      case 'summarize':
        return Icons.summarize_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'explain':
        return Icons.lightbulb_outline_rounded;
      case 'performance':
        return Icons.insights_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      case 'help':
        return Icons.help_outline_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
