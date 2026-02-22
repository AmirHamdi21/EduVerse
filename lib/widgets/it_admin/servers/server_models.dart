// Models for Server Management

class Server {
  final String id;
  final String name;
  final String type;
  final String status;
  final String ipAddress;
  final String region;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final String uptime;
  final String os;
  final int activeConnections;

  const Server({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.ipAddress,
    required this.region,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.uptime,
    required this.os,
    required this.activeConnections,
  });
}

class ServerStats {
  final int totalServers;
  final int onlineServers;
  final int offlineServers;
  final int maintenanceServers;
  final double avgCpu;
  final double avgMemory;

  const ServerStats({
    required this.totalServers,
    required this.onlineServers,
    required this.offlineServers,
    required this.maintenanceServers,
    required this.avgCpu,
    required this.avgMemory,
  });
}
