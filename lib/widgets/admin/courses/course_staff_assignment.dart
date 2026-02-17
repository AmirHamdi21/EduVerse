import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

/// Course staff assignment widget
class CourseStaffAssignment extends StatelessWidget {
  final bool isDark;
  final String? selectedInstructor;
  final List<String> selectedTAs;
  final ValueChanged<String?> onInstructorChanged;
  final ValueChanged<List<String>> onTAsChanged;
  final List<String> availableInstructors;
  final List<String> availableTAs;

  const CourseStaffAssignment({
    super.key,
    required this.isDark,
    this.selectedInstructor,
    this.selectedTAs = const [],
    required this.onInstructorChanged,
    required this.onTAsChanged,
    this.availableInstructors = const [],
    this.availableTAs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.staffAssignment,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInstructorSection(l10n),
          const SizedBox(height: 20),
          _buildTASection(l10n),
        ],
      ),
    );
  }

  Widget _buildInstructorSection(AppLocalizations l10n) {
    final instructors = availableInstructors.isEmpty
        ? [
            'Dr. Sarah Johnson',
            'Dr. Ahmed Hassan',
            'Dr. James Wilson',
            'Dr. Emily Chen',
            'Prof. Maria Garcia',
          ]
        : availableInstructors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignInstructor,
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkSurface.withValues(alpha: 0.5)
                : const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedInstructor,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.selectInstructor,
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(isDark),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
              dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
              items: instructors.map((instructor) {
                return DropdownMenuItem<String>(
                  value: instructor,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AdminColors.secondary.withValues(alpha: 0.2),
                        child: Text(
                          instructor.split(' ').map((n) => n[0]).take(2).join(),
                          style: TextStyle(
                            color: AdminColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        instructor,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onInstructorChanged,
            ),
          ),
        ),
        if (selectedInstructor != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AdminColors.secondary,
                  child: Text(
                    selectedInstructor!.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedInstructor!,
                        style: TextStyle(
                          color: AdminColors.getTextColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.instructor,
                        style: TextStyle(
                          color: AdminColors.getTextSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onInstructorChanged(null),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AdminColors.getTextSecondaryColor(isDark),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTASection(AppLocalizations l10n) {
    final tas = availableTAs.isEmpty
        ? [
            'Mike Chen',
            'Sara Ali',
            'John Smith',
            'Alex Brown',
            'Emily Davis',
          ]
        : availableTAs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.assignTAs,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AdminColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.optional,
                style: TextStyle(
                  color: AdminColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tas.map((ta) {
            final isSelected = selectedTAs.contains(ta);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final newList = List<String>.from(selectedTAs);
                  if (isSelected) {
                    newList.remove(ta);
                  } else {
                    newList.add(ta);
                  }
                  onTAsChanged(newList);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AdminColors.accent.withValues(alpha: 0.1)
                        : (isDark
                            ? AdminColors.darkSurface.withValues(alpha: 0.5)
                            : const Color(0xFFF3F3F5)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AdminColors.accent
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AdminColors.accent,
                        )
                      else
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AdminColors.accent.withValues(alpha: 0.2),
                          child: Text(
                            ta.split(' ').map((n) => n[0]).take(2).join(),
                            style: TextStyle(
                              color: AdminColors.accent,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        ta,
                        style: TextStyle(
                          color: isSelected
                              ? AdminColors.accent
                              : AdminColors.getTextColor(isDark),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
