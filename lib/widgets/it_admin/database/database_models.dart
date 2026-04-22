// Models for Database Management

class DatabaseInstance {
  final String id;
  final String name;
  final String type;
  final String status;
  final String version;
  final String host;
  final int port;
  final double storageUsed;
  final double storageTotal;
  final int activeConnections;
  final int maxConnections;
  final double queryLatency;

  DatabaseInstance({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.version,
    required this.host,
    required this.port,
    required this.storageUsed,
    required this.storageTotal,
    required this.activeConnections,
    required this.maxConnections,
    required this.queryLatency,
  });

  double get storagePercentage => (storageUsed / storageTotal) * 100;
  double get connectionPercentage => (activeConnections / maxConnections) * 100;
}

class DatabaseStats {
  final int totalDatabases;
  final int activeDatabases;
  final double totalStorage;
  final double usedStorage;
  final int totalConnections;
  final double avgLatency;

  DatabaseStats({
    required this.totalDatabases,
    required this.activeDatabases,
    required this.totalStorage,
    required this.usedStorage,
    required this.totalConnections,
    required this.avgLatency,
  });
}

class TableInfo {
  final String name;
  final int rows;
  final double size;
  final String lastUpdated;

  TableInfo({
    required this.name,
    required this.rows,
    required this.size,
    required this.lastUpdated,
  });
}
