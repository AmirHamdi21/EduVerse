import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'database_models.dart';

class TableListSection extends StatelessWidget {
  final bool isDark;
  final List<TableInfo> tables;
  final Function(TableInfo) onTableTap;

  const TableListSection({
    super.key,
    required this.isDark,
    required this.tables,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ITColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ITColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tables', style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...tables.map((table) => _buildTableRow(table)),
        ],
      ),
    );
  }

  Widget _buildTableRow(TableInfo table) {
    return GestureDetector(
      onTap: () => onTableTap(table),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ITColors.borderColor(isDark)))),
        child: Row(
          children: [
            Icon(Icons.table_chart_outlined, color: ITColors.textSecondaryColor(isDark), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(table.name, style: TextStyle(color: ITColors.textPrimaryColor(isDark), fontWeight: FontWeight.w500))),
            Text('${_formatNumber(table.rows)} rows', style: TextStyle(color: ITColors.textSecondaryColor(isDark), fontSize: 12)),
            const SizedBox(width: 12),
            Text('${table.size.toStringAsFixed(1)} MB', style: TextStyle(color: ITColors.textTertiaryColor(isDark), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }
}
