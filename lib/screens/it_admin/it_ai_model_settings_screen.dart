import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/ai_model_settings/it_ai_model_settings_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITAIModelSettingsScreen extends StatefulWidget {
  const ITAIModelSettingsScreen({super.key});

  @override
  State<ITAIModelSettingsScreen> createState() => _ITAIModelSettingsScreenState();
}

class _ITAIModelSettingsScreenState extends State<ITAIModelSettingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  // AI Provider settings
  AIProvider _selectedProvider = AIProvider.openai;
  AIModel _selectedModel = AIModel.gpt4Turbo;
  String _apiKey = 'sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz';
  bool _autoRotateEnabled = true;

  // Governance rules
  GovernanceRules _governanceRules = const GovernanceRules();

  // System limits
  SystemLimits _systemLimits = const SystemLimits();

  // Request logs
  AIRequestStats _stats = const AIRequestStats(
    successRate: 87.5,
    activeProviders: 2,
    requestsPerMinute: 24,
    totalRequests: 1248,
  );
  List<AIRequestLog> _logs = [];

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

      _logs = _getMockLogs();

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

  List<AIRequestLog> _getMockLogs() {
    final now = DateTime.now();
    return [
      AIRequestLog(
        id: '1',
        timestamp: now.subtract(const Duration(minutes: 2)),
        userId: 'u1',
        userName: 'john.doe@EduVerse.edu',
        provider: AIProvider.openai,
        model: AIModel.gpt4Turbo,
        status: RequestStatus.success,
        tokensUsed: 1250,
        responseTime: 1200,
      ),
      AIRequestLog(
        id: '2',
        timestamp: now.subtract(const Duration(minutes: 5)),
        userId: 'u2',
        userName: 'jane.smith@EduVerse.edu',
        provider: AIProvider.claude,
        model: AIModel.claude35Sonnet,
        status: RequestStatus.success,
        tokensUsed: 890,
        responseTime: 950,
      ),
      AIRequestLog(
        id: '3',
        timestamp: now.subtract(const Duration(minutes: 12)),
        userId: 'u3',
        userName: 'api_service_01',
        provider: AIProvider.openai,
        model: AIModel.gpt4Turbo,
        status: RequestStatus.rateLimited,
        errorMessage: 'Rate limit exceeded',
      ),
      AIRequestLog(
        id: '4',
        timestamp: now.subtract(const Duration(minutes: 25)),
        userId: 'u4',
        userName: 'mike.wilson@EduVerse.edu',
        provider: AIProvider.gemini,
        model: AIModel.gemini15Pro,
        status: RequestStatus.failed,
        errorMessage: 'Connection timeout',
      ),
      AIRequestLog(
        id: '5',
        timestamp: now.subtract(const Duration(hours: 1)),
        userId: 'u5',
        userName: 'sarah.admin@EduVerse.edu',
        provider: AIProvider.openai,
        model: AIModel.gpt4,
        status: RequestStatus.success,
        tokensUsed: 2100,
        responseTime: 1800,
      ),
    ];
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
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

  void _handleProviderChanged(AIProvider provider) {
    setState(() {
      _selectedProvider = provider;
      // Reset model to first available for new provider
      switch (provider) {
        case AIProvider.openai:
          _selectedModel = AIModel.gpt4Turbo;
          break;
        case AIProvider.gemini:
          _selectedModel = AIModel.geminiPro;
          break;
        case AIProvider.claude:
          _selectedModel = AIModel.claude35Sonnet;
          break;
      }
    });
    _markAsChanged();
  }

  void _handleModelChanged(AIModel model) {
    setState(() => _selectedModel = model);
    _markAsChanged();
  }

  void _handleApiKeyChanged(String key) {
    setState(() => _apiKey = key);
    _markAsChanged();
  }

  void _handleAutoRotateChanged(bool value) {
    setState(() => _autoRotateEnabled = value);
    _markAsChanged();
    _showSnackBar('Auto-rotate ${value ? 'enabled' : 'disabled'}');
  }

  void _handleRegenerateKey() {
    // Generate mock new key
    setState(() {
      _apiKey = 'sk-proj-new${DateTime.now().millisecondsSinceEpoch}key';
    });
    _markAsChanged();
    _showSnackBar('API key regenerated successfully');
  }

  void _handleRulesChanged(GovernanceRules rules) {
    setState(() => _governanceRules = rules);
    _markAsChanged();
  }

  void _handleLimitsChanged(SystemLimits limits) {
    setState(() => _systemLimits = limits);
    _markAsChanged();
  }

  void _showSaveDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showSaveConfigDialog(
      context,
      isDark: isDark,
      onSave: _handleSaveConfig,
      onResetToDefault: _handleResetToDefault,
    );
  }

  void _handleSaveConfig() {
    setState(() => _hasUnsavedChanges = false);
    _showSnackBar('Configuration saved successfully');
  }

  void _handleResetToDefault() {
    setState(() {
      _selectedProvider = AIProvider.openai;
      _selectedModel = AIModel.gpt4Turbo;
      _autoRotateEnabled = true;
      _governanceRules = const GovernanceRules();
      _systemLimits = const SystemLimits();
      _hasUnsavedChanges = false;
    });
    _showSnackBar('Settings reset to default');
  }

  void _handleViewFullLogs() {
    _showLogsBottomSheet();
  }

  void _handleDownloadLogs() {
    _showSnackBar('Downloading logs...');
  }

  void _showLogsBottomSheet() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? ITColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ITColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      color: ITColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Request Logs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ITColors.textPrimaryColor(isDark),
                          ),
                        ),
                        Text(
                          'Complete history of AI requests and responses',
                          style: TextStyle(
                            fontSize: 12,
                            color: ITColors.textSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: ITColors.textSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            
            // Logs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return _buildLogItem(log, isDark);
                },
              ),
            ),
            
            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ITColors.darkCard : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Exporting logs...');
                      },
                      icon: const Icon(Icons.file_download_rounded, size: 18),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ITColors.primary,
                        side: BorderSide(color: ITColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ITColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(AIRequestLog log, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: log.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  log.status == RequestStatus.success
                      ? Icons.check_circle_rounded
                      : log.status == RequestStatus.failed
                          ? Icons.error_rounded
                          : Icons.pending_rounded,
                  size: 20,
                  color: log.statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.userName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ITColors.textPrimaryColor(isDark),
                      ),
                    ),
                    Text(
                      _formatFullTimestamp(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: log.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: log.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLogDetail('Provider', _getProviderName(log.provider), isDark),
              const SizedBox(width: 16),
              _buildLogDetail('Model', _getModelShortName(log.model), isDark),
              if (log.tokensUsed > 0) ...[
                const SizedBox(width: 16),
                _buildLogDetail('Tokens', log.tokensUsed.toString(), isDark),
              ],
            ],
          ),
          if (log.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ITColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: ITColors.error),
                  const SizedBox(width: 8),
                  Text(
                    log.errorMessage!,
                    style: TextStyle(fontSize: 12, color: ITColors.error),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogDetail(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: ITColors.textSecondaryColor(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ITColors.textPrimaryColor(isDark),
          ),
        ),
      ],
    );
  }

  String _getProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.gemini:
        return 'Gemini';
      case AIProvider.claude:
        return 'Claude';
    }
  }

  String _getModelShortName(AIModel model) {
    switch (model) {
      case AIModel.gpt4Turbo:
        return 'GPT-4.1';
      case AIModel.gpt4:
        return 'GPT-4';
      case AIModel.gpt35Turbo:
        return 'GPT-3.5';
      case AIModel.geminiPro:
        return 'Gemini';
      case AIModel.gemini15Pro:
        return 'Gemini 1.5';
      case AIModel.claude3Opus:
        return 'Claude Opus';
      case AIModel.claude3Sonnet:
        return 'Claude 3';
      case AIModel.claude35Sonnet:
        return 'Claude 3.5';
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
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
          drawer: ITDrawer(currentRoute: '/it-admin/ai-settings', isDark: isDark),
          floatingActionButton: _hasUnsavedChanges
              ? FloatingActionButton.extended(
                  onPressed: _showSaveDialog,
                  backgroundColor: ITColors.primary,
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              : null,
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEFF6FF),
                          Colors.white,
                          Color(0xFFF3E8FF),
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
          ITAIModelSettingsAppBar(
            isDark: isDark,
            title: l10n.itAiModelSettings,
            subtitle: l10n.itAiModelSettingsSubtitle,
            onSaveTap: _hasUnsavedChanges ? _showSaveDialog : null,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // AI Providers Section
                ITAIProvidersSection(
                  isDark: isDark,
                  selectedProvider: _selectedProvider,
                  selectedModel: _selectedModel,
                  onProviderChanged: _handleProviderChanged,
                  onModelChanged: _handleModelChanged,
                ),
                const SizedBox(height: 20),
                
                // API Keys Section
                ITAPIKeysSection(
                  isDark: isDark,
                  apiKey: _apiKey,
                  autoRotateEnabled: _autoRotateEnabled,
                  onApiKeyChanged: _handleApiKeyChanged,
                  onAutoRotateChanged: _handleAutoRotateChanged,
                  onRegenerateKey: _handleRegenerateKey,
                ),
                const SizedBox(height: 20),
                
                // Governance Rules Section
                ITGovernanceRulesSection(
                  isDark: isDark,
                  rules: _governanceRules,
                  onRulesChanged: _handleRulesChanged,
                ),
                const SizedBox(height: 20),
                
                // System Limits Section
                ITSystemLimitsSection(
                  isDark: isDark,
                  limits: _systemLimits,
                  onLimitsChanged: _handleLimitsChanged,
                ),
                const SizedBox(height: 20),
                
                // AI Request Logs Section
                ITAIRequestLogsSection(
                  isDark: isDark,
                  stats: _stats,
                  logs: _logs,
                  onViewFullLogs: _handleViewFullLogs,
                  onDownloadLogs: _handleDownloadLogs,
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
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
