import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval; // 'monthly', 'yearly', 'lifetime'
  final int subscriberCount;
  final bool isActive;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.subscriberCount,
    required this.isActive,
    required this.features,
  });

  SubscriptionPlan copyWith({bool? isActive}) {
    return SubscriptionPlan(
      id: id,
      name: name,
      description: description,
      price: price,
      interval: interval,
      subscriberCount: subscriberCount,
      isActive: isActive ?? this.isActive,
      features: features,
    );
  }
}

class SubscriptionPlansCard extends StatelessWidget {
  final bool isDark;
  final List<SubscriptionPlan> plans;
  final Function(SubscriptionPlan) onEdit;
  final Function(SubscriptionPlan) onToggle;
  final VoidCallback onAddPlan;

  const SubscriptionPlansCard({
    super.key,
    required this.isDark,
    required this.plans,
    required this.onEdit,
    required this.onToggle,
    required this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
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
                  gradient: AdminColors.orangeGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subscriptionPlans,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.managePricingPlans,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddPlan,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addPlan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...plans.map((plan) => _buildPlanItem(context, plan, l10n)),
        ],
      ),
    );
  }

  Widget _buildPlanItem(
    BuildContext context,
    SubscriptionPlan plan,
    AppLocalizations l10n,
  ) {
    final planColor = _getPlanColor(plan.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: plan.isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  planColor.withValues(alpha: 0.1),
                  planColor.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: plan.isActive
            ? null
            : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isActive
              ? planColor.withValues(alpha: 0.4)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: planColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPlanIcon(plan.name),
                  color: planColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!plan.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AdminColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.inactive,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AdminColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      plan.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${plan.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: planColor,
                    ),
                  ),
                  Text(
                    '/${_getIntervalLabel(l10n, plan.interval)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                size: 14,
                color: AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                '${plan.subscriberCount} ${l10n.subscribers}',
                style: TextStyle(
                  fontSize: 12,
                  color: AdminColors.getTextColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => onEdit(plan),
                icon: Icon(Icons.edit_rounded, size: 16, color: AdminColors.primary),
                label: Text(
                  l10n.edit,
                  style: TextStyle(color: AdminColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: plan.isActive,
                onChanged: (_) => onToggle(plan),
                activeColor: AdminColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('premium') || lowerName.contains('pro')) {
      return const Color(0xFFFFD700);
    } else if (lowerName.contains('enterprise') || lowerName.contains('business')) {
      return AdminColors.secondary;
    } else if (lowerName.contains('basic') || lowerName.contains('free')) {
      return AdminColors.accent;
    }
    return AdminColors.primary;
  }

  IconData _getPlanIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('premium') || lowerName.contains('pro')) {
      return Icons.workspace_premium_rounded;
    } else if (lowerName.contains('enterprise') || lowerName.contains('business')) {
      return Icons.business_rounded;
    } else if (lowerName.contains('basic') || lowerName.contains('free')) {
      return Icons.star_outline_rounded;
    }
    return Icons.card_membership_rounded;
  }

  String _getIntervalLabel(AppLocalizations l10n, String interval) {
    switch (interval) {
      case 'monthly':
        return l10n.month;
      case 'yearly':
        return l10n.year;
      case 'lifetime':
        return l10n.lifetime;
      default:
        return interval;
    }
  }
}
