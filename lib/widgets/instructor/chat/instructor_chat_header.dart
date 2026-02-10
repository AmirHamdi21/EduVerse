import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

class InstructorChatHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onNewChat;
  final bool isSearching;
  final VoidCallback onToggleSearch;
  final int unreadCount;

  const InstructorChatHeader({
    super.key,
    required this.isDark,
    required this.onNewChat,
    required this.isSearching,
    required this.onToggleSearch,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? InstructorColors.background(true) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: InstructorColors.borderColor(isDark),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
              size: 20,
            ),
            splashRadius: 24,
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  l10n.messages,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: InstructorColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isSearching
                  ? InstructorColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onToggleSearch,
              icon: Icon(
                isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: isSearching
                    ? Colors.white
                    : InstructorColors.textTertiaryColor(isDark),
                size: 22,
              ),
              splashRadius: 24,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  InstructorColors.primary,
                  InstructorColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: InstructorColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
