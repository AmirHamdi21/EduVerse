import 'package:edu_verse/models/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth models', () {
    test('AuthResponse parses string-based numeric auth payloads', () {
      final response = AuthResponse.fromJson(<String, dynamic>{
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'tokenType': 'Bearer',
        'expiresIn': '3600',
        'timestamp': '2026-04-24T09:30:00.000Z',
        'user': <String, dynamic>{
          'userId': '17',
          'email': 'student.tarek@example.com',
          'firstName': 'Student',
          'lastName': 'Tarek',
          'campusId': '2',
          'status': 'ACTIVE',
          'emailVerified': 'true',
          'createdAt': '2026-04-24T09:00:00.000Z',
          'roles': <Map<String, dynamic>>[
            <String, dynamic>{'roleId': '1', 'roleName': 'student'},
          ],
          'permissions': <String>['assignments.read'],
        },
      });

      expect(response.expiresIn, 3600);
      expect(response.user.userId, 17);
      expect(response.user.campusId, 2);
      expect(response.user.emailVerified, isTrue);
      expect(response.user.primaryRoleName, 'student');
      expect(response.user.roles.first.roleId, 1);
    });

    test('UserDto parses string role payloads without crashing', () {
      final user = UserDto.fromJson(<String, dynamic>{
        'id': '42',
        'email': 'ta@example.com',
        'firstName': 'Teaching',
        'lastName': 'Assistant',
        'status': 'ACTIVE',
        'emailVerified': 1,
        'createdAt': '2026-04-24T09:00:00.000Z',
        'roles': <dynamic>['TA'],
      });

      expect(user.userId, 42);
      expect(user.emailVerified, isTrue);
      expect(user.roles, hasLength(1));
      expect(user.roles.first.roleName, 'TA');
      expect(user.hasRole('ta'), isTrue);
    });
  });
}
