// Models for API Management

class ApiEndpoint {
  final String id;
  final String name;
  final String method;
  final String path;
  final String version;
  final String status;
  final int requestsToday;
  final double avgResponseTime;
  final double successRate;
  final String rateLimit;

  ApiEndpoint({
    required this.id,
    required this.name,
    required this.method,
    required this.path,
    required this.version,
    required this.status,
    required this.requestsToday,
    required this.avgResponseTime,
    required this.successRate,
    required this.rateLimit,
  });
}

class ApiKey {
  final String id;
  final String name;
  final String key;
  final String status;
  final String createdAt;
  final String expiresAt;
  final int requestsToday;
  final List<String> scopes;

  ApiKey({
    required this.id,
    required this.name,
    required this.key,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.requestsToday,
    required this.scopes,
  });
}

class ApiStats {
  final int totalEndpoints;
  final int activeEndpoints;
  final int deprecatedEndpoints;
  final int totalRequests;
  final double avgResponseTime;
  final double uptime;

  ApiStats({
    required this.totalEndpoints,
    required this.activeEndpoints,
    required this.deprecatedEndpoints,
    required this.totalRequests,
    required this.avgResponseTime,
    required this.uptime,
  });
}
