import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';

class TACourseLabsTab extends StatelessWidget {
  final bool isDark;
  final List<TALabItem> labs;
  final Function(TALabItem)? onOpenLab;
  final Function(TALabItem)? onReview;
  final Function(TALabItem)? onAttendance;
  final Function(TALabItem)? onUpload;

  const TACourseLabsTab({
    super.key,
    required this.isDark,
    required this.labs,
    this.onOpenLab,
    this.onReview,
    this.onAttendance,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (labs.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return Column(
      children: labs.map((lab) => _buildLabCard(lab, l10n, context)).toList(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.science_rounded,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.taCourseNoLabs,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taCourseNoLabsDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(
    TALabItem lab,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  color: TAColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.science_rounded,
                  color: TAColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lab.subtitle,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(lab.status, l10n),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(lab.progress, lab.attended, lab.total, l10n),
          const SizedBox(height: 16),
          _buildActionButtons(lab, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TALabStatus status, AppLocalizations l10n) {
    final isActive = status == TALabStatus.active;
    final color = isActive
        ? TAColors.success
        : TAColors.textSecondaryColor(isDark);
    final bgColor = isActive
        ? TAColors.success.withValues(alpha: 0.1)
        : TAColors.borderColor(isDark);
    final label = isActive ? l10n.taCourseLabActive : l10n.taCourseLabClosed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    double progress,
    int attended,
    int total,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.taCourseLabAttendance,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            Text(
              '$attended / $total ${l10n.taCourseLabStudents}',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: TAColors.borderColor(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(TAColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TALabItem lab, AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          icon: Icons.open_in_new_rounded,
          label: l10n.taCourseLabOpen,
          onTap: () => onOpenLab?.call(lab),
        ),
        _buildActionButton(
          icon: Icons.rate_review_rounded,
          label: l10n.taCourseLabReview,
          onTap: () => onReview?.call(lab),
        ),
        _buildActionButton(
          icon: Icons.check_circle_outline_rounded,
          label: l10n.taCourseLabAttendanceBtn,
          onTap: () => onAttendance?.call(lab),
        ),
        _buildActionButton(
          icon: Icons.upload_file_rounded,
          label: l10n.taCourseLabUpload,
          onTap: () => onUpload?.call(lab),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: TAColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TAColors.borderColor(isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: TAColors.textSecondaryColor(isDark)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TALabItem {
  final String id;
  final String title;
  final String subtitle;
  final TALabStatus status;
  final double progress;
  final int attended;
  final int total;

  TALabItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
    required this.attended,
    required this.total,
  });
}

enum TALabStatus { active, closed }
