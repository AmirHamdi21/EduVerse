import 'package:flutter/material.dart';

import '../../../models/chat/user_profile_context.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileContext profile;
  final Color accentColor;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = profile.isOnline
        ? 'Online'
        : (profile.lastSeen != null
              ? 'Last seen ${_formatLastSeen(profile.lastSeen!)}'
              : 'Offline');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: accentColor.withValues(alpha: 0.16),
            child: Text(
              profile.initials,
              style: TextStyle(
                color: accentColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: profile.isOnline
                  ? const Color(0xFF16A34A).withValues(alpha: 0.14)
                  : Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: profile.isOnline
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${value.day}/${value.month}/${value.year}';
  }
}
