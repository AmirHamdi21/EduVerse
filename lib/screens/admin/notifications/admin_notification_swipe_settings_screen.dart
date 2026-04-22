import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/notifications/swipe_action_model.dart';
import '../../../services/admin_notification_swipe_settings_service.dart';
import '../../../widgets/admin/shared/admin_colors.dart';

class AdminNotificationSwipeSettingsScreen extends StatefulWidget {
  const AdminNotificationSwipeSettingsScreen({super.key});

  @override
  State<AdminNotificationSwipeSettingsScreen> createState() =>
      _AdminNotificationSwipeSettingsScreenState();
}

class _AdminNotificationSwipeSettingsScreenState
    extends State<AdminNotificationSwipeSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _settingsService = AdminNotificationSwipeSettingsService.instance;
  NotificationSwipeSettings _settings = const NotificationSwipeSettings();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.getSwipeSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _updateLeftAction(SwipeAction action) async {
    HapticFeedback.selectionClick();
    setState(() => _settings = _settings.copyWith(leftAction: action));
    await _settingsService.setLeftAction(action);
  }

  Future<void> _updateRightAction(SwipeAction action) async {
    HapticFeedback.selectionClick();
    setState(() => _settings = _settings.copyWith(rightAction: action));
    await _settingsService.setRightAction(action);
  }

  Future<void> _updateConfirmation(bool confirm) async {
    HapticFeedback.selectionClick();
    setState(
      () => _settings = _settings.copyWith(confirmBeforeAction: confirm),
    );
    await _settingsService.setConfirmBeforeAction(confirm);
  }

  Future<void> _updateSensitivity(double sensitivity) async {
    setState(
      () => _settings = _settings.copyWith(swipeSensitivity: sensitivity),
    );
    await _settingsService.setSwipeSensitivity(sensitivity);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AdminColors.getBackgroundGradient(isDark),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark, l10n),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(isDark)
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildContent(isDark, l10n),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.swipeActions,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                Text(
                  l10n.customizeSwipeGestures,
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              const defaultSettings = NotificationSwipeSettings();
              setState(() => _settings = defaultSettings);
              await _settingsService.saveSwipeSettings(defaultSettings);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AdminColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.reset,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: AdminColors.primary,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader(l10n.preview, isDark),
        const SizedBox(height: 12),
        _buildPreviewCard(isDark, l10n),
        const SizedBox(height: 28),
        _buildSectionHeader(l10n.swipeRightAction, isDark),
        const SizedBox(height: 12),
        _buildActionSelector(
          currentAction: _settings.rightAction,
          onActionSelected: _updateRightAction,
          isDark: isDark,
          l10n: l10n,
          highlightColor: AdminColors.success,
        ),
        const SizedBox(height: 28),
        _buildSectionHeader(l10n.swipeLeftAction, isDark),
        const SizedBox(height: 12),
        _buildActionSelector(
          currentAction: _settings.leftAction,
          onActionSelected: _updateLeftAction,
          isDark: isDark,
          l10n: l10n,
          highlightColor: AdminColors.error,
        ),
        const SizedBox(height: 28),
        _buildSectionHeader(l10n.additionalSettings, isDark),
        const SizedBox(height: 12),
        _buildSettingsCard(isDark, l10n),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AdminColors.getTextTertiaryColor(isDark),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [Colors.white, const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_settings.rightAction != SwipeAction.none)
                _buildSwipeHint(
                  icon: Icons.arrow_back_rounded,
                  action: _settings.rightAction,
                  isLeft: true,
                )
              else
                const SizedBox.shrink(),
              if (_settings.leftAction != SwipeAction.none)
                _buildSwipeHint(
                  icon: Icons.arrow_forward_rounded,
                  action: _settings.leftAction,
                  isLeft: false,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sampleNotificationTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.sampleNotificationBody,
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AdminColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe_rounded, size: 18, color: AdminColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.swipeToPreview,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint({
    required IconData icon,
    required SwipeAction action,
    required bool isLeft,
  }) {
    final children = [
      if (!isLeft) ...[
        Text(
          _getActionLabel(action),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: action.color,
          ),
        ),
        const SizedBox(width: 6),
      ],
      Icon(icon, size: 16, color: action.color),
      if (isLeft) ...[
        const SizedBox(width: 6),
        Text(
          _getActionLabel(action),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: action.color,
          ),
        ),
      ],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: action.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildActionSelector({
    required SwipeAction currentAction,
    required Function(SwipeAction) onActionSelected,
    required bool isDark,
    required AppLocalizations l10n,
    required Color highlightColor,
  }) {
    final actions = SwipeAction.values;

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          final isSelected = action == currentAction;
          final isFirst = index == 0;
          final isLast = index == actions.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onActionSelected(action),
                  borderRadius: BorderRadius.vertical(
                    top: isFirst ? const Radius.circular(20) : Radius.zero,
                    bottom: isLast ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? action.color.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? const Radius.circular(20) : Radius.zero,
                        bottom: isLast
                            ? const Radius.circular(20)
                            : Radius.zero,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? action.color.withOpacity(0.15)
                                : (isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action.icon,
                            color: isSelected
                                ? action.color
                                : AdminColors.getTextTertiaryColor(isDark),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getActionLabel(action),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? action.color
                                      : AdminColors.getTextColor(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getActionDescription(action, l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.getTextTertiaryColor(
                                    isDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? action.color
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? action.color
                                  : AdminColors.getTextTertiaryColor(isDark),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 74,
                  endIndent: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            isDark: isDark,
            icon: Icons.help_outline_rounded,
            iconColor: AdminColors.primary,
            title: l10n.confirmBeforeAction,
            subtitle: l10n.confirmBeforeActionDesc,
            trailing: Switch(
              value: _settings.confirmBeforeAction,
              onChanged: _updateConfirmation,
              activeColor: AdminColors.primary,
            ),
            isFirst: true,
          ),
          Divider(
            height: 1,
            indent: 74,
            endIndent: 18,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.shade200,
          ),
          _buildSensitivitySlider(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSensitivitySlider(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AdminColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  color: AdminColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.swipeSensitivity,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.swipeSensitivityDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.low,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AdminColors.secondary,
                    inactiveTrackColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                    thumbColor: AdminColors.secondary,
                    overlayColor: AdminColors.secondary.withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: _settings.swipeSensitivity,
                    min: 0.2,
                    max: 0.8,
                    onChanged: _updateSensitivity,
                    onChangeEnd: _updateSensitivity,
                  ),
                ),
              ),
              Text(
                l10n.high,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AdminColors.getTextTertiaryColor(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActionLabel(SwipeAction action) {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case SwipeAction.delete:
        return l10n.delete;
      case SwipeAction.markRead:
        return l10n.markAsRead;
      case SwipeAction.markUnread:
        return l10n.markAsUnread;
      case SwipeAction.archive:
        return l10n.archive;
      case SwipeAction.bookmark:
        return l10n.bookmark;
      case SwipeAction.none:
        return l10n.noAction;
    }
  }

  String _getActionDescription(SwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case SwipeAction.delete:
        return l10n.deleteActionDesc;
      case SwipeAction.markRead:
        return l10n.markReadActionDesc;
      case SwipeAction.markUnread:
        return l10n.markUnreadActionDesc;
      case SwipeAction.archive:
        return l10n.archiveActionDesc;
      case SwipeAction.bookmark:
        return l10n.bookmarkActionDesc;
      case SwipeAction.none:
        return l10n.noActionDesc;
    }
  }
}
