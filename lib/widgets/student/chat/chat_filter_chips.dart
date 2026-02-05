import 'package:flutter/material.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../generated_l10n/app_localizations.dart';

class ChatFilterChips extends StatelessWidget {
  final ChatFilter currentFilter;
  final bool isDark;
  final ValueChanged<ChatFilter> onFilterChanged;

  const ChatFilterChips({
    super.key,
    required this.currentFilter,
    required this.isDark,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filters = [
      _FilterItem(ChatFilter.all, l10n.all, Icons.chat_bubble_outline_rounded),
      _FilterItem(ChatFilter.unread, 'Unread', Icons.mark_unread_chat_alt_rounded),
      _FilterItem(ChatFilter.instructors, l10n.instructor, Icons.school_outlined),
      _FilterItem(ChatFilter.students, l10n.student, Icons.person_outline_rounded),
      _FilterItem(ChatFilter.groups, 'Groups', Icons.group_outlined),
      _FilterItem(ChatFilter.courses, l10n.courses, Icons.menu_book_outlined),
    ];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = currentFilter == filter.filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              filter: filter,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onFilterChanged(filter.filter),
            ),
          );
        },
      ),
    );
  }
}

class _FilterItem {
  final ChatFilter filter;
  final String label;
  final IconData icon;

  const _FilterItem(this.filter, this.label, this.icon);
}

class _FilterChip extends StatelessWidget {
  final _FilterItem filter;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected
            ? null
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 16,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 6),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
