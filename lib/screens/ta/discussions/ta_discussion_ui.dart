import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/common/utils/responsive.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TADiscussionViewerContext {
  const TADiscussionViewerContext({
    required this.userId,
    required this.userName,
    required this.canModerate,
    required this.canEditAnyThread,
    required this.canDeleteAnyThread,
  });

  final int? userId;
  final String userName;
  final bool canModerate;
  final bool canEditAnyThread;
  final bool canDeleteAnyThread;
}

class TADiscussionComposerResult {
  const TADiscussionComposerResult({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

TADiscussionViewerContext resolveTADiscussionViewerContext(
  BuildContext context,
) {
  final authState = context.read<AuthBloc>().state;
  if (authState is! AuthAuthenticated) {
    return const TADiscussionViewerContext(
      userId: null,
      userName: '',
      canModerate: false,
      canEditAnyThread: false,
      canDeleteAnyThread: false,
    );
  }

  final roleNames = authState.user.roles
      .map((role) => role.roleName.toLowerCase().trim())
      .toSet();
  final isTA =
      roleNames.contains('ta') || roleNames.contains('teaching_assistant');
  final isInstructor = roleNames.contains('instructor');
  final isAdmin =
      roleNames.contains('admin') ||
      roleNames.contains('it_admin') ||
      roleNames.contains('it admin');

  return TADiscussionViewerContext(
    userId: authState.user.userId,
    userName: authState.user.displayName,
    canModerate: isTA || isInstructor || isAdmin,
    canEditAnyThread: isInstructor || isAdmin,
    canDeleteAnyThread: isInstructor || isAdmin,
  );
}

String taDiscussionFormatDate(BuildContext context, DateTime? value) {
  if (value == null) {
    return '—';
  }

  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
}

String taDiscussionDisplayName(BuildContext context, String providedName) {
  final trimmed = providedName.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  return AppLocalizations.of(context).unknown;
}

String taDiscussionInitials(String primary, [String? secondary]) {
  final safePrimary = primary.trim();
  final safeSecondary = secondary?.trim() ?? '';
  if (safePrimary.isEmpty && safeSecondary.isEmpty) {
    return 'ED';
  }

  final first = safePrimary.isNotEmpty ? safePrimary.characters.first : '';
  final second = safeSecondary.isNotEmpty
      ? safeSecondary.characters.first
      : (safePrimary.contains(' ')
            ? safePrimary
                      .split(' ')
                      .where((part) => part.trim().isNotEmpty)
                      .skip(1)
                      .firstOrNull
                      ?.characters
                      .first ??
                  ''
            : '');

  return '$first$second'.toUpperCase();
}

LinearGradient taDiscussionHeaderGradient(bool isDark) {
  return isDark ? TAColors.darkHeaderGradient : TAColors.headerGradient;
}

LinearGradient taDiscussionAccentGradient(int seed) {
  const gradients = <List<Color>>[
    <Color>[TAColors.primary, TAColors.secondary],
    <Color>[TAColors.teal, TAColors.success],
    <Color>[TAColors.primaryDark, TAColors.pink],
    <Color>[TAColors.orange, TAColors.warning],
  ];
  final colors = gradients[seed % gradients.length];
  return LinearGradient(
    colors: colors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

BoxDecoration taDiscussionCardDecoration(
  bool isDark, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: TAColors.cardColor(isDark),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? TAColors.primary.withValues(alpha: isDark ? 0.4 : 0.22)
          : TAColors.borderColor(isDark).withValues(alpha: 0.75),
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class TADiscussionSummaryHeader extends StatelessWidget {
  const TADiscussionSummaryHeader({
    super.key,
    required this.isDark,
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stats,
  });

  final bool isDark;
  final ResponsiveUtil responsive;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<({IconData icon, String label, String value, Color color})> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: taDiscussionHeaderGradient(isDark),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: TAColors.primary.withValues(alpha: isDark ? 0.28 : 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -36,
              right: -18,
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.isMobile ? 16 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 21),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.isMobile ? 18 : 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.84),
                                fontSize: responsive.isMobile ? 11.5 : 12,
                                height: 1.28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 360
                          ? 2
                          : (stats.length <= 4 ? 4 : 3);
                      const spacing = 8.0;
                      final itemWidth =
                          (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: stats
                            .map(
                              (stat) => SizedBox(
                                width: itemWidth,
                                child: TADiscussionHeaderStatCard(
                                  icon: stat.icon,
                                  label: stat.label,
                                  value: stat.value,
                                  color: stat.color,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TADiscussionHeaderStatCard extends StatelessWidget {
  const TADiscussionHeaderStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class TADiscussionFilterPanel extends StatelessWidget {
  const TADiscussionFilterPanel({
    super.key,
    required this.isDark,
    required this.badgeLabel,
    required this.children,
    this.footer,
  });

  final bool isDark;
  final String badgeLabel;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.7),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeLabel,
                style: const TextStyle(
                  color: TAColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
            if (footer != null) ...<Widget>[
              const SizedBox(height: 14),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class TADiscussionSearchField extends StatelessWidget {
  const TADiscussionSearchField({
    super.key,
    required this.isDark,
    required this.hintText,
    required this.value,
    required this.onChanged,
  });

  final bool isDark;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        filled: true,
        fillColor: isDark
            ? TAColors.surfaceColor(isDark).withValues(alpha: 0.75)
            : TAColors.surfaceColor(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TAColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class TADiscussionDropdown<T> extends StatelessWidget {
  const TADiscussionDropdown({
    super.key,
    required this.isDark,
    required this.label,
    required this.selectedLabel,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    required this.menuMaxHeight,
  });

  final bool isDark;
  final String label;
  final String selectedLabel;
  final T value;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: menuMaxHeight,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, size: 18, color: TAColors.primary),
        filled: true,
        fillColor: isDark
            ? TAColors.surfaceColor(isDark).withValues(alpha: 0.75)
            : TAColors.surfaceColor(isDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TAColors.primary, width: 1.4),
        ),
      ),
      dropdownColor: TAColors.cardColor(isDark),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: TAColors.primary,
      ),
      style: TextStyle(
        color: TAColors.textPrimaryColor(isDark),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      selectedItemBuilder: (context) {
        return items
            .map(
              (_) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false);
      },
      items: items,
      onChanged: onChanged,
    );
  }
}

class TADiscussionMetricChip extends StatelessWidget {
  const TADiscussionMetricChip({
    super.key,
    required this.color,
    required this.label,
    this.icon,
  });

  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class TADiscussionEmptyState extends StatelessWidget {
  const TADiscussionEmptyState({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: taDiscussionCardDecoration(isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: taDiscussionHeaderGradient(isDark),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<TADiscussionComposerResult?> showTADiscussionThreadComposer(
  BuildContext context, {
  TADiscussionComposerResult? initialValue,
}) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController(
    text: initialValue?.title ?? '',
  );
  final descriptionController = TextEditingController(
    text: initialValue?.description ?? '',
  );
  final formKey = GlobalKey<FormState>();
  final isEditing = initialValue != null;

  return showDialog<TADiscussionComposerResult>(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        title: Text(
          isEditing
              ? l10n.instructorDiscussionEditPostTitle
              : l10n.instructorDiscussionNewPostTitle,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: l10n.instructorDiscussionPostTitleLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return l10n.instructorDiscussionPostTitleRequired;
                    }
                    if (text.length < 4) {
                      return l10n.instructorDiscussionPostTitleMin;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.instructorDiscussionPostDescriptionLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return l10n.instructorDiscussionPostDescriptionRequired;
                    }
                    if (text.length < 10) {
                      return l10n.instructorDiscussionPostDescriptionMin;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              Navigator.of(dialogContext).pop(
                TADiscussionComposerResult(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? l10n.save : l10n.create),
          ),
        ],
      );
    },
  );
}

Future<String?> showTADiscussionReplyEditor(
  BuildContext context, {
  String initialValue = '',
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialValue);
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        title: Text(
          l10n.instructorDiscussionEditReply,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: l10n.reply,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return l10n.instructorDiscussionReplyRequired;
              }
              if (text.length < 2) {
                return l10n.instructorDiscussionReplyMin;
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
}

Future<bool> showTADiscussionConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  Color confirmColor = TAColors.error,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        title: Text(
          title,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
