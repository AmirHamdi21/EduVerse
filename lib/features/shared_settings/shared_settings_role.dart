import 'package:flutter/widgets.dart';

import '../../generated_l10n/app_localizations.dart';
import '../../screens/shared/profile/role_profile_theme.dart';
import '../../services/auth_role_resolver.dart';

enum SharedSettingsRole { student, instructor, ta }

extension SharedSettingsRoleX on SharedSettingsRole {
  String get queryValue {
    switch (this) {
      case SharedSettingsRole.student:
        return 'student';
      case SharedSettingsRole.instructor:
        return 'instructor';
      case SharedSettingsRole.ta:
        return 'ta';
    }
  }

  String get profileRoute {
    switch (this) {
      case SharedSettingsRole.student:
        return '/profile';
      case SharedSettingsRole.instructor:
        return '/instructor/profile';
      case SharedSettingsRole.ta:
        return '/ta/profile';
    }
  }

  String get editProfileRoute {
    switch (this) {
      case SharedSettingsRole.student:
        return '/edit-profile';
      case SharedSettingsRole.instructor:
        return '/instructor/edit-profile';
      case SharedSettingsRole.ta:
        return '/ta/edit-profile';
    }
  }

  String get fallbackRoute {
    switch (this) {
      case SharedSettingsRole.student:
        return '/dashboard';
      case SharedSettingsRole.instructor:
        return '/instructor/dashboard';
      case SharedSettingsRole.ta:
        return '/ta/dashboard';
    }
  }

  RoleProfileTheme get theme {
    switch (this) {
      case SharedSettingsRole.student:
        return RoleProfileTheme.student();
      case SharedSettingsRole.instructor:
        return RoleProfileTheme.instructor();
      case SharedSettingsRole.ta:
        return RoleProfileTheme.ta();
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case SharedSettingsRole.student:
        return l10n.studentRole;
      case SharedSettingsRole.instructor:
        return l10n.instructorRole;
      case SharedSettingsRole.ta:
        return l10n.taRole;
    }
  }

  String routeTo(String path) => '$path?role=$queryValue';

  static SharedSettingsRole fromRaw(String? value) {
    final normalized = AuthRoleResolver.normalizeRole(value ?? '');
    switch (normalized) {
      case AuthRoleResolver.instructorRole:
        return SharedSettingsRole.instructor;
      case AuthRoleResolver.teachingAssistantRole:
        return SharedSettingsRole.ta;
      case 'teachingassistant':
      case 'teaching assistant':
      case 'assistant':
        return SharedSettingsRole.ta;
      default:
        return SharedSettingsRole.student;
    }
  }
}

class SharedSettingsRoleScope extends InheritedWidget {
  final SharedSettingsRole role;

  const SharedSettingsRoleScope({
    super.key,
    required this.role,
    required super.child,
  });

  static SharedSettingsRole of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SharedSettingsRoleScope>();
    return scope?.role ?? SharedSettingsRole.student;
  }

  @override
  bool updateShouldNotify(SharedSettingsRoleScope oldWidget) {
    return oldWidget.role != role;
  }
}
