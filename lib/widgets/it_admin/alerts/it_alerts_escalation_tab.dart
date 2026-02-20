import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsEscalationTab extends StatelessWidget {
  final bool isDark;
  final List<EscalationPolicy> policies;
  final ValueChanged<EscalationPolicy> onPolicyTap;
  final VoidCallback onCreatePolicy;

  const ITAlertsEscalationTab({
    super.key,
    required this.isDark,
    required this.policies,
    required this.onPolicyTap,
    required this.onCreatePolicy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ITColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ITColors.cardShadow(isDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ITColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: ITColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalation Policies',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Define multi-step alert escalation workflows',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCreatePolicy,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ITColors.teal, ITColors.teal.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Create Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Policies list
        if (policies.isEmpty)
          _buildEmptyState()
        else
          ...policies.map((policy) => _buildPolicyCard(policy)),
      ],
    );
  }

  Widget _buildPolicyCard(EscalationPolicy policy) {
    return GestureDetector(
      onTap: () => onPolicyTap(policy),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ITColors.cardShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ITColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.escalator_rounded,
                    color: ITColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        policy.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: policy.isEnabled
                        ? ITColors.success.withValues(alpha: 0.15)
                        : ITColors.textSecondaryColor(isDark).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    policy.isEnabled ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: policy.isEnabled
                          ? ITColors.success
                          : ITColors.textSecondaryColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Steps info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.format_list_numbered_rounded,
                    size: 16,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${policy.steps.length} steps',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            
            // Steps visualization
            ...policy.steps.map((step) => _buildStepItem(step, policy.steps.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(EscalationStep step, int totalSteps) {
    final isLast = step.stepNumber == totalSteps;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ITColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${step.stepNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ITColors.primary,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTargetIcon(step.targetType),
                  size: 16,
                  color: ITColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.target,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      Text(
                        step.targetType,
                        style: TextStyle(
                          fontSize: 11,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ITColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${step.delayAfter.inMinutes}m',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ITColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.account_tree_rounded,
              size: 48,
              color: ITColors.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No escalation policies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create policies to escalate unacknowledged alerts',
              style: TextStyle(
                fontSize: 13,
                color: ITColors.textSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTargetIcon(String targetType) {
    switch (targetType.toLowerCase()) {
      case 'slack':
        return Icons.tag_rounded;
      case 'pagerduty':
        return Icons.phone_in_talk_rounded;
      case 'email team':
        return Icons.group_rounded;
      case 'sms manager':
        return Icons.sms_rounded;
      case 'on-call engineer':
        return Icons.engineering_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
