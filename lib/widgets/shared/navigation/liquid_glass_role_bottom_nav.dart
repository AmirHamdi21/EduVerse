import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiquidGlassRoleBottomNav extends StatelessWidget {
  const LiquidGlassRoleBottomNav({
    super.key,
    required this.isDark,
    required this.isVisible,
    required this.theme,
    required this.mainItems,
    required this.actionItem,
  });

  final bool isDark;
  final bool isVisible;
  final LiquidGlassNavTheme theme;
  final List<LiquidGlassNavItem> mainItems;
  final LiquidGlassNavItem actionItem;

  static const double height = 92;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 520);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: AnimatedSlide(
            offset: isVisible ? Offset.zero : const Offset(0, 1.28),
            duration: duration,
            curve: Curves.easeInOutCubic,
            child: _LiquidGlassDock(
              isDark: isDark,
              theme: theme,
              mainItems: mainItems,
              actionItem: actionItem,
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidGlassNavTheme {
  const LiquidGlassNavTheme({
    required this.primary,
    required this.secondary,
    required this.action,
    required this.lightTextPrimary,
    required this.lightTextSecondary,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
  });

  final Color primary;
  final Color secondary;
  final Color action;
  final Color lightTextPrimary;
  final Color lightTextSecondary;
  final Color darkTextPrimary;
  final Color darkTextSecondary;

  Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  Color activeForeground(bool isDark) =>
      isDark ? Color.lerp(primary, Colors.white, 0.58)! : primary;
  Color activeSecondary(bool isDark) =>
      isDark ? Color.lerp(secondary, Colors.white, 0.46)! : secondary;
}

class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  bool matches(String path) => path == route || path.startsWith('$route/');
}

class _LiquidGlassDock extends StatelessWidget {
  const _LiquidGlassDock({
    required this.isDark,
    required this.theme,
    required this.mainItems,
    required this.actionItem,
  });

  final bool isDark;
  final LiquidGlassNavTheme theme;
  final List<LiquidGlassNavItem> mainItems;
  final LiquidGlassNavItem actionItem;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final activeIndex = mainItems.indexWhere(
      (item) => item.matches(currentPath),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final compact = availableWidth < 390;
        final tight = availableWidth < 340;
        final gap = compact ? 8.0 : 10.0;
        final bubbleSize = tight
            ? 52.0
            : compact
            ? 58.0
            : 64.0;
        final maxPillWidth = compact ? 318.0 : 370.0;
        final pillWidth = (availableWidth - bubbleSize - gap)
            .clamp(0.0, maxPillWidth)
            .toDouble();

        return Center(
          child: SizedBox(
            height: 72,
            width: pillWidth + bubbleSize + gap,
            child: Row(
              children: [
                SizedBox(
                  width: pillWidth,
                  height: 64,
                  child: _LiquidGlassPill(
                    isDark: isDark,
                    theme: theme,
                    items: mainItems,
                    activeIndex: activeIndex,
                    compact: compact,
                    onTap: (item) {
                      if (!item.matches(currentPath)) context.push(item.route);
                    },
                  ),
                ),
                SizedBox(width: gap),
                _LiquidGlassActionBubble(
                  isDark: isDark,
                  theme: theme,
                  size: bubbleSize,
                  destination: actionItem,
                  isActive: actionItem.matches(currentPath),
                  onTap: () {
                    if (!actionItem.matches(currentPath)) {
                      context.push(actionItem.route);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiquidGlassPill extends StatefulWidget {
  const _LiquidGlassPill({
    required this.isDark,
    required this.theme,
    required this.items,
    required this.activeIndex,
    required this.compact,
    required this.onTap,
  });

  final bool isDark;
  final LiquidGlassNavTheme theme;
  final List<LiquidGlassNavItem> items;
  final int activeIndex;
  final bool compact;
  final ValueChanged<LiquidGlassNavItem> onTap;

  @override
  State<_LiquidGlassPill> createState() => _LiquidGlassPillState();
}

class _LiquidGlassPillState extends State<_LiquidGlassPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pullController;
  int _fromIndex = -1;
  int _targetIndex = -1;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.activeIndex;
    _targetIndex = widget.activeIndex;
    _pullController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _LiquidGlassPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex >= 0 && widget.activeIndex != _targetIndex) {
      _animateTo(widget.activeIndex);
    }
    if (widget.activeIndex < 0 && oldWidget.activeIndex >= 0) {
      setState(() {
        _fromIndex = -1;
        _targetIndex = -1;
      });
      _pullController.value = 1;
    }
  }

  @override
  void dispose() {
    _pullController.dispose();
    super.dispose();
  }

  void _handleItemTap(int index) {
    if (index < 0 || index >= widget.items.length || index == _targetIndex) {
      return;
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _animateTo(index, animate: !reduceMotion);

    if (reduceMotion) {
      widget.onTap(widget.items[index]);
      return;
    }

    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted || _targetIndex != index) return;
      widget.onTap(widget.items[index]);
    });
  }

  void _animateTo(int index, {bool animate = true}) {
    setState(() {
      _fromIndex = _targetIndex >= 0 ? _targetIndex : index;
      _targetIndex = index;
    });

    if (!animate) {
      _pullController.value = 1;
      return;
    }

    _pullController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      isDark: widget.isDark,
      theme: widget.theme,
      radius: 34,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.items.length;
          final visibleIndex = _targetIndex >= 0
              ? _targetIndex
              : widget.activeIndex;

          return Stack(
            children: [
              if (visibleIndex >= 0)
                _ElasticSelectionIndicator(
                  animation: _pullController,
                  fromIndex: _fromIndex >= 0 ? _fromIndex : visibleIndex,
                  targetIndex: visibleIndex,
                  itemWidth: itemWidth,
                  isDark: widget.isDark,
                  theme: widget.theme,
                ),
              Positioned.fill(
                child: Row(
                  children: [
                    for (var index = 0; index < widget.items.length; index++)
                      Expanded(
                        child: _LiquidGlassPillItem(
                          item: widget.items[index],
                          isDark: widget.isDark,
                          theme: widget.theme,
                          selected: index == visibleIndex,
                          compact: widget.compact,
                          onTap: () => _handleItemTap(index),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ElasticSelectionIndicator extends StatelessWidget {
  const _ElasticSelectionIndicator({
    required this.animation,
    required this.fromIndex,
    required this.targetIndex,
    required this.itemWidth,
    required this.isDark,
    required this.theme,
  });

  final Animation<double> animation;
  final int fromIndex;
  final int targetIndex;
  final double itemWidth;
  final bool isDark;
  final LiquidGlassNavTheme theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final activePrimary = theme.activeForeground(isDark);
        final activeSecondary = theme.activeSecondary(isDark);
        final progress = Curves.easeOutCubic.transform(animation.value);
        final stretch = Curves.easeInOutSine.transform(
          (1 - (2 * progress - 1).abs()).clamp(0.0, 1.0),
        );
        final distance = (targetIndex - fromIndex).abs().toDouble();
        final fromLeft = fromIndex * itemWidth + 5;
        final toLeft = targetIndex * itemWidth + 5;
        final baseLeft = lerpDouble(fromLeft, toLeft, progress)!;
        final pull = itemWidth * distance * stretch * 0.62;

        return PositionedDirectional(
          start: baseLeft - pull / 2,
          top: 6,
          width: itemWidth - 10 + pull,
          height: 52,
          child: Transform.scale(
            scaleX: 1 + stretch * 0.025,
            scaleY: 1 - stretch * 0.035,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28 + stretch * 8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withValues(alpha: isDark ? 0.46 : 0.20),
                    theme.secondary.withValues(alpha: isDark ? 0.34 : 0.15),
                    if (isDark)
                      Colors.white.withValues(alpha: 0.08)
                    else
                      Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: isDark
                      ? activePrimary.withValues(alpha: 0.46)
                      : theme.primary.withValues(alpha: 0.24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(
                      alpha: isDark ? 0.30 : 0.18,
                    ),
                    blurRadius: 24 + stretch * 6,
                    offset: const Offset(0, 10),
                  ),
                  if (isDark)
                    BoxShadow(
                      color: activeSecondary.withValues(alpha: 0.16),
                      blurRadius: 18,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiquidGlassPillItem extends StatelessWidget {
  const _LiquidGlassPillItem({
    required this.item,
    required this.isDark,
    required this.theme,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final LiquidGlassNavItem item;
  final bool isDark;
  final LiquidGlassNavTheme theme;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);
    final foreground = selected
        ? theme.activeForeground(isDark)
        : theme.textSecondary(isDark);

    return Tooltip(
      message: item.label,
      waitDuration: const Duration(milliseconds: 500),
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.04 : 1,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 3 : 5,
                vertical: 7,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: foreground, size: selected ? 23 : 21),
                  const SizedBox(height: 2),
                  AnimatedOpacity(
                    opacity: compact && !selected ? 0.72 : 1,
                    duration: duration,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: selected ? 10.5 : 9.5,
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassActionBubble extends StatefulWidget {
  const _LiquidGlassActionBubble({
    required this.isDark,
    required this.theme,
    required this.size,
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final bool isDark;
  final LiquidGlassNavTheme theme;
  final double size;
  final LiquidGlassNavItem destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_LiquidGlassActionBubble> createState() =>
      _LiquidGlassActionBubbleState();
}

class _LiquidGlassActionBubbleState extends State<_LiquidGlassActionBubble> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 210);
    final scale = _pressed ? 0.94 : (widget.isActive ? 1.05 : 1.0);

    return Tooltip(
      message: widget.destination.label,
      waitDuration: const Duration(milliseconds: 500),
      child: Semantics(
        button: true,
        selected: widget.isActive,
        label: widget.destination.label,
        child: AnimatedScale(
          scale: scale,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: _GlassShell(
                isDark: widget.isDark,
                theme: widget.theme,
                radius: widget.size / 2,
                active: widget.isActive,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.theme.action.withValues(
                          alpha: widget.isDark ? 0.34 : 0.30,
                        ),
                        widget.theme.primary.withValues(
                          alpha: widget.isDark ? 0.18 : 0.13,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    widget.destination.icon,
                    color: widget.isActive
                        ? widget.theme.activeForeground(widget.isDark)
                        : widget.theme.textPrimary(widget.isDark),
                    size: widget.isActive ? 28 : 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({
    required this.isDark,
    required this.theme,
    required this.radius,
    required this.child,
    this.active = false,
  });

  final bool isDark;
  final LiquidGlassNavTheme theme;
  final double radius;
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.14),
            blurRadius: active ? 30 : 26,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: theme.primary.withValues(
              alpha: active ? (isDark ? 0.28 : 0.20) : 0.08,
            ),
            blurRadius: active ? 30 : 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.64)
                  : Colors.white.withValues(alpha: 0.58),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.82),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.16 : 0.70),
                  Colors.white.withValues(alpha: isDark ? 0.06 : 0.32),
                  theme.secondary.withValues(alpha: isDark ? 0.08 : 0.10),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
