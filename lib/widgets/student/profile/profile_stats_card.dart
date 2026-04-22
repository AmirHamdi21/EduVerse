import 'package:flutter/material.dart';
import '../../../bloc/profile/profile_models.dart';
import '../../../generated_l10n/app_localizations.dart';

class ProfileStatsCard extends StatelessWidget {
  final UserProfile profile;
  final bool isDark;

  const ProfileStatsCard({
    super.key,
    required this.profile,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.school_rounded,
            value: profile.coursesEnrolled.toString(),
            label: l10n.coursesEnrolled,
            color: const Color(0xFF3B82F6),
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.assignment_turned_in_rounded,
            value: profile.assignmentsCompleted.toString(),
            label: l10n.assignmentsCompleted,
            color: const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.grade_rounded,
            value: profile.gpa.toStringAsFixed(1),
            label: l10n.gpa,
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
