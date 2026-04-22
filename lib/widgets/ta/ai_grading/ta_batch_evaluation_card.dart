import 'package:flutter/material.dart';
import '../shared/ta_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

class TABatchEvaluationCard extends StatelessWidget {
  final bool isDark;
  final int pendingCount;
  final VoidCallback? onAutoEvaluate;
  final bool isLoading;

  const TABatchEvaluationCard({
    super.key,
    required this.isDark,
    required this.pendingCount,
    this.onAutoEvaluate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TAColors.primary.withValues(alpha: 0.12),
            TAColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TAColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: TAColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.taGradingBatchEvaluation,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taGradingBatchEvaluationDesc,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAutoEvaluate,
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                isLoading
                    ? l10n.taGradingEvaluating
                    : '${l10n.taGradingAutoEvaluateAll} ($pendingCount)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
