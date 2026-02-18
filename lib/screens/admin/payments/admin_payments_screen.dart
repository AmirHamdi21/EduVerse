import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/payments/payments_barrel.dart';
import '../../../common/utils/responsive.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _transactionFilter;

  // Sample data
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      userName: 'John Doe',
      userEmail: 'john@example.com',
      amount: 99.99,
      type: 'subscription',
      status: 'completed',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      paymentMethod: 'Visa •••• 4242',
    ),
    Transaction(
      id: '2',
      userName: 'Jane Smith',
      userEmail: 'jane@example.com',
      amount: 49.99,
      type: 'course',
      status: 'completed',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      paymentMethod: 'PayPal',
    ),
    Transaction(
      id: '3',
      userName: 'Mike Johnson',
      userEmail: 'mike@example.com',
      amount: 199.99,
      type: 'subscription',
      status: 'pending',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      paymentMethod: 'Mastercard •••• 5555',
    ),
    Transaction(
      id: '4',
      userName: 'Sarah Williams',
      userEmail: 'sarah@example.com',
      amount: 29.99,
      type: 'course',
      status: 'failed',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'Visa •••• 1234',
    ),
    Transaction(
      id: '5',
      userName: 'Alex Brown',
      userEmail: 'alex@example.com',
      amount: 99.99,
      type: 'refund',
      status: 'refunded',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'PayPal',
    ),
  ];

  late List<PaymentMethod> _paymentMethods;
  late List<SubscriptionPlan> _subscriptionPlans;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    _paymentMethods = [
      const PaymentMethod(
        id: '1',
        name: 'Stripe',
        type: 'card',
        isEnabled: true,
        fees: 2.9,
        transactionCount: 1250,
      ),
      const PaymentMethod(
        id: '2',
        name: 'PayPal',
        type: 'paypal',
        isEnabled: true,
        fees: 3.4,
        transactionCount: 856,
      ),
      const PaymentMethod(
        id: '3',
        name: 'Bank Transfer',
        type: 'bank',
        isEnabled: false,
        fees: 1.0,
        transactionCount: 124,
      ),
      const PaymentMethod(
        id: '4',
        name: 'Crypto',
        type: 'crypto',
        isEnabled: false,
        fees: 0.5,
        transactionCount: 45,
      ),
    ];

    _subscriptionPlans = [
      const SubscriptionPlan(
        id: '1',
        name: 'Basic',
        description: 'Perfect for individual learners',
        price: 9.99,
        interval: 'monthly',
        subscriberCount: 2450,
        isActive: true,
        features: ['Access to 100+ courses', 'Basic support', 'Mobile app'],
      ),
      const SubscriptionPlan(
        id: '2',
        name: 'Premium',
        description: 'For serious learners and professionals',
        price: 29.99,
        interval: 'monthly',
        subscriberCount: 1856,
        isActive: true,
        features: [
          'All Basic features',
          'Unlimited courses',
          'Priority support',
          'Certificates',
        ],
      ),
      const SubscriptionPlan(
        id: '3',
        name: 'Enterprise',
        description: 'For organizations and teams',
        price: 199.99,
        interval: 'monthly',
        subscriberCount: 156,
        isActive: true,
        features: [
          'All Premium features',
          'Team management',
          'Analytics dashboard',
          'API access',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    if (_transactionFilter == null) return _transactions;
    return _transactions.where((t) => t.status == _transactionFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      floating: true,
                      snap: true,
                      leading: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      title: Text(
                        l10n.paymentManagement,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _showReportOptions,
                          icon: Icon(
                            Icons.analytics_outlined,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                        IconButton(
                          onPressed: _showSettings,
                          icon: Icon(
                            Icons.settings_outlined,
                            color: AdminColors.getTextColor(isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      bottom: TabBar(
                        controller: _tabController,
                        labelColor: AdminColors.primary,
                        unselectedLabelColor: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                        indicatorColor: AdminColors.primary,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: l10n.overview),
                          Tab(text: l10n.transactions),
                          Tab(text: l10n.subscriptions),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDark, l10n, responsive),
                    _buildTransactionsTab(isDark, l10n, responsive),
                    _buildSubscriptionsTab(isDark, l10n, responsive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        PaymentStatsCard(
          isDark: isDark,
          totalRevenue: 125680.50,
          monthlyRevenue: 28450.00,
          pendingPayments: 3250.00,
          totalTransactions: 1856,
          growthPercentage: 12.5,
        ),
        SizedBox(height: responsive.p24),
        SubscriptionOverviewCard(
          isDark: isDark,
          activeSubscriptions: 4462,
          newSubscriptions: 156,
          canceledSubscriptions: 23,
          expiringSubscriptions: 89,
          onViewAll: () => _tabController.animateTo(2),
        ),
        SizedBox(height: responsive.p24),
        RecentTransactionsCard(
          isDark: isDark,
          transactions: _filteredTransactions.take(3).toList(),
          onViewDetails: _viewTransactionDetails,
          onRefund: _processRefund,
          onViewAll: () => _tabController.animateTo(1),
          filterStatus: _transactionFilter,
          onFilterChanged: (status) =>
              setState(() => _transactionFilter = status),
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildTransactionsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        RecentTransactionsCard(
          isDark: isDark,
          transactions: _filteredTransactions,
          onViewDetails: _viewTransactionDetails,
          onRefund: _processRefund,
          onViewAll: () {},
          filterStatus: _transactionFilter,
          onFilterChanged: (status) =>
              setState(() => _transactionFilter = status),
        ),
        SizedBox(height: responsive.p24),
        PaymentMethodsCard(
          isDark: isDark,
          methods: _paymentMethods,
          onToggle: _togglePaymentMethod,
          onAddMethod: _addPaymentMethod,
          onManageAll: () => context.push('/admin/settings/payment-gateways'),
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  Widget _buildSubscriptionsTab(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return ListView(
      padding: responsive.contentPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: responsive.p16),
        SubscriptionOverviewCard(
          isDark: isDark,
          activeSubscriptions: 4462,
          newSubscriptions: 156,
          canceledSubscriptions: 23,
          expiringSubscriptions: 89,
          onViewAll: () {},
        ),
        SizedBox(height: responsive.p24),
        SubscriptionPlansCard(
          isDark: isDark,
          plans: _subscriptionPlans,
          onEdit: _editPlan,
          onToggle: _togglePlan,
          onAddPlan: _addPlan,
        ),
        SizedBox(height: responsive.p32),
      ],
    );
  }

  void _viewTransactionDetails(Transaction transaction) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.getCardColor(
        context.read<ThemeBloc>().state.isDark,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.transactionDetails,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(l10n.transactionId, transaction.id),
            _buildDetailRow(l10n.customer, transaction.userName),
            _buildDetailRow(l10n.emailLabel, transaction.userEmail),
            _buildDetailRow(
              l10n.amount,
              '\$${transaction.amount.toStringAsFixed(2)}',
            ),
            _buildDetailRow(l10n.paymentMethodLabel, transaction.paymentMethod),
            _buildDetailRow(l10n.status, transaction.status.toUpperCase()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AdminColors.getTextColor(
                context.read<ThemeBloc>().state.isDark,
              ).withValues(alpha: 0.6),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _processRefund(Transaction transaction) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.processRefund),
        content: Text(
          '${l10n.refundConfirmation}\n\n${transaction.userName}: \$${transaction.amount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(l10n.refundProcessed);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.warning,
            ),
            child: Text(l10n.refund),
          ),
        ],
      ),
    );
  }

  void _togglePaymentMethod(PaymentMethod method) {
    setState(() {
      final index = _paymentMethods.indexWhere((m) => m.id == method.id);
      if (index != -1) {
        _paymentMethods[index] = method.copyWith(isEnabled: !method.isEnabled);
      }
    });
    final l10n = AppLocalizations.of(context);
    _showSnackBar(
      method.isEnabled
          ? '${method.name} ${l10n.disabled}'
          : '${method.name} ${l10n.enabled}',
    );
  }

  void _addPaymentMethod() {
    _showSnackBar('Opening payment gateway configuration...');
    context.push('/admin/settings/payment-gateways');
  }

  void _editPlan(SubscriptionPlan plan) {
    _showSnackBar('Editing ${plan.name} plan...');
  }

  void _togglePlan(SubscriptionPlan plan) {
    setState(() {
      final index = _subscriptionPlans.indexWhere((p) => p.id == plan.id);
      if (index != -1) {
        _subscriptionPlans[index] = plan.copyWith(isActive: !plan.isActive);
      }
    });
    final l10n = AppLocalizations.of(context);
    _showSnackBar(
      plan.isActive
          ? '${plan.name} ${l10n.planDeactivated}'
          : '${plan.name} ${l10n.planActivated}',
    );
  }

  void _addPlan() {
    _showSnackBar('Creating new subscription plan...');
  }

  void _showReportOptions() {
    _showSnackBar('Opening payment reports...');
  }

  void _showSettings() {
    context.push('/admin/settings/payment-gateways');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
