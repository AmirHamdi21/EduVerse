import '../../models/notifications/notification_model.dart';

class NotificationActionResolver {
  static String? resolveRoute(
    NotificationModel notification, {
    required String rolePrefix,
  }) {
    final actionUrl = notification.actionUrl?.trim();
    final resolvedFromActionUrl = _resolveFromActionUrl(
      actionUrl,
      rolePrefix: rolePrefix,
    );
    if (resolvedFromActionUrl != null) {
      return resolvedFromActionUrl;
    }

    switch (notification.type) {
      case NotificationType.announcement:
        return rolePrefix == '/student'
            ? '/student/announcements'
            : '$rolePrefix/announcements';
      case NotificationType.assignment:
        return _assignmentFallback(notification, rolePrefix: rolePrefix);
      case NotificationType.lab:
        return _labFallback(notification, rolePrefix: rolePrefix);
      case NotificationType.quiz:
        return rolePrefix == '/student'
            ? '/student/quizzes'
            : '$rolePrefix/quiz-management';
      case NotificationType.grade:
        return rolePrefix == '/student' ? '/grades' : '$rolePrefix/grading';
      case NotificationType.discussion:
      case NotificationType.community:
      case NotificationType.message:
        return rolePrefix == '/student'
            ? '/discussions'
            : '$rolePrefix/discussions';
      case NotificationType.material:
      case NotificationType.enrollment:
      case NotificationType.schedule:
      case NotificationType.officeHours:
      case NotificationType.deadline:
      case NotificationType.system:
      case NotificationType.unknown:
        return rolePrefix == '/student' ? '/courses' : '$rolePrefix/dashboard';
    }
  }

  static String? _resolveFromActionUrl(
    String? actionUrl, {
    required String rolePrefix,
  }) {
    if (actionUrl == null || actionUrl.isEmpty || !actionUrl.startsWith('/')) {
      return null;
    }

    if (actionUrl == '/schedule') {
      return rolePrefix == '/student' ? '/calendar' : '$rolePrefix/calendar';
    }

    final courseAssignment = RegExp(r'^/courses/(\d+)/assignments/(\d+)$');
    final courseAssignmentSubmissions = RegExp(
      r'^/courses/(\d+)/assignments/(\d+)/submissions$',
    );
    final courseLab = RegExp(r'^/courses/(\d+)/labs/(\d+)$');
    final courseLabSubmissions = RegExp(r'^/courses/(\d+)/labs/(\d+)/submissions$');
    final courseQuiz = RegExp(r'^/courses/(\d+)/quizzes/(\d+)$');
    final staffGrading = RegExp(r'^/instructor/courses/(\d+)/grading$');
    final staffLabDetail = RegExp(r'^/instructor/courses/(\d+)/labs/(\d+)$');

    final assignmentMatch = courseAssignment.firstMatch(actionUrl);
    if (assignmentMatch != null) {
      final courseId = assignmentMatch.group(1);
      return rolePrefix == '/student'
          ? '/assignments?courseId=$courseId'
          : '$rolePrefix/assignments';
    }

    final assignmentSubmissionsMatch = courseAssignmentSubmissions.firstMatch(
      actionUrl,
    );
    if (assignmentSubmissionsMatch != null) {
      final assignmentId = assignmentSubmissionsMatch.group(2);
      if (rolePrefix == '/student') {
        final courseId = assignmentSubmissionsMatch.group(1);
        return '/assignments?courseId=$courseId';
      }
      return '$rolePrefix/assignments/$assignmentId/submissions';
    }

    final labMatch = courseLab.firstMatch(actionUrl);
    if (labMatch != null) {
      final courseId = labMatch.group(1);
      final labId = labMatch.group(2);
      if (rolePrefix == '/student') {
        return '/labs?courseId=$courseId';
      }
      if (rolePrefix == '/instructor') {
        return '/instructor/labs/$labId';
      }
      if (rolePrefix == '/ta') {
        return '/ta/lab/$labId';
      }
    }

    final labSubmissionsMatch = courseLabSubmissions.firstMatch(actionUrl);
    if (labSubmissionsMatch != null) {
      final courseId = labSubmissionsMatch.group(1);
      final labId = labSubmissionsMatch.group(2);
      if (rolePrefix == '/student') {
        return '/labs?courseId=$courseId';
      }
      if (rolePrefix == '/instructor') {
        return '/instructor/labs/$labId?tab=submissions';
      }
      if (rolePrefix == '/ta') {
        return '/ta/lab/$labId?tab=submissions';
      }
    }

    final quizMatch = courseQuiz.firstMatch(actionUrl);
    if (quizMatch != null) {
      return rolePrefix == '/student'
          ? '/student/quizzes'
          : '$rolePrefix/quiz-management';
    }

    if (staffGrading.hasMatch(actionUrl)) {
      return '$rolePrefix/grading';
    }

    final staffLabMatch = staffLabDetail.firstMatch(actionUrl);
    if (staffLabMatch != null) {
      final labId = staffLabMatch.group(2);
      if (rolePrefix == '/instructor') {
        return '/instructor/labs/$labId';
      }
      if (rolePrefix == '/ta') {
        return '/ta/lab/$labId';
      }
    }

    return null;
  }

  static String _assignmentFallback(
    NotificationModel notification, {
    required String rolePrefix,
  }) {
    final assignmentId = notification.relatedEntityId;
    if (assignmentId != null && rolePrefix != '/student') {
      return '$rolePrefix/assignments/$assignmentId/submissions';
    }
    return rolePrefix == '/student'
        ? '/assignments'
        : '$rolePrefix/assignments';
  }

  static String _labFallback(
    NotificationModel notification, {
    required String rolePrefix,
  }) {
    final labId = notification.relatedEntityId;
    if (labId != null) {
      if (rolePrefix == '/instructor') {
        return '/instructor/labs/$labId';
      }
      if (rolePrefix == '/ta') {
        return '/ta/lab/$labId';
      }
    }
    return rolePrefix == '/student' ? '/labs' : '$rolePrefix/labs';
  }
}
