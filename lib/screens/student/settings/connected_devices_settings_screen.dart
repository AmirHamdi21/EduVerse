import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class ConnectedDevicesSettingsScreen extends StatefulWidget {
  const ConnectedDevicesSettingsScreen({super.key});

  @override
  State<ConnectedDevicesSettingsScreen> createState() =>
      _ConnectedDevicesSettingsScreenState();
}

class _ConnectedDevicesSettingsScreenState
    extends State<ConnectedDevicesSettingsScreen> {
  final List<_DeviceInfo> _devices = [
    _DeviceInfo(
      id: '1',
      name: 'iPhone 15 Pro',
      type: 'mobile',
      location: 'Cairo, Egypt',
      lastActive: DateTime.now(),
      isCurrent: true,
    ),
    _DeviceInfo(
      id: '2',
      name: 'MacBook Pro',
      type: 'laptop',
      location: 'Cairo, Egypt',
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      isCurrent: false,
    ),
    _DeviceInfo(
      id: '3',
      name: 'iPad Air',
      type: 'tablet',
      location: 'Alexandria, Egypt',
      lastActive: DateTime.now().subtract(const Duration(days: 1)),
      isCurrent: false,
    ),
    _DeviceInfo(
      id: '4',
      name: 'Windows PC',
      type: 'desktop',
      location: 'Giza, Egypt',
      lastActive: DateTime.now().subtract(const Duration(days: 5)),
      isCurrent: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.connectedDevices,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSignOutAllDialog(isDark, l10n),
            icon: Icon(
              Icons.logout_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            tooltip: l10n.signOutAllDevices,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Current Device
          _buildSectionTitle(l10n.currentDevice, isDark),
          const SizedBox(height: 12),
          _buildDeviceCard(
            isDark,
            _devices.firstWhere((d) => d.isCurrent),
            l10n,
          ),
          const SizedBox(height: 24),

          // Other Devices
          _buildSectionTitle(l10n.otherDevices, isDark),
          const SizedBox(height: 12),
          ..._devices
              .where((d) => !d.isCurrent)
              .map(
                (device) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDeviceCard(isDark, device, l10n),
                ),
              ),
          const SizedBox(height: 24),

          // Security Info
          _buildSecurityInfoCard(isDark, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    bool isDark,
    _DeviceInfo device,
    AppLocalizations l10n,
  ) {
    IconData icon;
    switch (device.type) {
      case 'mobile':
        icon = Icons.smartphone_rounded;
        break;
      case 'laptop':
        icon = Icons.laptop_mac_rounded;
        break;
      case 'tablet':
        icon = Icons.tablet_mac_rounded;
        break;
      case 'desktop':
        icon = Icons.desktop_mac_rounded;
        break;
      default:
        icon = Icons.devices_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: device.isCurrent
            ? Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    color: device.isCurrent
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                        : (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: device.isCurrent
                        ? const Color(0xFF3B82F6)
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              device.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (device.isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.thisDevice,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              _formatLastActive(device.lastActive, l10n),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!device.isCurrent)
                  IconButton(
                    onPressed: () =>
                        _showRemoveDeviceDialog(isDark, device, l10n),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    tooltip: l10n.signOut,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastActive(DateTime lastActive, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(lastActive);

    if (diff.inMinutes < 5) {
      return l10n.activeNow;
    } else if (diff.inHours < 1) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else {
      return l10n.daysAgo(diff.inDays);
    }
  }

  Widget _buildSecurityInfoCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.amber.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.securityTip,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDeviceDialog(
    bool isDark,
    _DeviceInfo device,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => _RemoveDeviceDialog(
        isDark: isDark,
        device: device,
        l10n: l10n,
        onConfirm: () {
          setState(() {
            _devices.removeWhere((d) => d.id == device.id);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deviceRemoved),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSignOutAllDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _SignOutAllDialog(
        isDark: isDark,
        l10n: l10n,
        deviceCount: _devices.where((d) => !d.isCurrent).length,
        onConfirm: () {
          setState(() {
            _devices.removeWhere((d) => !d.isCurrent);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.allDevicesRemoved),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeviceInfo {
  final String id;
  final String name;
  final String type;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;

  const _DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
}

class _RemoveDeviceDialog extends StatefulWidget {
  final bool isDark;
  final _DeviceInfo device;
  final AppLocalizations l10n;
  final VoidCallback onConfirm;

  const _RemoveDeviceDialog({
    required this.isDark,
    required this.device,
    required this.l10n,
    required this.onConfirm,
  });

  @override
  State<_RemoveDeviceDialog> createState() => _RemoveDeviceDialogState();
}

class _RemoveDeviceDialogState extends State<_RemoveDeviceDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.2),
                        const Color(0xFFEF4444).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      size: 44,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.l10n.removeDevice,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.smartphone_rounded,
                        size: 24,
                        color: widget.isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.device.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              widget.device.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark
                                    ? Colors.white54
                                    : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.l10n.removeDeviceWarning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDark ? Colors.white54 : Colors.black45,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.l10n.cancel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onConfirm();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.l10n.signOut,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutAllDialog extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final int deviceCount;
  final VoidCallback onConfirm;

  const _SignOutAllDialog({
    required this.isDark,
    required this.l10n,
    required this.deviceCount,
    required this.onConfirm,
  });

  @override
  State<_SignOutAllDialog> createState() => _SignOutAllDialogState();
}

class _SignOutAllDialogState extends State<_SignOutAllDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.2),
                        const Color(0xFFEF4444).withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.devices_rounded,
                      size: 44,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.l10n.signOutAllDevices,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${widget.l10n.signOutAllWarning} (${widget.deviceCount} ${widget.l10n.devices})',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDark
                                ? Colors.white70
                                : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.l10n.cancel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onConfirm();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.l10n.signOutAllDevices,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
