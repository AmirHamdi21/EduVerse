import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITIncidentDetailSheet extends StatelessWidget {
  final bool isDark;
  final SecurityIncident incident;
  final VoidCallback onBlockIps;
  final VoidCallback onMarkResolved;
  final VoidCallback onCreateReport;
  final VoidCallback onClose;

  const ITIncidentDetailSheet({
    super.key,
    required this.isDark,
    required this.incident,
    required this.onBlockIps,
    required this.onMarkResolved,
    required this.onCreateReport,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(
                          incident.severity,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: _getSeverityColor(incident.severity),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Security Logs &',
                                style: TextStyle(
                                  color: ITColors.textTertiaryColor(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Incident Details & Response Actions',
                            style: TextStyle(
                              color: ITColors.textPrimaryColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close_rounded,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Incident title and severity
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        incident.title,
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildSeverityBadge(),
                  ],
                ),
                if (incident.status == IncidentStatus.resolved)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ITColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: ITColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Resolved',
                          style: TextStyle(
                            color: ITColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Description
                Text(
                  'Description:',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  incident.description,
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Investigation Notes
                Text(
                  'Investigation Notes:',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : ITColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : ITColors.border,
                    ),
                  ),
                  child: Text(
                    incident.investigationNotes ??
                        'Add notes about investigation and response...',
                    style: TextStyle(
                      color: incident.investigationNotes != null
                          ? ITColors.textSecondaryColor(isDark)
                          : ITColors.textTertiaryColor(isDark),
                      fontSize: 13,
                      fontStyle: incident.investigationNotes == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                if (incident.assignedTo != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Assigned To:',
                        style: TextStyle(
                          color: ITColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ITColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          incident.assignedTo!,
                          style: TextStyle(
                            color: ITColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                // Quick Response Actions
                Text(
                  'Quick Response Actions',
                  style: TextStyle(
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.block_rounded,
                  label: 'Block All Related IPs',
                  color: ITColors.error,
                  onTap: onBlockIps,
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.check_circle_rounded,
                  label: 'Mark Resolved',
                  color: ITColors.success,
                  onTap: onMarkResolved,
                ),
                const SizedBox(height: 20),
                // Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCreateReport,
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Create Report'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ITColors.primary,
                          side: BorderSide(color: ITColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : ITColors.surface,
                          foregroundColor: ITColors.textPrimaryColor(isDark),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSeverityColor(incident.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(incident.severity),
            color: _getSeverityColor(incident.severity),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            _getSeverityLabel(incident.severity),
            style: TextStyle(
              color: _getSeverityColor(incident.severity),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
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
        return 'In Progress';
      case IncidentSeverity.warning:
        return 'Warning';
      case IncidentSeverity.info:
        return 'Info';
    }
  }
}
