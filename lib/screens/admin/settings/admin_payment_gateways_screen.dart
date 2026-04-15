import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminPaymentGatewaysScreen extends StatefulWidget {
  const AdminPaymentGatewaysScreen({super.key});

  @override
  State<AdminPaymentGatewaysScreen> createState() =>
      _AdminPaymentGatewaysScreenState();
}

class _AdminPaymentGatewaysScreenState
    extends State<AdminPaymentGatewaysScreen> {
  final List<_PaymentGateway> _gateways = [
    _PaymentGateway(
      id: '1',
      name: 'Stripe',
      icon: Icons.credit_card_rounded,
      color: const Color(0xFF635BFF),
      isEnabled: true,
      isConfigured: true,
    ),
    _PaymentGateway(
      id: '2',
      name: 'PayPal',
      icon: Icons.payment_rounded,
      color: const Color(0xFF003087),
      isEnabled: true,
      isConfigured: true,
    ),
    _PaymentGateway(
      id: '3',
      name: 'Apple Pay',
      icon: Icons.apple_rounded,
      color: const Color(0xFF000000),
      isEnabled: false,
      isConfigured: false,
    ),
    _PaymentGateway(
      id: '4',
      name: 'Google Pay',
      icon: Icons.g_mobiledata_rounded,
      color: const Color(0xFF4285F4),
      isEnabled: false,
      isConfigured: false,
    ),
  ];

  String _currency = 'USD';
  bool _testMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildRevenueCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildSettingsSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildGatewaysSection(isDark, l10n, responsive),
                  SizedBox(height: responsive.p16),
                  _buildRecentTransactions(isDark, l10n, responsive),
                  SizedBox(height: responsive.p32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.paymentGateways,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildRevenueCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AdminColors.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.success.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.attach_money_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalRevenue,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\$124,567.89',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.trending_up_rounded,
                  label: l10n.thisMonth,
                  value: '\$12,450',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.transactions,
                  value: '1,847',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.people_rounded,
                  label: l10n.paidUsers,
                  value: '523',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: AdminColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.paymentSettings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.defaultCurrency,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AdminColors.getBackgroundColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AdminColors.getDividerColor(isDark),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currency,
                          isExpanded: true,
                          dropdownColor: AdminColors.getCardColor(isDark),
                          style: TextStyle(
                            color: AdminColors.getTextColor(isDark),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
                          items: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _currency = v ?? 'USD'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.testMode,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _testMode
                          ? AdminColors.warning.withValues(alpha: 0.1)
                          : AdminColors.getBackgroundColor(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _testMode
                            ? AdminColors.warning
                            : AdminColors.getDividerColor(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_testMode)
                          Icon(
                            Icons.warning_rounded,
                            size: 16,
                            color: AdminColors.warning,
                          ),
                        if (_testMode) const SizedBox(width: 4),
                        Switch.adaptive(
                          value: _testMode,
                          onChanged: (v) => setState(() => _testMode = v),
                          activeColor: AdminColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGatewaysSection(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paymentMethods,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        SizedBox(height: responsive.p12),
        ..._gateways.map((gateway) => _buildGatewayCard(gateway, isDark, l10n)),
      ],
    );
  }

  Widget _buildGatewayCard(
    _PaymentGateway gateway,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: gateway.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(gateway.icon, color: gateway.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gateway.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (gateway.isConfigured
                                          ? AdminColors.success
                                          : Colors.grey)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              gateway.isConfigured
                                  ? l10n.configured
                                  : l10n.notConfigured,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: gateway.isConfigured
                                    ? AdminColors.success
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: gateway.isEnabled,
                  onChanged: gateway.isConfigured
                      ? (v) => setState(() => gateway.isEnabled = v)
                      : null,
                  activeColor: AdminColors.success,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AdminColors.getDividerColor(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextButton.icon(
              onPressed: () =>
                  _showConfigureDialog(context, gateway, isDark, l10n),
              icon: Icon(
                Icons.settings_rounded,
                size: 18,
                color: AdminColors.primary,
              ),
              label: Text(
                l10n.configure,
                style: TextStyle(color: AdminColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    final transactions = [
      _Transaction(
        id: '#TXN-001',
        user: 'John Doe',
        amount: 49.99,
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _Transaction(
        id: '#TXN-002',
        user: 'Jane Smith',
        amount: 99.99,
        status: 'completed',
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      _Transaction(
        id: '#TXN-003',
        user: 'Bob Wilson',
        amount: 29.99,
        status: 'pending',
        date: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
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
                      color: AdminColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AdminColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.recentTransactions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(color: AdminColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...transactions.map(
            (txn) => _buildTransactionItem(txn, isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    _Transaction txn,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isCompleted = txn.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCompleted ? AdminColors.success : AdminColors.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isCompleted ? AdminColors.success : AdminColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.user,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                Text(
                  txn.id,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.success,
                ),
              ),
              Text(
                _formatTime(txn.date),
                style: TextStyle(
                  fontSize: 11,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showConfigureDialog(
    BuildContext context,
    _PaymentGateway gateway,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: gateway.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(gateway.icon, color: gateway.color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              '${l10n.configure} ${gateway.name}',
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: l10n.publishableKey,
                hintText: 'pk_live_...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.secretKey,
                hintText: 'sk_live_...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => gateway.isConfigured = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.paymentGatewayConfigured),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdminColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gateway.color,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _PaymentGateway {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  bool isEnabled;
  bool isConfigured;

  _PaymentGateway({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isEnabled,
    required this.isConfigured,
  });
}

class _Transaction {
  final String id;
  final String user;
  final double amount;
  final String status;
  final DateTime date;

  _Transaction({
    required this.id,
    required this.user,
    required this.amount,
    required this.status,
    required this.date,
  });
}
