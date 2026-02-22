import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSearchCategoryChips extends StatelessWidget {
  final bool isDark;
  final String selectedCategory;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String> onCategoryChanged;

  const ITSearchCategoryChips({
    super.key,
    required this.isDark,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : ITColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(category['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category['id'] as String),
              selectedColor: ITColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : ITColors.textSecondaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: ITColors.cardColor(isDark),
              side: BorderSide(
                color: isSelected ? ITColors.primary : ITColors.borderColor(isDark),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
