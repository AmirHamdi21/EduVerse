import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class Transaction {
  final String id;
  final String userName;
  final String userEmail;
  final double amount;
  final String type; // 'subscription', 'course', 'refund'
  final String status; // 'completed', 'pending', 'failed', 'refunded'
  final DateTime date;
  final String paymentMethod;

  const Transaction({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    required this.paymentMethod,
  });
}

class RecentTransactionsCard extends StatelessWidget {
  final bool isDark;
  final List<Transaction> transactions;
  final Function(Transaction) onViewDetails;
  final Function(Transaction) onRefund;
  final VoidCallback onViewAll;
  final String? filterStatus;
  final ValueChanged<String?> onFilterChanged;

  const RecentTransactionsCard({
    super.key,
    required this.isDark,
    required this.transactions,
    required this.onViewDetails,
    required this.onRefund,
    required this.onViewAll,
    this.filterStatus,
    required this.onFilterChanged,
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
                  gradient: AdminColors.cyanGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
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
                      l10n.recentTransactions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transactions.length} ${l10n.transactionsToday}',
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
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  l10n.viewAll,
                  style: TextStyle(
                    color: AdminColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, null, l10n.all),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'completed', l10n.completed),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'pending', l10n.pending),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'failed', l10n.failed),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'refunded', l10n.refunded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AdminColors.getTextColor(
                        isDark,
                      ).withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noTransactions,
                      style: TextStyle(
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...transactions
                .take(5)
                .map((t) => _buildTransactionItem(context, t, l10n)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String? value, String label) {
    final isSelected = filterStatus == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AdminColors.cyanGradient : null,
          color: isSelected
              ? null
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AdminColors.getTextColor(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    AppLocalizations l10n,
  ) {
    final statusColor = _getStatusColor(transaction.status);
    final typeIcon = _getTypeIcon(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                    ),
                    Text(
                      transaction.status == 'refunded'
                          ? '-\$${transaction.amount.toStringAsFixed(2)}'
                          : '\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: transaction.status == 'refunded'
                            ? AdminColors.error
                            : AdminColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_getTypeLabel(l10n, transaction.type)} • ${transaction.paymentMethod}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextColor(
                            isDark,
                          ).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(l10n, transaction.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AdminColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
            color: AdminColors.getCardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      size: 18,
                      color: AdminColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.viewDetails),
                  ],
                ),
              ),
              if (transaction.status == 'completed')
                PopupMenuItem(
                  value: 'refund',
                  child: Row(
                    children: [
                      Icon(
                        Icons.undo_rounded,
                        size: 18,
                        color: AdminColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.refund),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'details':
                  onViewDetails(transaction);
                  break;
                case 'refund':
                  onRefund(transaction);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AdminColors.success;
      case 'pending':
        return AdminColors.warning;
      case 'failed':
        return AdminColors.error;
      case 'refunded':
        return AdminColors.secondary;
      default:
        return AdminColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'subscription':
        return Icons.card_membership_rounded;
      case 'course':
        return Icons.school_rounded;
      case 'refund':
        return Icons.undo_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _getTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'subscription':
        return l10n.subscription;
      case 'course':
        return l10n.coursePurchase;
      case 'refund':
        return l10n.refund;
      default:
        return type;
    }
  }

  String _getStatusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'completed':
        return l10n.completed;
      case 'pending':
        return l10n.pending;
      case 'failed':
        return l10n.failed;
      case 'refunded':
        return l10n.refunded;
      default:
        return status;
    }
  }
}
