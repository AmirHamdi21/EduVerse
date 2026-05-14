import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/chat/chat_swipe_action_model.dart';
import '../../../services/chat_swipe_settings_service.dart';
import '../../../utils/navigation/safe_back.dart';

class ChatSwipeSettingsScreen extends StatefulWidget {
  const ChatSwipeSettingsScreen({super.key});

  @override
  State<ChatSwipeSettingsScreen> createState() =>
      _ChatSwipeSettingsScreenState();
}

class _ChatSwipeSettingsScreenState extends State<ChatSwipeSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _settingsService = ChatSwipeSettingsService.instance;
  ChatSwipeSettings _settings = const ChatSwipeSettings();
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

  Future<void> _updateLeftAction(ChatSwipeAction action) async {
    HapticFeedback.selectionClick();
    setState(() => _settings = _settings.copyWith(leftAction: action));
    await _settingsService.setLeftAction(action);
  }

  Future<void> _updateRightAction(ChatSwipeAction action) async {
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark, l10n),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
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
              safeBack(context, '/dashboard');
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iosBackIcon(context),
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chatSwipeActions,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  l10n.chatSwipeActionsSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          // Reset button
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              final defaultSettings = const ChatSwipeSettings();
              setState(() => _settings = defaultSettings);
              await _settingsService.saveSwipeSettings(defaultSettings);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.reset,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF3B82F6),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        // Preview section
        _buildSectionHeader(l10n.preview, isDark),
        const SizedBox(height: 12),
        _buildPreviewCard(isDark, l10n),
        const SizedBox(height: 28),

        // Swipe Right action (shown on left when swiping right)
        _buildSectionHeader(l10n.swipeRightAction, isDark),
        const SizedBox(height: 12),
        _buildActionSelector(
          currentAction: _settings.rightAction,
          onActionSelected: _updateRightAction,
          isDark: isDark,
          l10n: l10n,
          highlightColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 28),

        // Swipe Left action (shown on right when swiping left)
        _buildSectionHeader(l10n.swipeLeftAction, isDark),
        const SizedBox(height: 12),
        _buildActionSelector(
          currentAction: _settings.leftAction,
          onActionSelected: _updateLeftAction,
          isDark: isDark,
          l10n: l10n,
          highlightColor: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 28),

        // Settings section
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
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Swipe hints
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side (swipe right action)
              if (_settings.rightAction != ChatSwipeAction.none)
                _buildSwipeHint(
                  icon: Icons.arrow_back_rounded,
                  action: _settings.rightAction,
                  isLeft: true,
                  l10n: l10n,
                )
              else
                const SizedBox.shrink(),
              // Right side (swipe left action)
              if (_settings.leftAction != ChatSwipeAction.none)
                _buildSwipeHint(
                  icon: Icons.arrow_forward_rounded,
                  action: _settings.leftAction,
                  isLeft: false,
                  l10n: l10n,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 16),
          // Sample chat preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chatSampleTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.chatSampleMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swipe_rounded,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.swipeToPreview,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3B82F6),
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
    required ChatSwipeAction action,
    required bool isLeft,
    required AppLocalizations l10n,
  }) {
    final children = [
      if (!isLeft) ...[
        Text(
          _getActionLabel(action, l10n),
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
          _getActionLabel(action, l10n),
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
        color: action.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildActionSelector({
    required ChatSwipeAction currentAction,
    required Function(ChatSwipeAction) onActionSelected,
    required bool isDark,
    required AppLocalizations l10n,
    required Color highlightColor,
  }) {
    final actions = ChatSwipeAction.values;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                          ? action.color.withValues(alpha: 0.08)
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
                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? action.color.withValues(alpha: 0.15)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action.icon,
                            color: isSelected
                                ? action.color
                                : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getActionLabel(action, l10n),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? action.color
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getActionDescription(action, l10n),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Selection indicator
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
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.grey.shade300),
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
                      ? Colors.white.withValues(alpha: 0.06)
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Confirmation toggle
          _buildSettingItem(
            isDark: isDark,
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: l10n.confirmBeforeAction,
            subtitle: l10n.confirmBeforeActionDesc,
            trailing: Switch(
              value: _settings.confirmBeforeAction,
              onChanged: _updateConfirmation,
              activeColor: const Color(0xFF3B82F6),
              activeTrackColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              inactiveThumbColor: isDark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
              inactiveTrackColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
            ),
          ),
          Divider(
            height: 1,
            indent: 74,
            endIndent: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade200,
          ),
          // Sensitivity slider
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
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
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF8B5CF6),
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
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.swipeSensitivityDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFF8B5CF6),
                    inactiveTrackColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    overlayColor: const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _settings.swipeSensitivity,
                    min: 0.2,
                    max: 0.8,
                    onChanged: _updateSensitivity,
                  ),
                ),
              ),
              Text(
                l10n.high,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActionLabel(ChatSwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case ChatSwipeAction.delete:
        return l10n.delete;
      case ChatSwipeAction.archive:
        return l10n.archive;
      case ChatSwipeAction.pin:
        return l10n.chatPin;
      case ChatSwipeAction.mute:
        return l10n.chatMute;
      case ChatSwipeAction.markRead:
        return l10n.markAsRead;
      case ChatSwipeAction.markUnread:
        return l10n.markAsUnread;
      case ChatSwipeAction.none:
        return l10n.none;
    }
  }

  String _getActionDescription(ChatSwipeAction action, AppLocalizations l10n) {
    switch (action) {
      case ChatSwipeAction.delete:
        return l10n.chatDeleteDesc;
      case ChatSwipeAction.archive:
        return l10n.chatArchiveDesc;
      case ChatSwipeAction.pin:
        return l10n.chatPinDesc;
      case ChatSwipeAction.mute:
        return l10n.chatMuteDesc;
      case ChatSwipeAction.markRead:
        return l10n.chatMarkReadDesc;
      case ChatSwipeAction.markUnread:
        return l10n.chatMarkUnreadDesc;
      case ChatSwipeAction.none:
        return l10n.chatNoneDesc;
    }
  }
}
