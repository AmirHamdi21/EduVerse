import 'package:flutter/material.dart';

/// Shared color constants for IT Admin features
class ITColors {
  ITColors._();

  // Primary cyan/teal - IT Admin theme
  static const Color primary = Color(0xFF0891B2);
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryLighter = Color(0xFF67E8F9);
  static const Color primaryDark = Color(0xFF0E7490);
  static const Color primarySurface = Color(0xFFECFEFF);

  // Secondary blue
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);

  // Status colors
  static const Color success = Color(0xFF00C950);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF0B100);
  static const Color warningLight = Color(0xFFFEFCE8);
  static const Color error = Color(0xFFE7000B);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color critical = Color(0xFFDC2626);
  static const Color criticalLight = Color(0xFFFEF2F2);

  // Accent colors
  static const Color accent = Color(0xFF53EAFD);
  static const Color accentLight = Color(0xFFA2F4FD);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);
  static const Color orange = Color(0xFFFF6900);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);

  // Operational status colors
  static const Color operational = Color(0xFF00A63E);
  static const Color operationalBg = Color(0xFFF0FDF4);
  static const Color degraded = Color(0xFFD08700);
  static const Color degradedBg = Color(0xFFFEFCE8);
  static const Color offline = Color(0xFFE7000B);
  static const Color offlineBg = Color(0xFFFEE2E2);
  static const Color maintenance = Color(0xFF6366F1);
  static const Color maintenanceBg = Color(0xFFEEF2FF);

  // Neutrals - Light
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF4A5565);
  static const Color textTertiary = Color(0xFF6A7282);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color lightBackground = Color(0xFFFAFAFA);

  // Dark mode colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSurface = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkBackground = Color(0xFF0F172A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Colors.white, Color(0xFFECFEFF)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0891B2), Color(0xFF22D3EE), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF0E4A5A), Color(0xFF1E293B), Color(0xFF0F3D4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Theme-aware color getters
  static Color background(bool isDark) => isDark ? darkBg : lightBackground;
  static Color scaffoldColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color cardColor(bool isDark) => isDark ? darkCard : card;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : surface;
  static Color borderColor(bool isDark) => isDark ? darkBorder : border;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : textPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : textSecondary;
  static Color textTertiaryColor(bool isDark) =>
      isDark ? darkTextTertiary : textTertiary;

  // Status colors based on service health
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
      case 'normal':
      case 'healthy':
        return operational;
      case 'degraded':
      case 'warning':
        return degraded;
      case 'offline':
      case 'down':
      case 'error':
        return offline;
      case 'maintenance':
        return maintenance;
      default:
        return textSecondary;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
      case 'normal':
      case 'healthy':
        return operationalBg;
      case 'degraded':
      case 'warning':
        return degradedBg;
      case 'offline':
      case 'down':
      case 'error':
        return offlineBg;
      case 'maintenance':
        return maintenanceBg;
      default:
        return surface;
    }
  }

  // Priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return critical;
      case 'high':
        return error;
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return textSecondary;
    }
  }

  static Color getPriorityBgColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return criticalLight;
      case 'high':
        return errorLight;
      case 'medium':
        return warningLight;
      case 'low':
        return successLight;
      default:
        return surface;
    }
  }

  // Metric type colors
  static Color getMetricColor(String type) {
    switch (type.toLowerCase()) {
      case 'cpu':
        return cyan;
      case 'memory':
      case 'ram':
        return purple;
      case 'storage':
      case 'disk':
        return orange;
      case 'network':
        return teal;
      case 'latency':
      case 'api':
        return secondary;
      case 'uptime':
        return success;
      default:
        return primary;
    }
  }

  static IconData getMetricIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cpu':
        return Icons.memory_rounded;
      case 'memory':
      case 'ram':
        return Icons.storage_rounded;
      case 'storage':
      case 'disk':
        return Icons.sd_storage_rounded;
      case 'network':
        return Icons.wifi_rounded;
      case 'latency':
      case 'api':
        return Icons.api_rounded;
      case 'uptime':
        return Icons.timer_rounded;
      case 'incidents':
        return Icons.warning_rounded;
      case 'database':
        return Icons.dns_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  // Card shadow
  static List<BoxShadow> cardShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : const Color(0xFFA2F4FD).withValues(alpha: 0.5),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFFA2F4FD).withValues(alpha: 0.5),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> lightCardShadow(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
