import '../../bloc/auth/auth_state.dart';

class CurrentUserIdentity {
  final String displayName;
  final String initials;
  final String? profilePictureUrl;

  const CurrentUserIdentity({
    required this.displayName,
    required this.initials,
    this.profilePictureUrl,
  });

  factory CurrentUserIdentity.fromAuthState(
    AuthState state, {
    required String fallbackName,
  }) {
    if (state is! AuthAuthenticated) {
      return CurrentUserIdentity(
        displayName: fallbackName,
        initials: _computeInitials(fallbackName),
      );
    }

    final user = state.user;
    return CurrentUserIdentity(
      displayName: user.displayName.trim().isEmpty
          ? fallbackName
          : user.displayName,
      initials: user.initials,
      profilePictureUrl: user.profilePictureUrl,
    );
  }

  static String _computeInitials(String input) {
    final parts = input
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return '$first$second'.toUpperCase();
  }
}
