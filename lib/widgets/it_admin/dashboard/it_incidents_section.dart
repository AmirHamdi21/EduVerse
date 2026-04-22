import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class ITIncidentsSection extends StatelessWidget {
  final bool isDark;
  final List<ITIncident> incidents;
  final VoidCallback? onViewAll;
  final Function(ITIncident)? onIncidentTap;
  final Function(ITIncident)? onResolve;

  const ITIncidentsSection({
    super.key,
    required this.isDark,
    required this.incidents,
    this.onViewAll,
    this.onIncidentTap,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ITColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: ITColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itActiveIncidents,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${incidents.length} ${l10n.itActive}',
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.itViewAll,
                    style: TextStyle(
                      color: ITColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (incidents.isEmpty)
            _buildEmptyState(l10n)
          else
            Column(
              children: incidents
                  .map((incident) => _buildIncidentItem(incident, l10n))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: ITColors.success,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.itNoActiveIncidents,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.itAllSystemsOperational,
            style: TextStyle(
              color: ITColors.textTertiaryColor(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentItem(ITIncident incident, AppLocalizations l10n) {
    final priorityColor = ITColors.getPriorityColor(incident.priority);
    final priorityBgColor = ITColors.getPriorityBgColor(incident.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onIncidentTap?.call(incident),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : priorityBgColor.withValues(alpha: 0.3),
              border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.priority.toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ITColors.surfaceColor(isDark),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        incident.service,
                        style: TextStyle(
                          color: ITColors.textSecondaryColor(isDark),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      incident.time,
                      style: TextStyle(
                        color: ITColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  incident.title,
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description,
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onResolve != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onResolve?.call(incident),
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: ITColors.success,
                        ),
                        label: Text(
                          l10n.itResolve,
                          style: TextStyle(
                            color: ITColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ITIncident {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String service;
  final String time;
  final String status;

  ITIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.service,
    required this.time,
    required this.status,
  });
}
