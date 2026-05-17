import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../utils/navigation/safe_back.dart';
import '../../widgets/shared/chat/shared_chat_detail_view.dart';
import '../../widgets/shared/chat/shared_conversation_list.dart';

/// Layout mode for responsive chat screen.
///
/// The layout mode is determined by screen width:
/// - [mobile]: Screen width < 600px - Shows either list or detail, not both
/// - [tabletDesktop]: Screen width >= 600px - Shows list and detail side-by-side
enum LayoutMode { mobile, tabletDesktop }

/// Unified chat screen shared by all 5 user roles in EduVerse.
///
/// ## Overview
/// This widget provides a responsive chat interface that adapts to different
/// screen sizes. It replaces the legacy role-specific chat screens with a
/// single unified implementation.
///
/// ## Responsive Breakpoint
/// - **Mobile (< 600px)**: Shows conversation list OR detail view (animated switch)
/// - **Tablet/Desktop (>= 600px)**: Shows 320px conversation list + flexible detail panel
///
/// ## Required Dependencies
/// This widget requires [ChatBloc] to be provided in the widget tree (typically
/// wrapped around MaterialApp in main.dart). If ChatBloc is not found, an error
/// screen is displayed.
///
/// ## Role-Specific Theming
/// Pass role-specific accent colors:
/// - **Student/IT Admin**: `Color(0xFF3B82F6)` (Blue)
/// - **Instructor/TA/Admin**: `Color(0xFF4F46E5)` (Indigo)
///
/// ## Example Usage
/// ```dart
/// SharedChatScreen(
///   accentColor: Color(0xFF3B82F6), // Blue for Student
///   title: 'Messages',
///   leadingIcon: Icons.menu,
///   onLeadingPressed: () => scaffoldKey.currentState?.openDrawer(),
/// )
/// ```
///
/// ## User Context
/// The widget automatically retrieves user ID and display name from [AuthBloc]
/// if not explicitly provided via [currentUserId] and [currentUserName] props.
///
/// See also:
/// - [SharedConversationList] - The conversation list component
/// - [SharedChatDetailView] - The message detail component
/// - [ChatBloc] - State management for chat functionality
class SharedChatScreen extends StatelessWidget {
  /// Accent color for theming (role-specific)
  /// Student/IT Admin: Color(0xFF3B82F6) - Blue
  /// Instructor/TA/Admin: Color(0xFF4F46E5) - Indigo
  final Color accentColor;

  /// Override for current user's display name (falls back to AuthBloc)
  final String? currentUserName;

  /// Override for current user's ID (falls back to AuthBloc)
  final int? currentUserId;

  /// Dark mode flag (if null, derived from Theme.brightness)
  final bool? isDark;

  /// Screen title shown in conversation list header
  final String? title;

  /// Leading icon for conversation list header
  final IconData? leadingIcon;

  /// Callback when leading icon is pressed
  final VoidCallback? onLeadingPressed;

  /// Route used when this screen is opened directly without a back stack.
  final String fallbackRoute;

  const SharedChatScreen({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    this.fallbackRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatBloc = context.read<ChatBloc?>();

    // Error state: ChatBloc not provided
    if (chatBloc == null) {
      return _buildErrorScreen(
        context,
        l10n.chatServiceUnavailableTitle,
        l10n.chatServiceUnavailableSubtitle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutMode = constraints.maxWidth >= 600
            ? LayoutMode.tabletDesktop
            : LayoutMode.mobile;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: layoutMode == LayoutMode.mobile
              ? _MobileLayout(
                  key: const ValueKey('mobile'),
                  accentColor: accentColor,
                  currentUserName: currentUserName,
                  currentUserId: currentUserId,
                  isDark: isDark,
                  title: title,
                  leadingIcon: leadingIcon,
                  onLeadingPressed: onLeadingPressed,
                  fallbackRoute: fallbackRoute,
                )
              : _TabletDesktopLayout(
                  key: const ValueKey('tabletDesktop'),
                  accentColor: accentColor,
                  currentUserName: currentUserName,
                  currentUserId: currentUserId,
                  isDark: isDark,
                  title: title,
                  leadingIcon: leadingIcon,
                  onLeadingPressed: onLeadingPressed,
                  fallbackRoute: fallbackRoute,
                ),
        );
      },
    );
  }

  Widget _buildErrorScreen(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.18),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.colorScheme.error.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.colorScheme.error,
                        Color.lerp(
                          theme.colorScheme.error,
                          theme.colorScheme.primary,
                          0.28,
                        )!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.sms_failed_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => safeBack(context, fallbackRoute),
                  icon: Icon(iosBackIcon(context)),
                  label: Text(l10n.chatGoBack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile layout: shows conversation list OR detail view (not both)
class _MobileLayout extends StatelessWidget {
  final Color accentColor;
  final String? currentUserName;
  final int? currentUserId;
  final bool? isDark;
  final String? title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final String fallbackRoute;

  const _MobileLayout({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    required this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveIsDark =
        isDark ?? Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
          previous.activeConversation != current.activeConversation,
      builder: (context, state) {
        final activeConversation = state.activeConversation;

        // If conversation selected, show detail view
        if (activeConversation != null) {
          final authState = context.read<AuthBloc>().state;
          final userId =
              currentUserId ??
              (authState is AuthAuthenticated ? authState.user.userId : 0);
          final userName =
              currentUserName ??
              (authState is AuthAuthenticated
                  ? authState.user.displayName
                  : null);

          return Scaffold(
            body: SafeArea(
              child: SharedChatDetailView(
                conversation: activeConversation,
                currentUserId: userId,
                currentUserName: userName,
                accentColor: accentColor,
                isDark: effectiveIsDark,
                onBack: () {
                  context.read<ChatBloc>().add(const DeselectConversation());
                },
              ),
            ),
          );
        }

        // Otherwise show conversation list
        return Scaffold(
          body: SafeArea(
            child: SharedConversationList(
              accentColor: accentColor,
              isDark: effectiveIsDark,
              title: title ?? l10n.messages,
              leadingIcon: leadingIcon ?? iosBackIcon(context),
              onLeadingPressed:
                  onLeadingPressed ??
                  () {
                    safeBack(context, fallbackRoute);
                  },
            ),
          ),
        );
      },
    );
  }
}

/// Tablet/Desktop layout: shows conversation list AND detail view side-by-side
class _TabletDesktopLayout extends StatelessWidget {
  final Color accentColor;
  final String? currentUserName;
  final int? currentUserId;
  final bool? isDark;
  final String? title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final String fallbackRoute;

  const _TabletDesktopLayout({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    required this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final effectiveIsDark = isDark ?? theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Conversation list panel (fixed width)
            SizedBox(
              width: 320,
              child: Column(
                children: [
                  Expanded(
                    child: SharedConversationList(
                      accentColor: accentColor,
                      isDark: effectiveIsDark,
                      title: title ?? l10n.messages,
                      leadingIcon: leadingIcon ?? iosBackIcon(context),
                      onLeadingPressed:
                          onLeadingPressed ??
                          () {
                            safeBack(context, fallbackRoute);
                          },
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              width: 1,
              color: theme.dividerColor.withValues(alpha: 0.3),
            ),
            // Detail panel
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) =>
                    previous.activeConversation != current.activeConversation,
                builder: (context, state) {
                  final activeConversation = state.activeConversation;

                  if (activeConversation == null) {
                    return _buildEmptyDetailPlaceholder(context);
                  }

                  final authState = context.read<AuthBloc>().state;
                  final userId =
                      currentUserId ??
                      (authState is AuthAuthenticated
                          ? authState.user.userId
                          : 0);
                  final userName =
                      currentUserName ??
                      (authState is AuthAuthenticated
                          ? authState.user.displayName
                          : null);

                  return SharedChatDetailView(
                    conversation: activeConversation,
                    currentUserId: userId,
                    currentUserName: userName,
                    accentColor: accentColor,
                    isDark: effectiveIsDark,
                    // No back button on tablet/desktop - list is always visible
                    onBack: null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDetailPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIsDark = isDark ?? theme.brightness == Brightness.dark;

    return Container(
      color: effectiveIsDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : theme.colorScheme.surfaceContainerLowest,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
          decoration: BoxDecoration(
            color: effectiveIsDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: accentColor.withValues(
                alpha: effectiveIsDark ? 0.18 : 0.10,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accentColor.withValues(
                  alpha: effectiveIsDark ? 0.18 : 0.08,
                ),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      accentColor,
                      Color.lerp(accentColor, const Color(0xFF06B6D4), 0.28)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context).chatSelectConversationTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).chatSelectConversationSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
