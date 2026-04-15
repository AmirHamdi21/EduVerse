import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String type; // 'card', 'paypal', 'bank', 'crypto'
  final bool isEnabled;
  final double fees;
  final int transactionCount;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
    required this.fees,
    required this.transactionCount,
  });

  PaymentMethod copyWith({bool? isEnabled}) {
    return PaymentMethod(
      id: id,
      name: name,
      type: type,
      isEnabled: isEnabled ?? this.isEnabled,
      fees: fees,
      transactionCount: transactionCount,
    );
  }
}

class PaymentMethodsCard extends StatelessWidget {
  final bool isDark;
  final List<PaymentMethod> methods;
  final ValueChanged<PaymentMethod> onToggle;
  final VoidCallback onAddMethod;
  final VoidCallback onManageAll;

  const PaymentMethodsCard({
    super.key,
    required this.isDark,
    required this.methods,
    required this.onToggle,
    required this.onAddMethod,
    required this.onManageAll,
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
                  gradient: AdminColors.greenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
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
                      l10n.paymentMethods,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.configurePaymentGateways,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAddMethod,
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: AdminColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...methods.map((method) => _buildMethodItem(context, method, l10n)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onManageAll,
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: Text(l10n.managePaymentGateways),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AdminColors.primary),
                foregroundColor: AdminColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem(
    BuildContext context,
    PaymentMethod method,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: method.isEnabled
              ? AdminColors.success.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getMethodColor(method.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getMethodIcon(method.type),
              color: _getMethodColor(method.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${method.fees}% ${l10n.fee}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${method.transactionCount} ${l10n.transactions}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: method.isEnabled,
            onChanged: (_) => onToggle(method),
            activeColor: AdminColors.success,
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'paypal':
        return Icons.account_balance_wallet_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getMethodColor(String type) {
    switch (type) {
      case 'card':
        return AdminColors.primary;
      case 'paypal':
        return const Color(0xFF003087);
      case 'bank':
        return AdminColors.accent;
      case 'crypto':
        return const Color(0xFFF7931A);
      default:
        return AdminColors.secondary;
    }
  }
}
