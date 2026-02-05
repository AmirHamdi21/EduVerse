import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/ai_chat/ai_chat_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class AiChatHeader extends StatelessWidget {
  final ChatMode chatMode;
  final String? selectedCourse;
  final List<String> availableCourses;
  final Function(ChatMode) onModeChanged;
  final Function(String) onCourseSelected;

  const AiChatHeader({
    super.key,
    required this.chatMode,
    this.selectedCourse,
    required this.availableCourses,
    required this.onModeChanged,
    required this.onCourseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(l10n, isDark),
          const SizedBox(height: 16),
          _buildModeSelector(context, l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildTitleRow(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF51A2FF).withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiAssistantTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFF3F4F6)
                      : const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.aiAssistantSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF99A1AF)
                      : const Color(0xFF4A5565),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildModeChip(
          context,
          ChatMode.generalHelp,
          l10n.generalHelp,
          Icons.help_outline_rounded,
          isDark,
        ),
        _buildModeChip(
          context,
          ChatMode.courseSpecific,
          l10n.courseSpecificMode,
          Icons.menu_book_rounded,
          isDark,
        ),
        _buildModeChip(
          context,
          ChatMode.aiTutor,
          l10n.aiTutorMode,
          Icons.school_rounded,
          isDark,
        ),
      ],
    );
  }

  Widget _buildModeChip(
    BuildContext context,
    ChatMode mode,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = chatMode == mode;

    return GestureDetector(
      onTap: () {
        onModeChanged(mode);
        if (mode == ChatMode.courseSpecific) {
          _showCourseSelector(context, isDark);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF155DFC)
              : (isDark ? const Color(0xFF101828) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF155DFC)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DC)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF155DFC).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFFD1D5DC)
                        : const Color(0xFF364153)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFFD1D5DC)
                            : const Color(0xFF364153)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseSelector(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101828) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.selectCourse,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            ...availableCourses.map((course) {
              final isSelected = selectedCourse == course;
              return GestureDetector(
                onTap: () {
                  onCourseSelected(course);
                  Navigator.pop(sheetContext);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2B7FFF).withValues(alpha: 0.15)
                        : (isDark
                              ? const Color(0xFF1E2939)
                              : const Color(0xFFF9FAFB)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2B7FFF)
                          : (isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: isSelected
                            ? const Color(0xFF2B7FFF)
                            : (isDark
                                  ? Colors.white54
                                  : const Color(0xFF6B7280)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          course,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF2B7FFF)
                                : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937)),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: Color(0xFF2B7FFF),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
