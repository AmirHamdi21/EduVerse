import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'database_models.dart';

class DatabaseStatsOverview extends StatelessWidget {
  final bool isDark;
  final DatabaseStats stats;

  const DatabaseStatsOverview({super.key, required this.isDark, required this.stats});

  @override
  Widget build(BuildContext context) {
    final usagePercent = (stats.usedStorage / stats.totalStorage * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF8B5CF6), const Color(0xFF8B5CF6).withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.storage_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Database Center', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Storage & Connections', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Text('$usagePercent% Used', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem('Databases', '${stats.totalDatabases}', Icons.dns_rounded),
              _buildDivider(),
              _buildStatItem('Active', '${stats.activeDatabases}', Icons.check_circle_outline_rounded),
              _buildDivider(),
              _buildStatItem('Connections', '${stats.totalConnections}', Icons.sync_alt_rounded),
              _buildDivider(),
              _buildStatItem('Latency', '${stats.avgLatency}ms', Icons.speed_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 50, color: Colors.white24);
}
