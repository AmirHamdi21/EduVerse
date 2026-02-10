import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TATaskCenterSection extends StatefulWidget {
  final bool isDark;
  final List<TATaskModel> tasks;
  final Function(TATaskModel task)? onTaskTap;
  final Function(TATaskModel task)? onStartTask;
  final VoidCallback? onViewAll;

  const TATaskCenterSection({
    super.key,
    required this.isDark,
    required this.tasks,
    this.onTaskTap,
    this.onStartTask,
    this.onViewAll,
  });

  @override
  State<TATaskCenterSection> createState() => _TATaskCenterSectionState();
}

class _TATaskCenterSectionState extends State<TATaskCenterSection> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filteredTasks = _selectedFilter == 'all'
        ? widget.tasks
        : widget.tasks
            .where((task) => task.type.toLowerCase() == _selectedFilter)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.taTaskCenter,
              style: TextStyle(
                color: TAColors.textPrimaryColor(widget.isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: widget.onViewAll,
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFilterChips(l10n),
        const SizedBox(height: 16),
        if (filteredTasks.isEmpty)
          _buildEmptyState(l10n)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _buildTaskCard(task, l10n);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      _FilterOption(id: 'all', label: l10n.taAllTasks, icon: Icons.list_rounded),
      _FilterOption(id: 'grading', label: l10n.taGrading, icon: Icons.grading_rounded),
      _FilterOption(id: 'review', label: l10n.taReviews, icon: Icons.rate_review_rounded),
      _FilterOption(id: 'discussion', label: l10n.taDiscussions, icon: Icons.forum_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter.id;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TAColors.primary
                        : TAColors.cardColor(widget.isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? TAColors.primary
                          : TAColors.borderColor(widget.isDark),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : TAColors.textSecondaryColor(widget.isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : TAColors.textPrimaryColor(widget.isDark),
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 48,
            color: TAColors.textTertiaryColor(widget.isDark),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.taNoTasksInCategory,
            style: TextStyle(
              color: TAColors.textSecondaryColor(widget.isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TATaskModel task, AppLocalizations l10n) {
    final priorityColor = TAColors.getPriorityColor(task.priority);
    final typeColor = TAColors.getTaskTypeColor(task.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTaskTap?.call(task),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TAColors.cardColor(widget.isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                      color: typeColor.withValues(alpha: widget.isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      TAColors.getTaskTypeIcon(task.type),
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: TAColors.textPrimaryColor(widget.isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.courseCode,
                          style: TextStyle(
                            color: TAColors.textSecondaryColor(widget.isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(widget.isDark),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskInfo(
                    icon: Icons.description_rounded,
                    label: '${task.submissionCount} ${l10n.taSubmissions}',
                  ),
                  const SizedBox(width: 16),
                  _buildTaskInfo(
                    icon: Icons.schedule_rounded,
                    label: task.dueDate,
                  ),
                  const Spacer(),
                  _buildStartButton(task, l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: TAColors.textTertiaryColor(widget.isDark),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(widget.isDark),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(TATaskModel task, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onStartTask?.call(task),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: TAColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.taStart,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterOption {
  final String id;
  final String label;
  final IconData icon;

  _FilterOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class TATaskModel {
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final String type;
  final String priority;
  final int submissionCount;
  final String dueDate;

  TATaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.courseCode,
    required this.type,
    required this.priority,
    this.submissionCount = 0,
    required this.dueDate,
  });
}
