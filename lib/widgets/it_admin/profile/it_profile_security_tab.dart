import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_profile_barrel.dart';

class ITProfileSecurityTab extends StatelessWidget {
  final bool isDark;
  final bool mfaEnabled;
  final List<ActiveSession> sessions;
  final List<ApiToken> apiTokens;
  final VoidCallback onChangePassword;
  final VoidCallback onSetupMfa;
  final VoidCallback onAddDevice;
  final Function(String) onTerminateSession;
  final VoidCallback onTerminateAllSessions;
  final VoidCallback onGenerateToken;
  final Function(String) onRevokeToken;

  const ITProfileSecurityTab({
    super.key,
    required this.isDark,
    required this.mfaEnabled,
    required this.sessions,
    required this.apiTokens,
    required this.onChangePassword,
    required this.onSetupMfa,
    required this.onAddDevice,
    required this.onTerminateSession,
    required this.onTerminateAllSessions,
    required this.onGenerateToken,
    required this.onRevokeToken,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Password Management
        _buildPasswordSection(context),
        const SizedBox(height: 16),

        // MFA Section
        _buildMfaSection(),
        const SizedBox(height: 16),

        // Active Sessions
        _buildSessionsSection(),
        const SizedBox(height: 16),

        // API Tokens
        _buildApiTokensSection(),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Container(
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
              Icon(Icons.lock_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Password Management',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Last changed 30 days ago',
                  style: TextStyle(
                    fontSize: 13,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Password requirements
          _buildPasswordRequirement('At least 12 characters'),
          _buildPasswordRequirement('One uppercase letter'),
          _buildPasswordRequirement('One lowercase letter'),
          _buildPasswordRequirement('One number'),
          _buildPasswordRequirement('One special character'),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: ITColors.success),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ITColors.textSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ITChangePasswordDialog(
        isDark: isDark,
        onSubmit: (current, newPass) {
          Navigator.pop(context);
          onChangePassword();
        },
      ),
    );
  }

  Widget _buildMfaSection() {
    return Container(
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
              Icon(Icons.security_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Multi-Factor Authentication',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: mfaEnabled
                      ? ITColors.success.withValues(alpha: 0.15)
                      : ITColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mfaEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: mfaEnabled ? ITColors.success : ITColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (mfaEnabled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    size: 20,
                    color: ITColors.success,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Authenticator App',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ITColors.textPrimaryColor(isDark),
                        ),
                      ),
                      Text(
                        'Google Authenticator',
                        style: TextStyle(
                          fontSize: 11,
                          color: ITColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetupMfa,
                    icon: const Icon(Icons.settings_rounded, size: 16),
                    label: const Text('Setup MFA'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ITColors.primary,
                      side: BorderSide(color: ITColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddDevice,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Device'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ITColors.textSecondaryColor(isDark),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: onSetupMfa,
              icon: const Icon(Icons.security_rounded, size: 16),
              label: const Text('Enable MFA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsSection() {
    return Container(
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
              Icon(Icons.devices_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'Active Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onTerminateAllSessions,
                style: TextButton.styleFrom(
                  foregroundColor: ITColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Terminate All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...sessions.map((session) => _buildSessionItem(session)),
        ],
      ),
    );
  }

  Widget _buildSessionItem(ActiveSession session) {
    IconData deviceIcon;
    switch (session.device) {
      case SessionDevice.desktop:
        deviceIcon = Icons.computer_rounded;
        break;
      case SessionDevice.mobile:
        deviceIcon = Icons.smartphone_rounded;
        break;
      case SessionDevice.tablet:
        deviceIcon = Icons.tablet_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: session.isCurrentSession
            ? ITColors.primary.withValues(alpha: 0.08)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(10),
        border: session.isCurrentSession
            ? Border.all(color: ITColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            deviceIcon,
            size: 22,
            color: session.isCurrentSession
                ? ITColors.primary
                : ITColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      session.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    if (session.isCurrentSession) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ITColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: ITColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.ip} • ${session.location}',
                  style: TextStyle(
                    fontSize: 11,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          if (!session.isCurrentSession)
            IconButton(
              onPressed: () => onTerminateSession(session.id),
              icon: Icon(Icons.close_rounded, size: 18, color: ITColors.error),
              tooltip: 'Terminate',
            ),
        ],
      ),
    );
  }

  Widget _buildApiTokensSection() {
    return Container(
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
              Icon(Icons.key_rounded, size: 18, color: ITColors.primary),
              const SizedBox(width: 8),
              Text(
                'API Access Tokens',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ITColors.textPrimaryColor(isDark),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onGenerateToken,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: const Text(
                    'Generate Token',
                    textAlign: TextAlign.center,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ITColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...apiTokens.map((token) => _buildTokenItem(token)),
        ],
      ),
    );
  }

  Widget _buildTokenItem(ApiToken token) {
    final isExpiringSoon =
        token.expiresAt.difference(DateTime.now()).inDays < 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ITColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              size: 20,
              color: ITColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ITColors.textPrimaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    token.preview,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Expires: ${_formatDate(token.expiresAt)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isExpiringSoon
                        ? ITColors.warning
                        : ITColors.textSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onRevokeToken(token.id),
            style: TextButton.styleFrom(
              foregroundColor: ITColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Revoke', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
