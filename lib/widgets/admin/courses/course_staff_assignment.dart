import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class StaffMemberOption extends Equatable {
  final int userId;
  final String fullName;

  const StaffMemberOption({required this.userId, required this.fullName});

  @override
  List<Object?> get props => <Object?>[userId, fullName];
}

class InstructorAssignmentDraft extends Equatable {
  final int? userId;
  final String role;
  final String? responsibilities;

  const InstructorAssignmentDraft({
    this.userId,
    this.role = 'primary',
    this.responsibilities,
  });

  InstructorAssignmentDraft copyWith({
    int? userId,
    bool clearUserId = false,
    String? role,
    String? responsibilities,
  }) {
    return InstructorAssignmentDraft(
      userId: clearUserId ? null : (userId ?? this.userId),
      role: role ?? this.role,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }

  @override
  List<Object?> get props => <Object?>[userId, role, responsibilities];
}

class _RoleOption {
  final String value;
  final String label;

  const _RoleOption({required this.value, required this.label});
}

/// Course staff assignment widget.
class CourseStaffAssignment extends StatelessWidget {
  final bool isDark;
  final List<InstructorAssignmentDraft> assignments;
  final ValueChanged<List<InstructorAssignmentDraft>> onAssignmentsChanged;
  final List<StaffMemberOption> availableStaff;

  const CourseStaffAssignment({
    super.key,
    required this.isDark,
    required this.assignments,
    required this.onAssignmentsChanged,
    this.availableStaff = const <StaffMemberOption>[],
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
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
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
              const Spacer(),
              IconButton(
                onPressed: () {
                  final next = List<InstructorAssignmentDraft>.from(assignments)
                    ..add(const InstructorAssignmentDraft());
                  onAssignmentsChanged(next);
                },
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: AdminColors.primary,
                ),
                tooltip: l10n.add,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (availableStaff.isEmpty)
            _buildEmptyStaffSource(context)
          else if (assignments.isEmpty)
            _buildAddPrompt(context)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return _buildAssignmentRow(
                  context: context,
                  assignment: assignment,
                  index: index,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyStaffSource(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.45)
            : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l10n.noData,
        style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
      ),
    );
  }

  Widget _buildAddPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.45)
            : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l10n.add,
        style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
      ),
    );
  }

  Widget _buildAssignmentRow({
    required BuildContext context,
    required InstructorAssignmentDraft assignment,
    required int index,
  }) {
    final l10n = AppLocalizations.of(context);
    final roleOptions = <_RoleOption>[
      _RoleOption(value: 'primary', label: l10n.rolePrimary),
      _RoleOption(value: 'co_instructor', label: l10n.roleCoInstructor),
      _RoleOption(value: 'guest', label: l10n.roleGuestInstructor),
      _RoleOption(value: 'ta', label: l10n.teachingAssistant),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.5)
            : const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: assignment.userId,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  hint: Text(l10n.user),
                  dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                  items: availableStaff
                      .map(
                        (staff) => DropdownMenuItem<int>(
                          value: staff.userId,
                          child: Text(
                            staff.fullName,
                            style: TextStyle(
                              color: AdminColors.getTextColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (userId) {
                    _updateAssignment(
                      index,
                      assignment.copyWith(userId: userId),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue:
                      roleOptions.any(
                        (option) => option.value == assignment.role,
                      )
                      ? assignment.role
                      : roleOptions.first.value,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  dropdownColor: isDark ? AdminColors.darkCard : Colors.white,
                  items: roleOptions
                      .map(
                        (roleOption) => DropdownMenuItem<String>(
                          value: roleOption.value,
                          child: Text(
                            roleOption.label,
                            style: TextStyle(
                              color: AdminColors.getTextColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (role) {
                    if (role == null) {
                      return;
                    }
                    _updateAssignment(index, assignment.copyWith(role: role));
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  final next = List<InstructorAssignmentDraft>.from(assignments)
                    ..removeAt(index);
                  onAssignmentsChanged(next);
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AdminColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: assignment.responsibilities,
            onChanged: (value) {
              _updateAssignment(
                index,
                assignment.copyWith(responsibilities: value),
              );
            },
            style: TextStyle(
              color: AdminColors.getTextColor(isDark),
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: l10n.description,
              isDense: true,
              filled: true,
              fillColor: isDark
                  ? AdminColors.darkCard.withValues(alpha: 0.65)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateAssignment(int index, InstructorAssignmentDraft updated) {
    final next = List<InstructorAssignmentDraft>.from(assignments)
      ..[index] = updated;
    onAssignmentsChanged(next);
  }
}
