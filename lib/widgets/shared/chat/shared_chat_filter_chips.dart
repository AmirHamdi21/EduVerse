import 'package:flutter/material.dart';

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
    final items = <_FilterChipItem>[
      const _FilterChipItem(filter: ChatListFilter.all, label: 'All'),
      const _FilterChipItem(filter: ChatListFilter.unread, label: 'Unread'),
      const _FilterChipItem(filter: ChatListFilter.groups, label: 'Groups'),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = currentFilter == item.filter;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Text(item.label),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155)),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
            ),
            selectedColor: accentColor,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            onSelected: (_) => onFilterChanged(item.filter),
          );
        },
      ),
    );
  }
}

class _FilterChipItem {
  final ChatListFilter filter;
  final String label;

  const _FilterChipItem({required this.filter, required this.label});
}
