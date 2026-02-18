import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class SecurityPolicyItem {
  final String id;
  final String name;
  final String description;
  final String status;
  final IconData icon;
  final Color color;
  final VoidCallback onConfigure;

  const SecurityPolicyItem({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.icon,
    required this.color,
    required this.onConfigure,
  });
}

class SecurityPoliciesCard extends StatelessWidget {
  final bool isDark;
  final List<SecurityPolicyItem> policies;

  const SecurityPoliciesCard({
    super.key,
    required this.isDark,
    required this.policies,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: AdminColors.chartPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.policy_rounded,
                  color: AdminColors.chartPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.securityPolicies,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      l10n.securityPoliciesDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...policies.map((policy) => _buildPolicyItem(policy, l10n)),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(SecurityPolicyItem policy, AppLocalizations l10n) {
    final isEnabled = policy.status.toLowerCase() == 'enabled' || 
                      policy.status.toLowerCase() == 'strong' ||
                      policy.status.toLowerCase() == 'active';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: policy.onConfigure,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: policy.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    policy.icon,
                    color: policy.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        policy.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        policy.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AdminColors.success.withValues(alpha: 0.15)
                        : AdminColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    policy.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? AdminColors.success : AdminColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AdminColors.getTextTertiaryColor(isDark),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
