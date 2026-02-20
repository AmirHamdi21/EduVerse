import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_security_logs_barrel.dart';

class ITAccessRequestsSection extends StatelessWidget {
  final bool isDark;
  final List<AccessRequest> requests;
  final Function(AccessRequest) onApprove;
  final Function(AccessRequest) onDeny;
  final Function(AccessRequest) onViewDetails;

  const ITAccessRequestsSection({
    super.key,
    required this.isDark,
    required this.requests,
    required this.onApprove,
    required this.onDeny,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Access Requests',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          _buildEmptyState()
        else
          ...requests.map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(AccessRequest request) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ITColors.primary.withValues(alpha: 0.1),
                child: Text(
                  request.userName.isNotEmpty
                      ? request.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: ITColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.userName,
                    style: TextStyle(
                      color: ITColors.textPrimaryColor(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.userEmail,
                    style: TextStyle(
                      color: ITColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ITColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.currentRole,
                          style: TextStyle(
                            color: ITColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: ITColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ITColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.requestedRole,
                          style: TextStyle(
                            color: ITColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : ITColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.reason,
                  style: TextStyle(
                    color: ITColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: ITColors.textTertiaryColor(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                'Requested ${_formatTime(request.requestedAt)}',
                style: TextStyle(
                  color: ITColors.textTertiaryColor(isDark),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onDeny(request),
                style: TextButton.styleFrom(
                  foregroundColor: ITColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: ITColors.error),
                  ),
                ),
                child: const Text(
                  'Deny',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onApprove(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Approve',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : ITColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: ITColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              'No pending requests',
              style: TextStyle(
                color: ITColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All access requests have been processed',
              style: TextStyle(
                color: ITColors.textTertiaryColor(isDark),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
