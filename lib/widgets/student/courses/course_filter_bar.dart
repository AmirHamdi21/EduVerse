import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class CourseFilterBar extends StatefulWidget {
  final Function(String) onFilterChanged;

  const CourseFilterBar({super.key, required this.onFilterChanged});

  @override
  State<CourseFilterBar> createState() => _CourseFilterBarState();
}

class _CourseFilterBarState extends State<CourseFilterBar> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton(
                label: l10n.all,
                value: 'all',
                isDark: isDark,
                isGradient: true,
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: 'Active',
                value: 'active',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: l10n.completed,
                value: 'completed',
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildFilterButton(
                label: 'Dropped',
                value: 'dropped',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String value,
    required bool isDark,
    bool isGradient = false,
  }) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        widget.onFilterChanged(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected && isGradient
              ? const LinearGradient(
                  colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected && !isGradient
              ? (isDark ? const Color(0xFF2A3F5F) : const Color(0xFFF0F4FF))
              : (isDark ? const Color(0xFF16213E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected && !isGradient
                ? const Color(0xFF155DFC)
                : (isDark ? Colors.white10 : const Color(0xFFD1D5DC)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF155DFC).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected && isGradient
                ? Colors.white
                : (isSelected
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white70 : const Color(0xFF364153))),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
