import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/smart_study/smart_study_cubit.dart';
import '../../../bloc/smart_study/smart_study_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SmartStudyTabs extends StatelessWidget {
  final bool isDark;

  const SmartStudyTabs({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SmartStudyCubit, SmartStudyState>(
      buildWhen: (prev, curr) => prev.currentTab != curr.currentTab,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab(
                    context: context,
                    title: l10n.smartStudyTopicsToReview,
                    isSelected:
                        state.currentTab == SmartStudyTab.topicsToReview,
                    onTap: () => context.read<SmartStudyCubit>().changeTab(
                      SmartStudyTab.topicsToReview,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTab(
                    context: context,
                    title: l10n.smartStudySchedule,
                    isSelected: state.currentTab == SmartStudyTab.studySchedule,
                    onTap: () => context.read<SmartStudyCubit>().changeTab(
                      SmartStudyTab.studySchedule,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2B7FFF) : const Color(0xFF2B7FFF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF4A5565)),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
