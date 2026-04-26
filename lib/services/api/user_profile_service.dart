import '../../bloc/profile/profile_models.dart';
import 'core_api_client.dart';

class UserProfileService {
  final CoreApiClient _client;

  UserProfileService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<UserProfile> getProfile() async {
    final response = await _client.dio.get('/users/profile');
    final payload = _extractMap(response.data);
    return UserProfile.fromJson(payload);
  }

  Future<UserProfile> updateProfile(UpdateUserProfileRequest request) async {
    final response = await _client.dio.put(
      '/users/profile',
      data: request.toJson(),
    );
    final payload = _extractMap(response.data);
    return UserProfile.fromJson(payload);
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _client.dio.patch('/users/password', data: request.toJson());
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    return <String, dynamic>{};
  }
}
