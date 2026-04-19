import 'core_api_client.dart';
import '../../models/student/grade_gpa_model.dart';
import '../../models/student/notification_unread_model.dart';

class StudentStatsService {
  final CoreApiClient _client;

  StudentStatsService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<GradeGpaModel> getStudentGpa(dynamic studentId) async {
    final response = await _client.dio.get('/grades/gpa/$studentId');

    if (response.data is Map<String, dynamic>) {
      return GradeGpaModel.fromJson(response.data as Map<String, dynamic>);
    }

    return GradeGpaModel(studentId: 0, gpa: 0);
  }

  Future<NotificationUnreadModel> getUnreadCount() async {
    final response = await _client.dio.get('/notifications/unread-count');

    if (response.data is Map<String, dynamic>) {
      return NotificationUnreadModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return const NotificationUnreadModel(unreadCount: 0);
  }
}
