import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITActiveIncidentsSection extends StatelessWidget {
  final bool isDark;
  final List<SecurityIncident> incidents;
  final Function(SecurityIncident) onHide;
  final Function(SecurityIncident) onViewDetails;

  const ITActiveIncidentsSection({
    super.key,
    required this.isDark,
    required this.incidents,
    required this.onHide,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ITColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: ITColors.error, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Active Incidents',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ITColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                incidents.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...incidents.map((incident) => _buildIncidentCard(incident)),
      ],
    );
  }

  Widget _buildIncidentCard(SecurityIncident incident) {
    return GestureDetector(
      onTap: () => onViewDetails(incident),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getSeverityColor(incident.severity).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: ITColors.lightCardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getSeverityColor(incident.severity).withValues(alpha: 0.15),
                    _getSeverityColor(incident.severity).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(incident.severity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSeverityIcon(incident.severity),
                      color: _getSeverityColor(incident.severity),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.title,
                          style: TextStyle(
                            color: ITColors.textPrimaryColor(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildSeverityBadge(incident.severity),
                            const SizedBox(width: 8),
                            if (incident.affectedAccounts > 0)
                              Text(
                                '${incident.affectedAccounts} accounts',
                                style: TextStyle(
                                  color: ITColors.textTertiaryColor(isDark),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onHide(incident),
                    style: TextButton.styleFrom(
                      foregroundColor: _getSeverityColor(incident.severity),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Hide',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.description,
                    style: TextStyle(
                      color: ITColors.textSecondaryColor(isDark),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: ITColors.textTertiaryColor(isDark)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(incident.detectedAt),
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(IncidentSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getSeverityLabel(severity),
        style: TextStyle(
          color: _getSeverityColor(severity),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return ITColors.error;
      case IncidentSeverity.warning:
        return ITColors.warning;
      case IncidentSeverity.info:
        return ITColors.info;
    }
  }

  IconData _getSeverityIcon(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return Icons.gpp_bad_rounded;
      case IncidentSeverity.warning:
        return Icons.warning_rounded;
      case IncidentSeverity.info:
        return Icons.info_rounded;
    }
  }

  String _getSeverityLabel(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return 'CRITICAL';
      case IncidentSeverity.warning:
        return 'WARNING';
      case IncidentSeverity.info:
        return 'INFO';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
