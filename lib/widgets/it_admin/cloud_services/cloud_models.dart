// Models for Cloud Services Management

class CloudProvider {
  final String name;
  final int services;
  final double cost;
  final String logo;

  CloudProvider({
    required this.name,
    required this.services,
    required this.cost,
    required this.logo,
  });
}

class CloudService {
  final String id;
  final String name;
  final String provider;
  final String type;
  final String status;
  final String region;
  final double monthlyCost;
  final int usagePercent;
  final String lastSync;

  CloudService({
    required this.id,
    required this.name,
    required this.provider,
    required this.type,
    required this.status,
    required this.region,
    required this.monthlyCost,
    required this.usagePercent,
    required this.lastSync,
  });
}

class CloudStats {
  final int totalServices;
  final int activeServices;
  final double totalCost;
  final double budgetUsed;
  final double avgUptime;
  final int regions;

  CloudStats({
    required this.totalServices,
    required this.activeServices,
    required this.totalCost,
    required this.budgetUsed,
    required this.avgUptime,
    required this.regions,
  });
}
