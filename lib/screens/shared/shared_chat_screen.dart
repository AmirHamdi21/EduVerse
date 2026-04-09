import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/shared/chat/shared_chat_detail_view.dart';
import '../../widgets/shared/chat/shared_conversation_list.dart';
import '../../widgets/shared/chat/shared_new_chat_dialog.dart';

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

  const SharedChatScreen({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc?>();

    // Error state: ChatBloc not provided
    if (chatBloc == null) {
      return _buildErrorScreen(
        context,
        'Chat service unavailable',
        'The chat feature could not be initialized. Please restart the app or contact support if this persists.',
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
                ),
        );
      },
    );
  }

  Widget _buildErrorScreen(BuildContext context, String title, String message) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
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

  const _MobileLayout({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
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
              leadingIcon: leadingIcon ?? Icons.arrow_back_ios_new_rounded,
              onLeadingPressed:
                  onLeadingPressed ??
                  () {
                    Navigator.of(context).maybePop();
                  },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: accentColor,
            onPressed: () => _showNewConversationDialog(context),
            tooltip: 'New Conversation',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    context.read<ChatBloc>().add(const ChatNewConversationDialogReset());

    showDialog<int?>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ChatBloc>(),
        child: const SharedNewChatDialog(),
      ),
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

  const _TabletDesktopLayout({
    super.key,
    required this.accentColor,
    this.currentUserName,
    this.currentUserId,
    this.isDark,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
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
                      leadingIcon:
                          leadingIcon ?? Icons.arrow_back_ios_new_rounded,
                      onLeadingPressed:
                          onLeadingPressed ??
                          () {
                            Navigator.of(context).maybePop();
                          },
                    ),
                  ),
                  // New conversation button at bottom of list
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                        ),
                        onPressed: () => _showNewConversationDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('New Conversation'),
                      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: accentColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a conversation',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose from your existing conversations\nor start a new one',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    context.read<ChatBloc>().add(const ChatNewConversationDialogReset());

    showDialog<int?>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ChatBloc>(),
        child: const SharedNewChatDialog(),
      ),
    );
  }
}
