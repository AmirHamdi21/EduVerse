import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITSecurityPoliciesSection extends StatelessWidget {
  final bool isDark;
  final List<SecurityPolicy> policies;
  final Function(SecurityPolicy, bool) onTogglePolicy;
  final Function(SecurityPolicy) onConfigure;

  const ITSecurityPoliciesSection({
    super.key,
    required this.isDark,
    required this.policies,
    required this.onTogglePolicy,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Policies & MFA',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...policies.map((policy) => _buildPolicyCard(policy)),
      ],
    );
  }

  Widget _buildPolicyCard(SecurityPolicy policy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : ITColors.border,
        ),
        boxShadow: ITColors.lightCardShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ITColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getPolicyIcon(policy.id),
              color: ITColors.primary,
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
                    color: ITColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  policy.description,
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                  ),
                ),
                if (policy.value != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ITColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      policy.value!,
                      style: TextStyle(
                        color: ITColors.info,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (policy.configureAction != null)
            TextButton(
              onPressed: () => onConfigure(policy),
              style: TextButton.styleFrom(
                foregroundColor: ITColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                policy.configureAction!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )
          else
            Switch.adaptive(
              value: policy.isEnabled,
              onChanged: (value) => onTogglePolicy(policy, value),
              activeThumbColor: ITColors.primary,
              activeTrackColor: ITColors.primary.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }

  IconData _getPolicyIcon(String policyId) {
    switch (policyId) {
      case 'mfa':
        return Icons.security_rounded;
      case 'password':
        return Icons.password_rounded;
      case 'session':
        return Icons.timer_rounded;
      case 'ipBlocklist':
        return Icons.block_rounded;
      case 'rateLimit':
        return Icons.speed_rounded;
      default:
        return Icons.policy_rounded;
    }
  }
}
