import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITAlertsChannelsTab extends StatelessWidget {
  final bool isDark;
  final List<NotificationChannel> channels;
  final ValueChanged<NotificationChannel> onChannelTap;
  final ValueChanged<NotificationChannel> onChannelToggle;
  final Function(NotificationChannel) onTestChannel;
  final Function(NotificationChannel) onEditChannel;
  final VoidCallback onAddChannel;

  const ITAlertsChannelsTab({
    super.key,
    required this.isDark,
    required this.channels,
    required this.onChannelTap,
    required this.onChannelToggle,
    required this.onTestChannel,
    required this.onEditChannel,
    required this.onAddChannel,
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
                  color: ITColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.send_rounded,
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
                      'Notification Channels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure where alerts are delivered',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAddChannel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ITColors.primary, ITColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add Channel',
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

        // Channels list
        if (channels.isEmpty)
          _buildEmptyState()
        else
          ...channels.map((channel) => _buildChannelCard(channel)),
      ],
    );
  }

  Widget _buildChannelCard(NotificationChannel channel) {
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getChannelColor(channel.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getChannelIcon(channel.type),
                  color: _getChannelColor(channel.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          channel.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ITColors.textPrimaryColor(isDark),
                          ),
                        ),
                        if (channel.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: ITColors.success,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      channel.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: channel.isEnabled,
                onChanged: (_) => onChannelToggle(channel),
                activeTrackColor: ITColors.success.withValues(alpha: 0.5),
                activeThumbColor: ITColors.success,
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Channel config details
          ...channel.config.entries.take(2).map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ITColors.textSecondaryColor(isDark),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ITColors.textPrimaryColor(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              _buildActionButton(
                Icons.send_rounded,
                'Test',
                () => onTestChannel(channel),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                Icons.edit_rounded,
                'Edit',
                () => onEditChannel(channel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: ITColors.textSecondaryColor(isDark)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: ITColors.textSecondaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No notification channels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a channel to receive alert notifications',
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

  IconData _getChannelIcon(ChannelType type) {
    switch (type) {
      case ChannelType.slack:
        return Icons.tag_rounded;
      case ChannelType.email:
        return Icons.email_rounded;
      case ChannelType.pagerDuty:
        return Icons.phone_in_talk_rounded;
      case ChannelType.sms:
        return Icons.sms_rounded;
      case ChannelType.webhook:
        return Icons.webhook_rounded;
    }
  }

  Color _getChannelColor(ChannelType type) {
    switch (type) {
      case ChannelType.slack:
        return const Color(0xFF4A154B);
      case ChannelType.email:
        return ITColors.info;
      case ChannelType.pagerDuty:
        return ITColors.success;
      case ChannelType.sms:
        return ITColors.purple;
      case ChannelType.webhook:
        return ITColors.orange;
    }
  }
}
