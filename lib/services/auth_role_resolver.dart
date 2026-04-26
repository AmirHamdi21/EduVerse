import '../models/auth_models.dart';

class AuthRoleResolver {
  static const String studentRole = 'student';
  static const String instructorRole = 'instructor';
  static const String teachingAssistantRole = 'teaching_assistant';
  static const String adminRole = 'admin';
  static const String itAdminRole = 'it_admin';

  static String dashboardRouteForUser(UserDto user) {
    if (hasRole(user, itAdminRole)) {
      return '/it-admin/dashboard';
    }
    if (hasRole(user, adminRole)) {
      return '/admin/dashboard';
    }
    if (hasRole(user, instructorRole)) {
      return '/instructor/dashboard';
    }
    if (hasRole(user, teachingAssistantRole)) {
      return '/ta/dashboard';
    }
    return '/dashboard';
  }

  static bool canAccessRoute(UserDto user, String location) {
    if (location.startsWith('/it-admin/')) {
      return hasRole(user, itAdminRole);
    }
    if (location.startsWith('/admin/')) {
      return hasRole(user, adminRole);
    }
    if (location.startsWith('/instructor/')) {
      return hasRole(user, instructorRole);
    }
    if (location.startsWith('/ta/')) {
      return hasRole(user, teachingAssistantRole);
    }

    return hasRole(user, studentRole);
  }

  static bool hasRole(UserDto user, String expectedRole) {
    final normalizedExpectedRole = normalizeRole(expectedRole);
    return user.roles.any(
      (role) => normalizeRole(role.roleName) == normalizedExpectedRole,
    );
  }

  static String normalizeRole(String rawRole) {
    final normalized = rawRole.trim().toLowerCase();
    switch (normalized) {
      case 'ta':
        return teachingAssistantRole;
      case 'it':
      case 'it-admin':
        return itAdminRole;
      default:
        return normalized;
    }
  }
}
