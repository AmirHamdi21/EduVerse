import 'package:flutter/material.dart';
import 'create_assignment_colors.dart';

class ProjectMilestone {
  final String id;
  final String title;
  final DateTime? dueDate;
  final int weight;
  final bool isCompleted;

  ProjectMilestone({
    required this.id,
    required this.title,
    this.dueDate,
    this.weight = 20,
    this.isCompleted = false,
  });

  ProjectMilestone copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    int? weight,
    bool? isCompleted,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ProjectDeliverable {
  final String id;
  final String name;
  final String type;
  final bool isRequired;

  ProjectDeliverable({
    required this.id,
    required this.name,
    required this.type,
    this.isRequired = true,
  });
}

class ProjectDetailsSection extends StatelessWidget {
  final TextEditingController scopeController;
  final TextEditingController objectivesController;
  final TextEditingController resourcesController;
  final List<ProjectMilestone> milestones;
  final List<ProjectDeliverable> deliverables;
  final int minTeamSize;
  final int maxTeamSize;
  final bool allowIndividual;
  final bool requirePresentation;
  final bool requireDocumentation;
  final bool peerReview;
  final bool isDark;
  final VoidCallback onAddMilestone;
  final Function(int, ProjectMilestone) onUpdateMilestone;
  final Function(int) onRemoveMilestone;
  final Function(String) onAddDeliverable;
  final Function(int) onRemoveDeliverable;
  final Function(int) onMinTeamSizeChanged;
  final Function(int) onMaxTeamSizeChanged;
  final Function(bool) onAllowIndividualChanged;
  final Function(bool) onRequirePresentationChanged;
  final Function(bool) onRequireDocumentationChanged;
  final Function(bool) onPeerReviewChanged;

  const ProjectDetailsSection({
    super.key,
    required this.scopeController,
    required this.objectivesController,
    required this.resourcesController,
    required this.milestones,
    required this.deliverables,
    required this.minTeamSize,
    required this.maxTeamSize,
    required this.allowIndividual,
    required this.requirePresentation,
    required this.requireDocumentation,
    required this.peerReview,
    required this.isDark,
    required this.onAddMilestone,
    required this.onUpdateMilestone,
    required this.onRemoveMilestone,
    required this.onAddDeliverable,
    required this.onRemoveDeliverable,
    required this.onMinTeamSizeChanged,
    required this.onMaxTeamSizeChanged,
    required this.onAllowIndividualChanged,
    required this.onRequirePresentationChanged,
    required this.onRequireDocumentationChanged,
    required this.onPeerReviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Scope
        _buildLabel('Project Scope', Icons.crop_free_rounded),
        const SizedBox(height: 8),
        _buildTextField(
          controller: scopeController,
          hintText: 'Define the boundaries and extent of the project...',
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Project Objectives
        _buildLabel('Learning Objectives', Icons.track_changes_rounded),
        const SizedBox(height: 8),
        _buildTextField(
          controller: objectivesController,
          hintText: 'What students will learn by completing this project...',
          maxLines: 2,
        ),
        const SizedBox(height: 20),

        // Team Configuration
        _buildTeamSection(),
        const SizedBox(height: 20),

        // Milestones Section
        _buildMilestonesSection(context),
        const SizedBox(height: 20),

        // Deliverables Section
        _buildDeliverablesSection(context),
        const SizedBox(height: 20),

        // Resources
        _buildLabel('Resources & References', Icons.library_books_outlined),
        const SizedBox(height: 8),
        _buildTextField(
          controller: resourcesController,
          hintText: 'Recommended readings, tools, or materials...',
          maxLines: 2,
        ),
        const SizedBox(height: 20),

        // Requirements Toggles
        _buildRequirementsSection(),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CreateAssignmentColors.project,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: CreateAssignmentColors.textPrimaryColor(isDark),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: CreateAssignmentColors.textTertiaryColor(isDark),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: CreateAssignmentColors.project,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CreateAssignmentColors.project.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.project.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 18,
                color: CreateAssignmentColors.project,
              ),
              const SizedBox(width: 8),
              Text(
                'Team Configuration',
                style: TextStyle(
                  color: CreateAssignmentColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Team Size Row
          Row(
            children: [
              Expanded(
                child: _buildTeamSizeSelector(
                  label: 'Min Team Size',
                  value: minTeamSize,
                  min: 1,
                  max: maxTeamSize,
                  onChanged: onMinTeamSizeChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTeamSizeSelector(
                  label: 'Max Team Size',
                  value: maxTeamSize,
                  min: minTeamSize,
                  max: 10,
                  onChanged: onMaxTeamSizeChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Allow Individual
          _buildToggleChip(
            icon: Icons.person_outline_rounded,
            label: 'Allow Individual Submission',
            isSelected: allowIndividual,
            onTap: () => onAllowIndividualChanged(!allowIndividual),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSizeSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? CreateAssignmentColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CreateAssignmentColors.borderColor(isDark),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: Icon(
                  Icons.remove_rounded,
                  size: 18,
                  color: value > min
                      ? CreateAssignmentColors.project
                      : CreateAssignmentColors.textTertiaryColor(isDark),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: value < max
                      ? CreateAssignmentColors.project
                      : CreateAssignmentColors.textTertiaryColor(isDark),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CreateAssignmentColors.project.withValues(alpha: 0.15)
              : (isDark ? CreateAssignmentColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? CreateAssignmentColors.project
                : CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              size: 18,
              color: isSelected
                  ? CreateAssignmentColors.project
                  : CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? CreateAssignmentColors.project
                    : CreateAssignmentColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 18,
                color: CreateAssignmentColors.project,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Project Milestones',
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildAddButton('Add', onAddMilestone),
            ],
          ),
          if (milestones.isEmpty) ...[
            const SizedBox(height: 16),
            _buildEmptyState(
              icon: Icons.timeline_rounded,
              message: 'No milestones yet. Add checkpoints for project progress.',
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              return _buildMilestoneCard(context, index, milestone);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, int index, ProjectMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? CreateAssignmentColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CreateAssignmentColors.project.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: CreateAssignmentColors.project,
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
                  milestone.title.isEmpty ? 'Milestone ${index + 1}' : milestone.title,
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${milestone.weight}% weight',
                  style: TextStyle(
                    color: CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMilestoneEditor(context, index, milestone),
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: () => onRemoveMilestone(index),
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: CreateAssignmentColors.error,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _showMilestoneEditor(BuildContext context, int index, ProjectMilestone milestone) {
    final titleController = TextEditingController(text: milestone.title);
    int weight = milestone.weight;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? CreateAssignmentColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit Milestone',
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(isDark),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(
                  color: CreateAssignmentColors.textPrimaryColor(isDark),
                ),
                decoration: InputDecoration(
                  labelText: 'Milestone Title',
                  labelStyle: TextStyle(
                    color: CreateAssignmentColors.textSecondaryColor(isDark),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Weight: ',
                    style: TextStyle(
                      color: CreateAssignmentColors.textSecondaryColor(isDark),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: weight.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: '$weight%',
                      activeColor: CreateAssignmentColors.project,
                      onChanged: (v) {
                        setDialogState(() => weight = v.toInt());
                      },
                    ),
                  ),
                  Text(
                    '$weight%',
                    style: TextStyle(
                      color: CreateAssignmentColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: CreateAssignmentColors.textSecondaryColor(isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onUpdateMilestone(
                  index,
                  milestone.copyWith(title: titleController.text, weight: weight),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CreateAssignmentColors.project,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverablesSection(BuildContext context) {
    final deliverableTypes = [
      ('Report', Icons.description_outlined),
      ('Code', Icons.code_rounded),
      ('Presentation', Icons.slideshow_rounded),
      ('Demo', Icons.play_circle_outline_rounded),
      ('Documentation', Icons.article_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: CreateAssignmentColors.project,
              ),
              const SizedBox(width: 8),
              Text(
                'Required Deliverables',
                style: TextStyle(
                  color: CreateAssignmentColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: deliverableTypes.map((type) {
              final isSelected = deliverables.any((d) => d.type == type.$1);
              return _buildDeliverableChip(
                icon: type.$2,
                label: type.$1,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    final idx = deliverables.indexWhere((d) => d.type == type.$1);
                    if (idx != -1) onRemoveDeliverable(idx);
                  } else {
                    onAddDeliverable(type.$1);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverableChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CreateAssignmentColors.project
              : (isDark ? CreateAssignmentColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CreateAssignmentColors.project
                : CreateAssignmentColors.borderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_rounded : icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : CreateAssignmentColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : CreateAssignmentColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Additional Requirements', Icons.checklist_rounded),
        const SizedBox(height: 12),
        _buildRequirementToggle(
          icon: Icons.present_to_all_rounded,
          title: 'Final Presentation',
          subtitle: 'Teams must present their project',
          value: requirePresentation,
          onChanged: onRequirePresentationChanged,
        ),
        const SizedBox(height: 8),
        _buildRequirementToggle(
          icon: Icons.menu_book_rounded,
          title: 'Technical Documentation',
          subtitle: 'Include full project documentation',
          value: requireDocumentation,
          onChanged: onRequireDocumentationChanged,
        ),
        const SizedBox(height: 8),
        _buildRequirementToggle(
          icon: Icons.rate_review_outlined,
          title: 'Peer Review',
          subtitle: 'Teams review each other\'s work',
          value: peerReview,
          onChanged: onPeerReviewChanged,
        ),
      ],
    );
  }

  Widget _buildRequirementToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? CreateAssignmentColors.project.withValues(alpha: 0.5)
              : CreateAssignmentColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value
                ? CreateAssignmentColors.project
                : CreateAssignmentColors.textTertiaryColor(isDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: CreateAssignmentColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: CreateAssignmentColors.project,
            activeThumbColor: Colors.white,
            inactiveThumbColor: CreateAssignmentColors.textTertiaryColor(isDark),
            inactiveTrackColor: CreateAssignmentColors.borderColor(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: CreateAssignmentColors.project.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: 16,
              color: CreateAssignmentColors.project,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: CreateAssignmentColors.project,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: CreateAssignmentColors.textTertiaryColor(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CreateAssignmentColors.textTertiaryColor(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
