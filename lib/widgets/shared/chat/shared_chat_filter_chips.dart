import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import 'chat_list_types.dart';

class SharedChatFilterChips extends StatelessWidget {
  final ChatListFilter currentFilter;
  final ValueChanged<ChatListFilter> onFilterChanged;
  final bool isDark;
  final Color accentColor;

  const SharedChatFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_FilterChipItem>[
      _FilterChipItem(
        filter: ChatListFilter.all,
        label: l10n.chatFilterAll,
        icon: Icons.forum_rounded,
      ),
      _FilterChipItem(
        filter: ChatListFilter.unread,
        label: l10n.chatFilterUnread,
        icon: Icons.mark_chat_unread_rounded,
      ),
      _FilterChipItem(
        filter: ChatListFilter.groups,
        label: l10n.chatFilterGroups,
        icon: Icons.groups_rounded,
      ),
    ];
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = currentFilter == item.filter;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onFilterChanged(item.filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : borderColor.withValues(alpha: 0.95),
                ),
                boxShadow: isSelected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.20),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.16)
                          : accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      size: 16,
                      color: isSelected ? Colors.white : accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF334155)),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChipItem {
  final ChatListFilter filter;
  final String label;
  final IconData icon;

  const _FilterChipItem({
    required this.filter,
    required this.label,
    required this.icon,
  });
}
