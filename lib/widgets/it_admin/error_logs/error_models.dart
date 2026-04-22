// Models for Error Logs

class ErrorLog {
  final String id;
  final String type;
  final String message;
  final String source;
  final String severity;
  final String timestamp;
  final String stackTrace;
  final String userId;
  final String requestId;
  final int occurrences;
  final bool isResolved;

  ErrorLog({
    required this.id,
    required this.type,
    required this.message,
    required this.source,
    required this.severity,
    required this.timestamp,
    required this.stackTrace,
    required this.userId,
    required this.requestId,
    required this.occurrences,
    required this.isResolved,
  });
}

class ErrorStats {
  final int totalErrors;
  final int criticalErrors;
  final int warningErrors;
  final int resolvedToday;
  final int unresolvedErrors;
  final double resolutionRate;

  ErrorStats({
    required this.totalErrors,
    required this.criticalErrors,
    required this.warningErrors,
    required this.resolvedToday,
    required this.unresolvedErrors,
    required this.resolutionRate,
  });
}
