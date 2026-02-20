import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/alerts/it_alerts_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITAlertsScreen extends StatefulWidget {
  const ITAlertsScreen({super.key});

  @override
  State<ITAlertsScreen> createState() => _ITAlertsScreenState();
}

class _ITAlertsScreenState extends State<ITAlertsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // State
  AlertTab _selectedTab = AlertTab.rules;
  String _searchQuery = '';
  AlertSeverity? _selectedSeverity;
  
  // Data
  AlertStats _stats = const AlertStats(
    activeAlerts: 0,
    resolvedAlerts: 0,
    suppressedAlerts: 0,
    noiseScore: 0,
    activeHistory: [],
    resolvedHistory: [],
  );
  List<AlertRule> _rules = [];
  List<NotificationChannel> _channels = [];
  List<SuppressionWindow> _suppressionWindows = [];
  List<EscalationPolicy> _escalationPolicies = [];
  List<AlertHistoryEntry> _history = [];
  List<AiSuggestion> _aiSuggestions = [];
  List<AlertMetric> _alertMetrics = [];
  List<NoisyRule> _noisyRules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _stats = _getMockStats();
      _rules = _getMockRules();
      _channels = _getMockChannels();
      _suppressionWindows = _getMockSuppressionWindows();
      _escalationPolicies = _getMockEscalationPolicies();
      _history = _getMockHistory();
      _aiSuggestions = _getMockAiSuggestions();
      _alertMetrics = _getMockAlertMetrics();
      _noisyRules = _getMockNoisyRules();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  AlertStats _getMockStats() {
    return const AlertStats(
      activeAlerts: 3,
      resolvedAlerts: 28,
      suppressedAlerts: 12,
      noiseScore: 42,
      activeHistory: [2, 5, 3, 7, 4, 6, 3],
      resolvedHistory: [8, 12, 15, 10, 18, 14, 20],
    );
  }

  List<AlertRule> _getMockRules() {
    final now = DateTime.now();
    return [
      AlertRule(
        id: 'r1',
        name: 'DB Replication Lag > 5s',
        description: 'Alert when database replication lag exceeds 5 seconds',
        service: 'Database',
        severity: AlertSeverity.critical,
        metric: 'replication_lag',
        operator: '>',
        threshold: 5000,
        forDuration: const Duration(minutes: 3),
        isEnabled: true,
        tags: ['production', 'database'],
        lastTriggered: now.subtract(const Duration(hours: 2)),
        triggerCount: 15,
      ),
      AlertRule(
        id: 'r2',
        name: 'API P95 Latency High',
        description: 'API P95 latency exceeds threshold',
        service: 'API Gateway',
        severity: AlertSeverity.warning,
        metric: 'api_latency',
        operator: '>',
        threshold: 500,
        forDuration: const Duration(minutes: 5),
        isEnabled: true,
        tags: ['api', 'latency'],
        lastTriggered: now.subtract(const Duration(hours: 5)),
        triggerCount: 42,
      ),
      AlertRule(
        id: 'r3',
        name: 'AI Queue Backup',
        description: 'AI processing queue depth exceeds normal range',
        service: 'AI Service',
        severity: AlertSeverity.warning,
        metric: 'queue_depth',
        operator: '>',
        threshold: 1000,
        forDuration: const Duration(minutes: 10),
        isEnabled: true,
        tags: ['ai', 'queue'],
        lastTriggered: now.subtract(const Duration(days: 1)),
        triggerCount: 8,
      ),
      AlertRule(
        id: 'r4',
        name: 'Backup Failure Detection',
        description: 'Automated backup job failed',
        service: 'Backup Service',
        severity: AlertSeverity.critical,
        metric: 'backup_status',
        operator: '==',
        threshold: 0,
        forDuration: const Duration(minutes: 1),
        isEnabled: false,
        tags: ['backup', 'critical'],
        triggerCount: 3,
      ),
    ];
  }

  List<NotificationChannel> _getMockChannels() {
    return [
      const NotificationChannel(
        id: 'c1',
        name: 'Critical Alerts Slack',
        type: ChannelType.slack,
        description: 'Slack channel for critical alerts',
        config: {
          'Alerts-critical': 'sms-call',
          'Webhook': '#ops-alerts',
        },
        isEnabled: true,
        isVerified: true,
      ),
      const NotificationChannel(
        id: 'c2',
        name: 'IT Team Email',
        type: ChannelType.email,
        description: 'Email distribution for IT team',
        config: {
          'it-team@EduVerse.edu': 'main',
          'ops@EduVerse.edu': 'cc',
        },
        isEnabled: true,
        isVerified: true,
      ),
      const NotificationChannel(
        id: 'c3',
        name: 'PagerDuty On-Call',
        type: ChannelType.pagerDuty,
        description: 'PagerDuty escalation service',
        config: {
          'On-Call Engineers': 'primary',
        },
        isEnabled: true,
        isVerified: true,
      ),
      const NotificationChannel(
        id: 'c4',
        name: 'SMS Emergency',
        type: ChannelType.sms,
        description: 'Emergency SMS notifications',
        config: {
          '+1 (555) 123-4567': 'primary',
          '+1 (555) 234-5678': 'backup',
        },
        isEnabled: true,
        isVerified: false,
      ),
    ];
  }

  List<SuppressionWindow> _getMockSuppressionWindows() {
    final now = DateTime.now();
    return [
      SuppressionWindow(
        id: 'sw1',
        name: 'Weekly Maintenance Window',
        description: 'Regular weekly maintenance period',
        startTime: DateTime(now.year, now.month, now.day + (7 - now.weekday), 2, 0),
        endTime: DateTime(now.year, now.month, now.day + (7 - now.weekday), 6, 0),
        affectedServices: ['All Services'],
        isRecurring: true,
        recurringPattern: 'Weekly',
        isActive: true,
      ),
      SuppressionWindow(
        id: 'sw2',
        name: 'Database Migration',
        description: 'Scheduled database migration window',
        startTime: DateTime(2025, 11, 22, 20, 0),
        endTime: DateTime(2025, 11, 22, 23, 0),
        affectedServices: ['Database', 'API Gateway'],
        isRecurring: false,
        isActive: true,
      ),
    ];
  }

  List<EscalationPolicy> _getMockEscalationPolicies() {
    return [
      const EscalationPolicy(
        id: 'ep1',
        name: 'Critical Alert Escalation',
        description: 'Slack → PagerDuty → SMS Manager',
        steps: [
          EscalationStep(
            stepNumber: 1,
            target: 'Slack',
            targetType: 'Slack',
            delayAfter: Duration(minutes: 5),
          ),
          EscalationStep(
            stepNumber: 2,
            target: 'PagerDuty',
            targetType: 'PagerDuty',
            delayAfter: Duration(minutes: 10),
          ),
          EscalationStep(
            stepNumber: 3,
            target: 'SMS Manager',
            targetType: 'SMS Manager',
            delayAfter: Duration.zero,
          ),
        ],
        isEnabled: true,
      ),
      const EscalationPolicy(
        id: 'ep2',
        name: 'Database Team Escalation',
        description: 'Email Team → On-Call Engineer',
        steps: [
          EscalationStep(
            stepNumber: 1,
            target: 'Email Team',
            targetType: 'Email Team',
            delayAfter: Duration(minutes: 15),
          ),
          EscalationStep(
            stepNumber: 2,
            target: 'On-Call Engineer',
            targetType: 'On-Call Engineer',
            delayAfter: Duration.zero,
          ),
        ],
        isEnabled: true,
      ),
    ];
  }

  List<AlertHistoryEntry> _getMockHistory() {
    final now = DateTime.now();
    return [
      AlertHistoryEntry(
        id: 'h1',
        timestamp: DateTime(2025, 11, 20, 14, 32, 0),
        ruleName: 'DB Replication Lag',
        severity: AlertSeverity.critical,
        status: 'Resolved',
      ),
      AlertHistoryEntry(
        id: 'h2',
        timestamp: DateTime(2025, 11, 20, 12, 15, 0),
        ruleName: 'API P95 Latency',
        severity: AlertSeverity.warning,
        status: 'Acknowledged',
      ),
      AlertHistoryEntry(
        id: 'h3',
        timestamp: now.subtract(const Duration(hours: 6)),
        ruleName: 'AI Queue Backup',
        severity: AlertSeverity.warning,
        status: 'Resolved',
      ),
    ];
  }

  List<AiSuggestion> _getMockAiSuggestions() {
    return const [
      AiSuggestion(
        id: 's1',
        type: 'threshold',
        title: 'Threshold Suggestion',
        description: 'DB lag threshold should be 3s (not 5s) based on 30d history',
        confidence: 92,
        actionLabel: 'Apply Suggestion',
      ),
      AiSuggestion(
        id: 's2',
        type: 'noise',
        title: 'Noise Reduction',
        description: 'Group 3 correlated API latency alerts into single notification',
        confidence: 87,
        actionLabel: 'Review Grouping',
      ),
      AiSuggestion(
        id: 's3',
        type: 'window',
        title: 'Optimal Window',
        description: 'Use 5-minute aggregation for API latency (currently 1m)',
        confidence: 78,
        actionLabel: 'Update Window',
      ),
    ];
  }

  List<AlertMetric> _getMockAlertMetrics() {
    return const [
      AlertMetric(name: 'Alerts per Day', value: 42, change: 15),
      AlertMetric(name: 'False Positives', value: '8%', change: 8),
      AlertMetric(name: 'Avg Time to Ack', value: '4.2 min'),
    ];
  }

  List<NoisyRule> _getMockNoisyRules() {
    return const [
      NoisyRule(name: 'API Latency', count: 124),
      NoisyRule(name: 'Memory Usage', count: 89),
      NoisyRule(name: 'Error Rate', count: 67),
    ];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleRuleTap(AlertRule rule) {
    _showSnackBar('Viewing rule: ${rule.name}');
  }

  void _handleRuleToggle(AlertRule rule) {
    setState(() {
      final index = _rules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _rules[index] = rule.copyWith(isEnabled: !rule.isEnabled);
      }
    });
    _showSnackBar('${rule.name} ${rule.isEnabled ? 'disabled' : 'enabled'}');
  }

  void _handleCreateRule() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showDialog(
      context: context,
      builder: (context) => ITCreateRuleDialog(
        isDark: isDark,
        onCreateRule: (rule) {
          setState(() => _rules.add(rule));
          _showSnackBar('Rule created: ${rule.name}');
        },
      ),
    );
  }

  void _handleChannelTap(NotificationChannel channel) {
    _showSnackBar('Viewing channel: ${channel.name}');
  }

  void _handleChannelToggle(NotificationChannel channel) {
    setState(() {
      final index = _channels.indexWhere((c) => c.id == channel.id);
      if (index != -1) {
        _channels[index] = channel.copyWith(isEnabled: !channel.isEnabled);
      }
    });
    _showSnackBar('${channel.name} ${channel.isEnabled ? 'disabled' : 'enabled'}');
  }

  void _handleTestChannel(NotificationChannel channel) {
    _showSnackBar('Testing channel: ${channel.name}...');
  }

  void _handleEditChannel(NotificationChannel channel) {
    _showSnackBar('Editing channel: ${channel.name}');
  }

  void _handleAddChannel() {
    _showSnackBar('Opening add channel dialog...');
  }

  void _handleWindowTap(SuppressionWindow window) {
    _showSnackBar('Viewing window: ${window.name}');
  }

  void _handleCreateWindow() {
    _showSnackBar('Creating suppression window...');
  }

  void _handlePolicyTap(EscalationPolicy policy) {
    _showSnackBar('Viewing policy: ${policy.name}');
  }

  void _handleCreatePolicy() {
    _showSnackBar('Creating escalation policy...');
  }

  void _handleHistoryEntryTap(AlertHistoryEntry entry) {
    _showSnackBar('Viewing alert: ${entry.ruleName}');
  }

  void _handleApplySuggestion(AiSuggestion suggestion) {
    _showSnackBar('Applying: ${suggestion.title}');
  }

  void _handleDismissSuggestion(AiSuggestion suggestion) {
    setState(() {
      _aiSuggestions.removeWhere((s) => s.id == suggestion.id);
    });
    _showSnackBar('Suggestion dismissed');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          drawer: ITDrawer(currentRoute: '/it-admin/alerts', isDark: isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF7ED),
                          Colors.white,
                          Color(0xFFECFDF5),
                        ],
                      ),
                    ),
              child: _buildContent(isDark, l10n),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: ITColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: CustomScrollView(
        slivers: [
          ITAlertsAppBar(
            isDark: isDark,
            title: l10n.itAlertsTitle,
            subtitle: l10n.itAlertsSubtitle,
            onSettingsTap: () => _showSnackBar('Opening alert settings...'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Cards
                ITAlertsStatsCards(
                  isDark: isDark,
                  stats: _stats,
                  onViewHistory: () => setState(() => _selectedTab = AlertTab.history),
                  onManageWindows: () => setState(() => _selectedTab = AlertTab.suppress),
                ),
                const SizedBox(height: 20),

                // Tab Bar
                ITAlertsTabBar(
                  isDark: isDark,
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                ),
                const SizedBox(height: 20),

                // Tab Content
                _buildTabContent(isDark),
                const SizedBox(height: 20),

                // AI Tuning Advisor
                ITAiTuningAdvisor(
                  isDark: isDark,
                  suggestions: _aiSuggestions,
                  onApplySuggestion: _handleApplySuggestion,
                  onDismissSuggestion: _handleDismissSuggestion,
                ),
                const SizedBox(height: 20),

                // Alert Metrics
                ITAlertMetricsSection(
                  isDark: isDark,
                  metrics: _alertMetrics,
                  noisyRules: _noisyRules,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case AlertTab.rules:
        return ITAlertsRulesTab(
          isDark: isDark,
          rules: _rules,
          searchQuery: _searchQuery,
          selectedSeverity: _selectedSeverity,
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onSeverityChanged: (severity) => setState(() => _selectedSeverity = severity),
          onRuleTap: _handleRuleTap,
          onRuleToggle: _handleRuleToggle,
          onCreateRule: _handleCreateRule,
        );
      case AlertTab.channels:
        return ITAlertsChannelsTab(
          isDark: isDark,
          channels: _channels,
          onChannelTap: _handleChannelTap,
          onChannelToggle: _handleChannelToggle,
          onTestChannel: _handleTestChannel,
          onEditChannel: _handleEditChannel,
          onAddChannel: _handleAddChannel,
        );
      case AlertTab.escalation:
        return ITAlertsEscalationTab(
          isDark: isDark,
          policies: _escalationPolicies,
          onPolicyTap: _handlePolicyTap,
          onCreatePolicy: _handleCreatePolicy,
        );
      case AlertTab.suppress:
        return ITAlertsSuppressTab(
          isDark: isDark,
          windows: _suppressionWindows,
          onWindowTap: _handleWindowTap,
          onCreateWindow: _handleCreateWindow,
        );
      case AlertTab.history:
        return ITAlertsHistoryTab(
          isDark: isDark,
          history: _history,
          onEntryTap: _handleHistoryEntryTap,
        );
    }
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: ITColors.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ITColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: ITColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: ITColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
