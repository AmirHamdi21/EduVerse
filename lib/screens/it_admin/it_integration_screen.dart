import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/integration/it_integration_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITIntegrationScreen extends StatefulWidget {
  const ITIntegrationScreen({super.key});

  @override
  State<ITIntegrationScreen> createState() => _ITIntegrationScreenState();
}

class _ITIntegrationScreenState extends State<ITIntegrationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IntegrationCategory _selectedCategory = IntegrationCategory.all;
  String _searchQuery = '';
  List<IntegrationProvider> _integrations = [];

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

      _integrations = _getMockIntegrations();

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

  List<IntegrationProvider> _getMockIntegrations() {
    return [
      // LMS Integrations
      IntegrationProvider(
        id: '1',
        name: 'Canvas LMS',
        description:
            'Learning management system integration for course management and student tracking',
        category: 'LMS',
        status: IntegrationStatus.connected,
        icon: Icons.school_rounded,
        iconColor: const Color(0xFFE74C3C),
        iconBgColor: const Color(0xFFE74C3C).withValues(alpha: 0.1),
        lastSync: '5 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 15420,
        requestLimit: 50000,
        uptime: 99.9,
        errorRate: 0.12,
        version: '2.4.1',
        isPopular: true,
        features: [
          'Course Sync',
          'Grade Export',
          'User Provisioning',
          'Assignment Sync',
        ],
        connectionSettings: ConnectionSettings(
          apiEndpoint: 'https://canvas.example.edu/api/v1',
          autoSync: true,
          syncInterval: 15,
          rateLimitPerMinute: 100,
          timeout: 30,
        ),
        performanceMetrics: PerformanceMetrics(
          totalRequests: 15420,
          successfulRequests: 15401,
          failedRequests: 19,
          averageResponseTime: 145,
          uptimePercentage: 99.9,
        ),
      ),
      IntegrationProvider(
        id: '2',
        name: 'Moodle',
        description:
            'Open-source learning platform integration for virtual classrooms',
        category: 'LMS',
        status: IntegrationStatus.connected,
        icon: Icons.menu_book_rounded,
        iconColor: const Color(0xFFF68C1F),
        iconBgColor: const Color(0xFFF68C1F).withValues(alpha: 0.1),
        lastSync: '10 min ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 8750,
        requestLimit: 30000,
        uptime: 99.7,
        errorRate: 0.23,
        version: '4.1.0',
        features: ['Course Import', 'Quiz Sync', 'Gradebook'],
      ),
      // AI Integrations
      IntegrationProvider(
        id: '3',
        name: 'OpenAI GPT',
        description:
            'AI-powered learning assistant for personalized tutoring and content generation',
        category: 'AI',
        status: IntegrationStatus.connected,
        icon: Icons.psychology_rounded,
        iconColor: const Color(0xFF10A37F),
        iconBgColor: const Color(0xFF10A37F).withValues(alpha: 0.1),
        lastSync: '2 min ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 45230,
        requestLimit: 100000,
        uptime: 99.95,
        errorRate: 0.05,
        version: '4.0',
        isPopular: true,
        features: ['Content Generation', 'Tutoring', 'Essay Grading', 'Q&A'],
        connectionSettings: ConnectionSettings(
          apiEndpoint: 'https://api.openai.com/v1',
          autoSync: false,
          rateLimitPerMinute: 60,
          timeout: 60,
        ),
        performanceMetrics: PerformanceMetrics(
          totalRequests: 45230,
          successfulRequests: 45207,
          failedRequests: 23,
          averageResponseTime: 2100,
          uptimePercentage: 99.95,
        ),
      ),
      IntegrationProvider(
        id: '4',
        name: 'Google Gemini',
        description: 'Advanced AI model for multimodal learning experiences',
        category: 'AI',
        status: IntegrationStatus.connected,
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFF4285F4),
        iconBgColor: const Color(0xFF4285F4).withValues(alpha: 0.1),
        lastSync: '8 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 12800,
        requestLimit: 50000,
        uptime: 99.8,
        errorRate: 0.15,
        version: '1.5',
        isPopular: true,
        features: ['Multimodal', 'Code Generation', 'Image Analysis'],
      ),
      // Storage Integrations
      IntegrationProvider(
        id: '5',
        name: 'AWS S3 Storage',
        description:
            'Cloud storage for course materials, assignments, and media files',
        category: 'Storage',
        status: IntegrationStatus.connected,
        icon: Icons.cloud_rounded,
        iconColor: const Color(0xFFFF9900),
        iconBgColor: const Color(0xFFFF9900).withValues(alpha: 0.1),
        lastSync: '1 min ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 89420,
        requestLimit: 500000,
        uptime: 99.99,
        errorRate: 0.01,
        version: '2.0',
        features: ['File Storage', 'CDN', 'Backup', 'Versioning'],
        connectionSettings: ConnectionSettings(
          apiEndpoint: 'https://s3.amazonaws.com',
          autoSync: true,
          syncInterval: 5,
          rateLimitPerMinute: 500,
          timeout: 30,
        ),
        performanceMetrics: PerformanceMetrics(
          totalRequests: 89420,
          successfulRequests: 89411,
          failedRequests: 9,
          averageResponseTime: 85,
          uptimePercentage: 99.99,
        ),
      ),
      IntegrationProvider(
        id: '6',
        name: 'Google Cloud Storage',
        description: 'Enterprise-grade cloud storage with global availability',
        category: 'Storage',
        status: IntegrationStatus.connected,
        icon: Icons.cloud_queue_rounded,
        iconColor: const Color(0xFF4285F4),
        iconBgColor: const Color(0xFF4285F4).withValues(alpha: 0.1),
        lastSync: '3 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 34560,
        requestLimit: 200000,
        uptime: 99.95,
        errorRate: 0.08,
        version: '1.0',
        features: ['Object Storage', 'CDN', 'Analytics'],
      ),
      IntegrationProvider(
        id: '7',
        name: 'Azure Blob Storage',
        description: 'Microsoft Azure cloud storage for education workloads',
        category: 'Storage',
        status: IntegrationStatus.disconnected,
        icon: Icons.dns_rounded,
        iconColor: const Color(0xFF0078D4),
        iconBgColor: const Color(0xFF0078D4).withValues(alpha: 0.1),
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        version: '12.0',
        features: ['Blob Storage', 'Archive', 'Lifecycle Management'],
      ),
      // Productivity Integrations
      IntegrationProvider(
        id: '8',
        name: 'Microsoft 365',
        description:
            'Office suite integration for documents, spreadsheets, and collaboration',
        category: 'Productivity',
        status: IntegrationStatus.connected,
        icon: Icons.grid_view_rounded,
        iconColor: const Color(0xFF0078D4),
        iconBgColor: const Color(0xFF0078D4).withValues(alpha: 0.1),
        lastSync: '15 min ago',
        apiType: 'Graph API',
        hasOAuth: true,
        hasApiKey: false,
        requestCount: 28900,
        requestLimit: 100000,
        uptime: 99.85,
        errorRate: 0.18,
        version: '1.0',
        isPopular: true,
        features: ['OneDrive', 'Teams', 'Outlook', 'SharePoint'],
      ),
      IntegrationProvider(
        id: '9',
        name: 'Google Workspace',
        description:
            'Google productivity suite for education with Drive, Docs, and Meet',
        category: 'Productivity',
        status: IntegrationStatus.connected,
        icon: Icons.work_rounded,
        iconColor: const Color(0xFF34A853),
        iconBgColor: const Color(0xFF34A853).withValues(alpha: 0.1),
        lastSync: '7 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 42100,
        requestLimit: 150000,
        uptime: 99.9,
        errorRate: 0.1,
        version: '2.0',
        isPopular: true,
        features: ['Drive', 'Docs', 'Meet', 'Calendar', 'Classroom'],
      ),
      IntegrationProvider(
        id: '10',
        name: 'Notion',
        description:
            'All-in-one workspace for notes, docs, and project management',
        category: 'Productivity',
        status: IntegrationStatus.disconnected,
        icon: Icons.note_alt_rounded,
        iconColor: Colors.black,
        iconBgColor: Colors.black.withValues(alpha: 0.1),
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        version: '1.0',
        features: ['Notes', 'Databases', 'Wiki', 'Projects'],
      ),
      // Communication Integrations
      IntegrationProvider(
        id: '11',
        name: 'Slack',
        description:
            'Team communication platform for instant messaging and collaboration',
        category: 'Communication',
        status: IntegrationStatus.connected,
        icon: Icons.tag_rounded,
        iconColor: const Color(0xFF611F69),
        iconBgColor: const Color(0xFF611F69).withValues(alpha: 0.1),
        lastSync: '2 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 18600,
        requestLimit: 50000,
        uptime: 99.8,
        errorRate: 0.15,
        version: '2.0',
        features: ['Messaging', 'Notifications', 'Channels', 'Bots'],
      ),
      IntegrationProvider(
        id: '12',
        name: 'Zoom',
        description: 'Video conferencing for virtual classes and meetings',
        category: 'Communication',
        status: IntegrationStatus.connected,
        icon: Icons.videocam_rounded,
        iconColor: const Color(0xFF2D8CFF),
        iconBgColor: const Color(0xFF2D8CFF).withValues(alpha: 0.1),
        lastSync: '5 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 9800,
        requestLimit: 30000,
        uptime: 99.7,
        errorRate: 0.2,
        version: '2.0',
        isPopular: true,
        features: ['Video Calls', 'Webinars', 'Recordings', 'Breakout Rooms'],
      ),
      IntegrationProvider(
        id: '13',
        name: 'Discord',
        description:
            'Community platform for student engagement and study groups',
        category: 'Communication',
        status: IntegrationStatus.disconnected,
        icon: Icons.headset_mic_rounded,
        iconColor: const Color(0xFF5865F2),
        iconBgColor: const Color(0xFF5865F2).withValues(alpha: 0.1),
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        version: '10.0',
        features: ['Voice Channels', 'Text Chat', 'Bots', 'Roles'],
      ),
      // Analytics Integrations
      IntegrationProvider(
        id: '14',
        name: 'Google Analytics',
        description: 'Learning analytics and user behavior tracking',
        category: 'Analytics',
        status: IntegrationStatus.connected,
        icon: Icons.analytics_rounded,
        iconColor: const Color(0xFFE37400),
        iconBgColor: const Color(0xFFE37400).withValues(alpha: 0.1),
        lastSync: '10 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 125000,
        requestLimit: 500000,
        uptime: 99.9,
        errorRate: 0.08,
        version: '4.0',
        features: ['User Tracking', 'Events', 'Reports', 'Dashboards'],
      ),
      IntegrationProvider(
        id: '15',
        name: 'Mixpanel',
        description: 'Product analytics for learning engagement metrics',
        category: 'Analytics',
        status: IntegrationStatus.disconnected,
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFF7856FF),
        iconBgColor: const Color(0xFF7856FF).withValues(alpha: 0.1),
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        version: '2.0',
        features: ['Funnels', 'Retention', 'Cohorts', 'A/B Testing'],
      ),
      // Security Integrations
      IntegrationProvider(
        id: '16',
        name: 'Okta SSO',
        description: 'Single sign-on and identity management for secure access',
        category: 'Security',
        status: IntegrationStatus.connected,
        icon: Icons.security_rounded,
        iconColor: const Color(0xFF007DC1),
        iconBgColor: const Color(0xFF007DC1).withValues(alpha: 0.1),
        lastSync: '1 min ago',
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        requestCount: 56000,
        requestLimit: 200000,
        uptime: 99.99,
        errorRate: 0.02,
        version: '2.0',
        isPopular: true,
        features: ['SSO', 'MFA', 'Directory', 'Lifecycle Management'],
        connectionSettings: ConnectionSettings(
          apiEndpoint: 'https://dev-12345.okta.com/api/v1',
          autoSync: true,
          syncInterval: 5,
          rateLimitPerMinute: 200,
          timeout: 15,
        ),
        performanceMetrics: PerformanceMetrics(
          totalRequests: 56000,
          successfulRequests: 55989,
          failedRequests: 11,
          averageResponseTime: 120,
          uptimePercentage: 99.99,
        ),
      ),
      IntegrationProvider(
        id: '17',
        name: 'Auth0',
        description: 'Flexible authentication and authorization platform',
        category: 'Security',
        status: IntegrationStatus.disconnected,
        icon: Icons.lock_rounded,
        iconColor: const Color(0xFFEB5424),
        iconBgColor: const Color(0xFFEB5424).withValues(alpha: 0.1),
        apiType: 'REST API',
        hasOAuth: true,
        hasApiKey: true,
        version: '2.0',
        features: ['Universal Login', 'MFA', 'Social Login', 'Passwordless'],
      ),
      IntegrationProvider(
        id: '18',
        name: 'Cloudflare DNS',
        description: 'DNS and security services for application protection',
        category: 'Security',
        status: IntegrationStatus.connected,
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFFF38020),
        iconBgColor: const Color(0xFFF38020).withValues(alpha: 0.1),
        lastSync: '30 sec ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 890000,
        requestLimit: 5000000,
        uptime: 99.999,
        errorRate: 0.001,
        version: '4.0',
        features: ['DNS', 'WAF', 'DDoS Protection', 'CDN'],
      ),
      IntegrationProvider(
        id: '19',
        name: 'Stripe Payments',
        description:
            'Payment processing for course purchases and subscriptions',
        category: 'Productivity',
        status: IntegrationStatus.connected,
        icon: Icons.payment_rounded,
        iconColor: const Color(0xFF635BFF),
        iconBgColor: const Color(0xFF635BFF).withValues(alpha: 0.1),
        lastSync: '1 min ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 4520,
        requestLimit: 25000,
        uptime: 99.99,
        errorRate: 0.03,
        version: '2024-01',
        features: ['Payments', 'Subscriptions', 'Invoices', 'Refunds'],
      ),
      IntegrationProvider(
        id: '20',
        name: 'Turnitin',
        description: 'Academic integrity and plagiarism detection service',
        category: 'LMS',
        status: IntegrationStatus.connected,
        icon: Icons.fact_check_rounded,
        iconColor: const Color(0xFF00539B),
        iconBgColor: const Color(0xFF00539B).withValues(alpha: 0.1),
        lastSync: '20 min ago',
        apiType: 'REST API',
        hasOAuth: false,
        hasApiKey: true,
        requestCount: 2340,
        requestLimit: 10000,
        uptime: 99.5,
        errorRate: 0.35,
        version: '2.0',
        features: ['Plagiarism Check', 'Similarity Report', 'Grading'],
      ),
    ];
  }

  List<IntegrationProvider> get _filteredIntegrations {
    List<IntegrationProvider> filtered = _integrations;

    // Filter by category
    if (_selectedCategory != IntegrationCategory.all) {
      filtered = filtered.where((i) {
        final category = i.category.toLowerCase();
        switch (_selectedCategory) {
          case IntegrationCategory.lms:
            return category == 'lms';
          case IntegrationCategory.ai:
            return category == 'ai';
          case IntegrationCategory.storage:
            return category == 'storage';
          case IntegrationCategory.productivity:
            return category == 'productivity';
          case IntegrationCategory.communication:
            return category == 'communication';
          case IntegrationCategory.analytics:
            return category == 'analytics';
          case IntegrationCategory.security:
            return category == 'security';
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.name.toLowerCase().contains(query) ||
            i.description.toLowerCase().contains(query) ||
            i.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  int get _connectedCount => _integrations
      .where((i) => i.status == IntegrationStatus.connected)
      .length;

  int get _totalApiCalls =>
      _integrations.fold(0, (sum, i) => sum + (i.requestCount ?? 0));

  double get _overallUptime {
    final connected = _integrations.where((i) => i.uptime != null).toList();
    if (connected.isEmpty) return 0;
    return connected.fold(0.0, (sum, i) => sum + i.uptime!) / connected.length;
  }

  void _handleCategoryChange(IntegrationCategory category) {
    setState(() => _selectedCategory = category);
  }

  void _handleSearchChange(String query) {
    setState(() => _searchQuery = query);
  }

  void _clearSearch() {
    setState(() => _searchQuery = '');
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

  void _showIntegrationDetail(IntegrationProvider integration) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ITIntegrationDetailSheet(
          isDark: isDark,
          integration: integration,
          onConfigure: () => _showConfigDialog(integration),
          onSync: () => _handleSync(integration),
          onDisconnect: () => _handleDisconnect(integration),
          onConnect: () => _handleConnect(integration),
          onViewLogs: () =>
              _showSnackBar('Opening logs for ${integration.name}...'),
          onViewDocs: () =>
              _showSnackBar('Opening documentation for ${integration.name}...'),
        ),
      ),
    );
  }

  void _showConfigDialog(IntegrationProvider integration) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      builder: (context) => ITIntegrationConfigDialog(
        isDark: isDark,
        integration: integration,
        onSave: (settings) {
          setState(() {
            final index = _integrations.indexWhere(
              (i) => i.id == integration.id,
            );
            if (index != -1) {
              _integrations[index] = integration.copyWith(
                connectionSettings: settings,
              );
            }
          });
          _showSnackBar('Configuration saved for ${integration.name}');
        },
      ),
    );
  }

  void _handleSync(IntegrationProvider integration) {
    setState(() {
      final index = _integrations.indexWhere((i) => i.id == integration.id);
      if (index != -1) {
        _integrations[index] = integration.copyWith(lastSync: 'Just now');
      }
    });
    _showSnackBar('Syncing ${integration.name}...');
  }

  void _handleConnect(IntegrationProvider integration) {
    setState(() {
      final index = _integrations.indexWhere((i) => i.id == integration.id);
      if (index != -1) {
        _integrations[index] = integration.copyWith(
          status: IntegrationStatus.connected,
          lastSync: 'Just now',
        );
      }
    });
    _showSnackBar('${integration.name} connected successfully!');
  }

  void _handleDisconnect(IntegrationProvider integration) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ITColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ITColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.power_off_rounded,
                color: ITColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Disconnect ${integration.name}?',
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will remove the connection and stop all data synchronization. You can reconnect at any time.',
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ITColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _integrations.indexWhere(
                  (i) => i.id == integration.id,
                );
                if (index != -1) {
                  _integrations[index] = integration.copyWith(
                    status: IntegrationStatus.disconnected,
                    lastSync: null,
                  );
                }
              });
              _showSnackBar('${integration.name} disconnected');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ITColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _handleAddIntegration() {
    _showSnackBar('Add new integration feature');
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
          drawer: ITDrawer(
            currentRoute: '/it-admin/integrations',
            isDark: isDark,
          ),
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
                          Color(0xFFECFEFF),
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
      return Center(child: CircularProgressIndicator(color: ITColors.primary));
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ITColors.primary,
      child: CustomScrollView(
        slivers: [
          ITIntegrationAppBar(
            isDark: isDark,
            title: l10n.itIntegrations,
            subtitle: l10n.itManageExternalServices,
            connectedCount: _connectedCount,
            totalCount: _integrations.length,
            onRefreshTap: _loadData,
            onSearchTap: () {},
            onFilterTap: () {},
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats card
                ITIntegrationStatsCard(
                  isDark: isDark,
                  totalIntegrations: _integrations.length,
                  connectedCount: _connectedCount,
                  activeApiCalls: _totalApiCalls,
                  overallUptime: _overallUptime,
                  onAddIntegration: _handleAddIntegration,
                ),
                // Filter section
                ITIntegrationFilterSection(
                  isDark: isDark,
                  selectedCategory: _selectedCategory,
                  searchQuery: _searchQuery,
                  onCategoryChanged: _handleCategoryChange,
                  onSearchChanged: _handleSearchChange,
                  onClearSearch: _clearSearch,
                ),
                const SizedBox(height: 20),
                // Integration list
                ITIntegrationListSection(
                  isDark: isDark,
                  integrations: _filteredIntegrations,
                  sectionTitle: _getSectionTitle(),
                  sectionSubtitle: _getSectionSubtitle(),
                  onIntegrationTap: _showIntegrationDetail,
                  onConfigure: _showConfigDialog,
                  onSync: _handleSync,
                  onToggleConnection: _handleConnect,
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getSectionTitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Search Results';
    }
    switch (_selectedCategory) {
      case IntegrationCategory.all:
        return 'All Integrations';
      case IntegrationCategory.lms:
        return 'LMS Integrations';
      case IntegrationCategory.ai:
        return 'AI Integrations';
      case IntegrationCategory.storage:
        return 'Storage Integrations';
      case IntegrationCategory.productivity:
        return 'Productivity Tools';
      case IntegrationCategory.communication:
        return 'Communication Tools';
      case IntegrationCategory.analytics:
        return 'Analytics Tools';
      case IntegrationCategory.security:
        return 'Security & Identity';
    }
  }

  String _getSectionSubtitle() {
    if (_searchQuery.isNotEmpty) {
      return 'Found ${_filteredIntegrations.length} results for "$_searchQuery"';
    }
    return '${_filteredIntegrations.where((i) => i.status == IntegrationStatus.connected).length} connected of ${_filteredIntegrations.length}';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
