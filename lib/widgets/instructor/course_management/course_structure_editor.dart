import 'package:flutter/material.dart';

import '../../../models/core/course_structure_model.dart';
import 'course_management_colors.dart';
import 'structure_item_card.dart';

typedef CreateStructureItemCallback =
    void Function(String title, int weekNumber, String? description);
typedef UpdateStructureItemCallback =
    void Function(
      CourseStructureModel item,
      String title,
      int weekNumber,
      String? description,
    );
typedef DeleteStructureItemCallback = void Function(CourseStructureModel item);
typedef ReorderStructureItemsCallback = void Function(List<int> orderedIds);

class CourseStructureEditor extends StatelessWidget {
  final List<CourseStructureModel> items;
  final Map<int, int> materialCountsByWeek;
  final bool isDark;
  final CreateStructureItemCallback? onCreate;
  final UpdateStructureItemCallback? onUpdate;
  final DeleteStructureItemCallback? onDelete;
  final ReorderStructureItemsCallback? onReorder;

  const CourseStructureEditor({
    super.key,
    required this.items,
    required this.materialCountsByWeek,
    required this.isDark,
    this.onCreate,
    this.onUpdate,
    this.onDelete,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        isDark: isDark,
        onCreate: () => _showCreateDialog(context),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Course Structure',
                  style: TextStyle(
                    color: CMColors.text(isDark),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Week'),
                style: FilledButton.styleFrom(
                  backgroundColor: CMColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final materialCount = materialCountsByWeek[item.weekNumber] ?? 0;

              return StructureItemCard(
                item: item,
                materialCount: materialCount,
                isDark: isDark,
                onMoveUp: index == 0 ? null : () => _move(index, index - 1),
                onMoveDown: index == items.length - 1
                    ? null
                    : () => _move(index, index + 1),
                onEdit: () => _showEditDialog(context, item),
                onDelete: () => _showDeleteDialog(context, item, materialCount),
              );
            },
          ),
        ),
      ],
    );
  }

  void _move(int from, int to) {
    if (onReorder == null || from == to || from < 0 || to < 0) {
      return;
    }

    final reordered = List<CourseStructureModel>.from(items);
    final moved = reordered.removeAt(from);
    reordered.insert(to, moved);

    final ids = reordered
        .map((item) => item.id)
        .where((id) => id > 0)
        .toList(growable: false);

    if (ids.isNotEmpty) {
      onReorder!(ids);
    }
  }

  void _showCreateDialog(BuildContext context) {
    _showItemDialog(
      context,
      title: 'Create Week',
      confirmLabel: 'Create',
      onConfirm: (name, weekNumber, description) {
        onCreate?.call(name, weekNumber, description);
      },
    );
  }

  void _showEditDialog(BuildContext context, CourseStructureModel item) {
    _showItemDialog(
      context,
      title: 'Edit Week',
      confirmLabel: 'Save',
      initialTitle: item.title,
      initialWeek: item.weekNumber,
      initialDescription: item.description,
      onConfirm: (name, weekNumber, description) {
        onUpdate?.call(item, name, weekNumber, description);
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CourseStructureModel item,
    int materialCount,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Structure Item?'),
          content: Text(
            materialCount > 0
                ? 'Materials in this week will become ungrouped (not deleted).'
                : 'This item will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDelete?.call(item);
              },
              style: FilledButton.styleFrom(backgroundColor: CMColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDialog(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? initialTitle,
    int? initialWeek,
    String? initialDescription,
    required void Function(String title, int week, String? description)
    onConfirm,
  }) {
    var draftTitle = initialTitle ?? '';
    var draftDescription = initialDescription ?? '';
    var draftWeek = (initialWeek ?? 1).toString();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey<String>('structure-title-field'),
                initialValue: draftTitle,
                onChanged: (value) => draftTitle = value,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey<String>('structure-week-field'),
                initialValue: draftWeek,
                onChanged: (value) => draftWeek = value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Week Number'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey<String>('structure-description-field'),
                initialValue: draftDescription,
                onChanged: (value) => draftDescription = value,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = draftTitle.trim();
                final week = int.tryParse(draftWeek.trim()) ?? 1;

                if (name.isEmpty || week <= 0) {
                  return;
                }

                Navigator.pop(ctx);
                onConfirm(
                  name,
                  week,
                  draftDescription.trim().isEmpty
                      ? null
                      : draftDescription.trim(),
                );
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCreate;

  const _EmptyState({required this.isDark, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: CMColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.timeline_rounded,
                color: CMColors.textSub(isDark),
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Structure Yet',
              style: TextStyle(
                color: CMColors.text(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create week items to organize lectures and materials.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CMColors.textSub(isDark), fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Week'),
              style: FilledButton.styleFrom(backgroundColor: CMColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
