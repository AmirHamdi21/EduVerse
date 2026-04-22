import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_alerts_barrel.dart';

class ITCreateRuleDialog extends StatefulWidget {
  final bool isDark;
  final Function(AlertRule) onCreateRule;

  const ITCreateRuleDialog({
    super.key,
    required this.isDark,
    required this.onCreateRule,
  });

  @override
  State<ITCreateRuleDialog> createState() => _ITCreateRuleDialogState();
}

class _ITCreateRuleDialogState extends State<ITCreateRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _durationController = TextEditingController(text: '5');

  String _selectedService = 'Select service';
  AlertSeverity _selectedSeverity = AlertSeverity.warning;
  String _selectedMetric = 'Select metric';
  String _selectedOperator = '>';
  String _selectedTeam = 'Select team';

  final List<String> _services = [
    'Database',
    'API',
    'Web Server',
    'Cache',
    'All Services',
  ];
  final List<String> _metrics = [
    'cpu_usage',
    'memory_usage',
    'disk_usage',
    'api_latency',
    'error_rate',
    'request_count',
  ];
  final List<String> _operators = ['>', '<', '>=', '<=', '==', '!='];
  final List<String> _teams = [
    'DevOps Team',
    'Backend Team',
    'Frontend Team',
    'Security Team',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _thresholdController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        decoration: BoxDecoration(
          color: widget.isDark ? ITColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Rule Name',
                        hint: 'e.g., High CPU Usage Alert',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a rule name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe when this alert should fire...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Service',
                              value: _selectedService,
                              items: _services,
                              onChanged: (value) {
                                setState(
                                  () => _selectedService =
                                      value ?? _selectedService,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSeveritySelector()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Metric',
                        value: _selectedMetric,
                        items: _metrics,
                        onChanged: (value) {
                          setState(
                            () => _selectedMetric = value ?? _selectedMetric,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Operator',
                              value: _selectedOperator,
                              items: _operators,
                              onChanged: (value) {
                                setState(
                                  () => _selectedOperator =
                                      value ?? _selectedOperator,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _thresholdController,
                              label: 'Threshold',
                              hint: 'e.g., 90',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _durationController,
                              label: 'For Duration',
                              hint: 'minutes',
                              suffix: 'min',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Owner / Team',
                        value: _selectedTeam,
                        items: _teams,
                        onChanged: (value) {
                          setState(
                            () => _selectedTeam = value ?? _selectedTeam,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ITColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_alert_rounded,
              color: ITColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Alert Rule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ITColors.textPrimaryColor(widget.isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Define conditions and thresholds for system alerts',
                  style: TextStyle(
                    fontSize: 12,
                    color: ITColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ITColors.textPrimaryColor(widget.isDark),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: ITColors.textPrimaryColor(widget.isDark),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ITColors.textPrimaryColor(widget.isDark),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              hint: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: ITColors.textSecondaryColor(widget.isDark),
                ),
              ),
              isExpanded: true,
              dropdownColor: widget.isDark ? ITColors.darkCard : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ITColors.textSecondaryColor(widget.isDark),
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: ITColors.textPrimaryColor(widget.isDark),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ITColors.textPrimaryColor(widget.isDark),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: AlertSeverity.values.map((severity) {
            final isSelected = severity == _selectedSeverity;
            final color = _getSeverityColor(severity);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSeverity = severity),
                child: Container(
                  margin: EdgeInsets.only(
                    right: severity != AlertSeverity.info ? 6 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: color, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ITColors.textSecondaryColor(widget.isDark),
                side: BorderSide(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save as Draft'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ITColors.textSecondaryColor(widget.isDark),
                side: BorderSide(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return ITColors.error;
      case AlertSeverity.warning:
        return ITColors.warning;
      case AlertSeverity.info:
        return ITColors.info;
    }
  }
}
