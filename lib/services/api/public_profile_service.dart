import 'package:dio/dio.dart';

import 'core_api_client.dart';
import '../../models/student/public_profile_model.dart';

class PublicProfileService {
  final CoreApiClient _client;

  PublicProfileService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<PublicProfileModel> getPublicProfile(
    dynamic userId, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.dio.get(
      '/users/$userId/public',
      cancelToken: cancelToken,
    );

    if (response.data is Map<String, dynamic>) {
      return PublicProfileModel.fromJson(response.data as Map<String, dynamic>);
    }

    return PublicProfileModel.fromJson(<String, dynamic>{
      'userId': userId,
      'firstName': '',
      'lastName': '',
      'email': '',
    });
  }
}
