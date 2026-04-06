import '../models/auth_models.dart';

/// Demo credentials for development/testing purposes
/// Each role has a specific email/password combination
class DemoCredentials {
  // Student credentials
  static const String studentEmail = 'student@eduverse.dev';
  static const String studentPassword = 'Student@123';

  // Instructor credentials
  static const String instructorEmail = 'instructor@eduverse.dev';
  static const String instructorPassword = 'Instructor@123';

  // Teaching Assistant credentials
  static const String taEmail = 'ta@eduverse.dev';
  static const String taPassword = 'TA@123456';

  // Admin credentials
  static const String adminEmail = 'admin@eduverse.dev';
  static const String adminPassword = 'Admin@123';

  // IT Admin credentials
  static const String itAdminEmail = 'itadmin@eduverse.dev';
  static const String itAdminPassword = 'ITAdmin@123';

  /// Check if email/password matches a demo account
  /// Returns the user role if valid, null otherwise
  static String? validateDemoCredentials(String email, String password) {
    final emailLower = email.toLowerCase().trim();

    if (emailLower == studentEmail && password == studentPassword) {
      return 'STUDENT';
    }
    if (emailLower == instructorEmail && password == instructorPassword) {
      return 'INSTRUCTOR';
    }
    if (emailLower == taEmail && password == taPassword) {
      return 'TA';
    }
    if (emailLower == adminEmail && password == adminPassword) {
      return 'ADMIN';
    }
    if (emailLower == itAdminEmail && password == itAdminPassword) {
      return 'IT_ADMIN';
    }

    return null;
  }

  /// Check if an email is a demo account
  static bool isDemoEmail(String email) {
    final emailLower = email.toLowerCase().trim();
    return emailLower == studentEmail ||
        emailLower == instructorEmail ||
        emailLower == taEmail ||
        emailLower == adminEmail ||
        emailLower == itAdminEmail;
  }

  /// Get a mock UserDto for demo login
  static UserDto getDemoUser(String role) {
    switch (role) {
      case 'STUDENT':
        return UserDto(
          userId: 1001,
          email: studentEmail,
          firstName: 'Demo',
          lastName: 'Student',
          phone: '+1234567890',
          profilePictureUrl: null,
          campusId: 1,
          status: 'ACTIVE',
          emailVerified: true,
          lastLoginAt: DateTime.now().toIso8601String(),
          createdAt: '2024-01-01T00:00:00Z',
          roles: [const RoleModel(roleId: 0, roleName: 'STUDENT')],
        );
      case 'INSTRUCTOR':
        return UserDto(
          userId: 2001,
          email: instructorEmail,
          firstName: 'Demo',
          lastName: 'Instructor',
          phone: '+1234567891',
          profilePictureUrl: null,
          campusId: 1,
          status: 'ACTIVE',
          emailVerified: true,
          lastLoginAt: DateTime.now().toIso8601String(),
          createdAt: '2024-01-01T00:00:00Z',
          roles: [const RoleModel(roleId: 0, roleName: 'INSTRUCTOR')],
        );
      case 'TA':
        return UserDto(
          userId: 3001,
          email: taEmail,
          firstName: 'Demo',
          lastName: 'TA',
          phone: '+1234567892',
          profilePictureUrl: null,
          campusId: 1,
          status: 'ACTIVE',
          emailVerified: true,
          lastLoginAt: DateTime.now().toIso8601String(),
          createdAt: '2024-01-01T00:00:00Z',
          roles: [const RoleModel(roleId: 0, roleName: 'TA')],
        );
      case 'ADMIN':
        return UserDto(
          userId: 4001,
          email: adminEmail,
          firstName: 'Demo',
          lastName: 'Admin',
          phone: '+1234567893',
          profilePictureUrl: null,
          campusId: 1,
          status: 'ACTIVE',
          emailVerified: true,
          lastLoginAt: DateTime.now().toIso8601String(),
          createdAt: '2024-01-01T00:00:00Z',
          roles: [const RoleModel(roleId: 0, roleName: 'ADMIN')],
        );
      case 'IT_ADMIN':
        return UserDto(
          userId: 5001,
          email: itAdminEmail,
          firstName: 'Demo',
          lastName: 'IT Admin',
          phone: '+1234567894',
          profilePictureUrl: null,
          campusId: 1,
          status: 'ACTIVE',
          emailVerified: true,
          lastLoginAt: DateTime.now().toIso8601String(),
          createdAt: '2024-01-01T00:00:00Z',
          roles: [const RoleModel(roleId: 0, roleName: 'IT_ADMIN')],
        );
      default:
        throw Exception('Unknown role: $role');
    }
  }

  /// Get the dashboard route for a given role
  static String getDashboardRoute(String role) {
    switch (role) {
      case 'STUDENT':
        return '/dashboard';
      case 'INSTRUCTOR':
        return '/instructor/dashboard';
      case 'TA':
        return '/ta/dashboard'; // Future: create TA screens
      case 'ADMIN':
        return '/admin/dashboard'; // Future: create Admin screens
      case 'IT_ADMIN':
        return '/it-admin/dashboard'; // Future: create IT Admin screens
      default:
        return '/dashboard';
    }
  }

  /// Get the dashboard route based on user's roles
  static String getDashboardRouteForUser(UserDto user) {
    // Priority: IT_ADMIN > ADMIN > INSTRUCTOR > TA > STUDENT
    if (user.hasRole('IT_ADMIN')) {
      return getDashboardRoute('IT_ADMIN');
    }
    if (user.hasRole('ADMIN')) {
      return getDashboardRoute('ADMIN');
    }
    if (user.hasRole('INSTRUCTOR')) {
      return getDashboardRoute('INSTRUCTOR');
    }
    if (user.hasRole('TA')) {
      return getDashboardRoute('TA');
    }
    return getDashboardRoute('STUDENT');
  }

  /// Get all demo credentials as a list for display
  static List<Map<String, String>> getAllCredentials() {
    return [
      {'role': 'Student', 'email': studentEmail, 'password': studentPassword},
      {
        'role': 'Instructor',
        'email': instructorEmail,
        'password': instructorPassword,
      },
      {'role': 'Teaching Assistant', 'email': taEmail, 'password': taPassword},
      {'role': 'Admin', 'email': adminEmail, 'password': adminPassword},
      {'role': 'IT Admin', 'email': itAdminEmail, 'password': itAdminPassword},
    ];
  }
}
