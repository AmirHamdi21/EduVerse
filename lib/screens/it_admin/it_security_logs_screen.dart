import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/it_admin/security_logs/it_security_logs_barrel.dart';
import '../../widgets/it_admin/shared/it_colors.dart';
import '../../widgets/it_admin/shared/it_drawer.dart';

class ITSecurityLogsScreen extends StatefulWidget {
  const ITSecurityLogsScreen({super.key});

  @override
  State<ITSecurityLogsScreen> createState() => _ITSecurityLogsScreenState();
}

class _ITSecurityLogsScreenState extends State<ITSecurityLogsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Tab state
  int _selectedMainTab = 0;
  int _selectedSubTab = 0;

  // Filters
  String _searchQuery = '';
  String _selectedFilter = 'All Events';
  bool _showFlaggedOnly = false;
  bool _showHighRiskOnly = false;

  // Data
  List<SecurityLogEntry> _logs = [];
  List<SecurityIncident> _incidents = [];
  List<AccessRequest> _accessRequests = [];
  List<UserRole> _roles = [];
  List<SecurityPolicy> _policies = [];
  List<AISecurityInsight> _aiInsights = [];
  List<RecentSecurityAction> _recentActions = [];
  late SecurityStats _stats;

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
      _incidents = _getMockIncidents();
      _accessRequests = _getMockAccessRequests();
      _roles = _getMockRoles();
      _policies = _getMockPolicies();
      _aiInsights = _getMockAIInsights();
      _recentActions = _getMockRecentActions();
      _stats = _getMockStats();

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

  List<SecurityLogEntry> _getMockLogs() {
    final now = DateTime.now();
    return [
      SecurityLogEntry(
        id: '1',
        timestamp: now.subtract(const Duration(minutes: 5)),
        userId: 'u1',
        userName: 'john.doe@EduVerse.edu',
        userEmail: 'john.doe@EduVerse.edu',
        eventType: LogEventType.loginSuccess,
        ipAddress: '192.168.1.45',
        location: 'Los Angeles, US',
        device: 'Chrome on Windows',
        riskLevel: RiskLevel.low,
      ),
      SecurityLogEntry(
        id: '2',
        timestamp: now.subtract(const Duration(minutes: 12)),
        userId: 'u2',
        userName: 'attacker@malicious.com',
        userEmail: 'attacker@malicious.com',
        eventType: LogEventType.breachAttempt,
        ipAddress: '45.142.212.81',
        location: 'Unknown',
        device: 'Unknown',
        riskLevel: RiskLevel.critical,
        isFlagged: true,
      ),
      SecurityLogEntry(
        id: '3',
        timestamp: now.subtract(const Duration(minutes: 30)),
        userId: 'u3',
        userName: 'kate.smith@EduVerse.edu',
        userEmail: 'kate.smith@EduVerse.edu',
        eventType: LogEventType.permissionChange,
        ipAddress: '192.168.1.102',
        location: 'Los Angeles, US',
        device: 'Safari on macOS',
        riskLevel: RiskLevel.medium,
      ),
      SecurityLogEntry(
        id: '4',
        timestamp: now.subtract(const Duration(hours: 1)),
        userId: 'u4',
        userName: 'api_service_01',
        userEmail: 'service@EduVerse.edu',
        eventType: LogEventType.apiAccess,
        ipAddress: '10.0.0.63',
        device: 'API Client',
        riskLevel: RiskLevel.low,
      ),
      SecurityLogEntry(
        id: '5',
        timestamp: now.subtract(const Duration(hours: 2)),
        userId: 'u5',
        userName: 'suspicious@unknown.com',
        userEmail: 'suspicious@unknown.com',
        eventType: LogEventType.loginFailed,
        ipAddress: '45.142.212.81',
        location: 'Unknown',
        device: 'Unknown',
        riskLevel: RiskLevel.high,
        isFlagged: true,
      ),
      SecurityLogEntry(
        id: '6',
        timestamp: now.subtract(const Duration(hours: 3)),
        userId: 'u6',
        userName: 'mike.wilson@EduVerse.edu',
        userEmail: 'mike.wilson@EduVerse.edu',
        eventType: LogEventType.logout,
        ipAddress: '192.168.1.87',
        location: 'Los Angeles, US',
        device: 'Mobile Safari',
        riskLevel: RiskLevel.low,
      ),
      SecurityLogEntry(
        id: '7',
        timestamp: now.subtract(const Duration(hours: 4)),
        userId: 'u7',
        userName: 'sarah.admin@EduVerse.edu',
        userEmail: 'sarah.admin@EduVerse.edu',
        eventType: LogEventType.mfaEnabled,
        ipAddress: '192.168.1.15',
        location: 'Los Angeles, US',
        device: 'Chrome on Windows',
        riskLevel: RiskLevel.low,
      ),
      SecurityLogEntry(
        id: '8',
        timestamp: now.subtract(const Duration(hours: 5)),
        userId: 'u8',
        userName: 'Unknown',
        userEmail: 'unknown@test.com',
        eventType: LogEventType.loginFailed,
        ipAddress: '185.220.101.45',
        location: 'Tor Exit Node',
        device: 'Unknown',
        riskLevel: RiskLevel.critical,
        isFlagged: true,
      ),
    ];
  }

  List<SecurityIncident> _getMockIncidents() {
    final now = DateTime.now();
    return [
      SecurityIncident(
        id: 'inc1',
        title: 'Brute Force Attack Detected',
        description:
            'Multiple failed login attempts from IP 45.142.212.81 targeting admin accounts.',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.active,
        detectedAt: now.subtract(const Duration(hours: 2)),
        affectedAccounts: 5,
        relatedIps: ['45.142.212.81', '45.142.212.82'],
      ),
      SecurityIncident(
        id: 'inc2',
        title: 'Unusual Access Pattern',
        description:
            'System detected logins from 3 different locations for user accounts within 5 minutes.',
        severity: IncidentSeverity.warning,
        status: IncidentStatus.investigating,
        detectedAt: now.subtract(const Duration(hours: 4)),
        affectedAccounts: 3,
      ),
      SecurityIncident(
        id: 'inc3',
        title: 'API Rate Limit Exceeded',
        description:
            'Service account exceeded 1000 requests per minute threshold.',
        severity: IncidentSeverity.info,
        status: IncidentStatus.active,
        detectedAt: now.subtract(const Duration(hours: 6)),
        affectedAccounts: 1,
      ),
    ];
  }

  List<AccessRequest> _getMockAccessRequests() {
    final now = DateTime.now();
    return [
      AccessRequest(
        id: 'req1',
        userId: 'u10',
        userName: 'emily.chen@EduVerse.edu',
        userEmail: 'emily.chen@EduVerse.edu',
        currentRole: 'Student',
        requestedRole: 'Teaching Assistant',
        reason: 'Assisting Prof. Johnson with CS201 grading',
        requestedAt: now.subtract(const Duration(hours: 2)),
      ),
      AccessRequest(
        id: 'req2',
        userId: 'u11',
        userName: 'michael.brown@EduVerse.edu',
        userEmail: 'michael.brown@EduVerse.edu',
        currentRole: 'Teaching Assistant',
        requestedRole: 'Instructor',
        reason: 'Promoted to lead instructor for Spring 2024',
        requestedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<UserRole> _getMockRoles() {
    return [
      UserRole(
        id: 'student',
        name: 'Student',
        description: 'Basic learning access',
        icon: Icons.school_rounded,
        color: ITColors.primary,
        userCount: 15420,
        permissions: ['View courses', 'Submit assignments', 'View grades'],
      ),
      UserRole(
        id: 'instructor',
        name: 'Instructor',
        description: 'Teaching and grading capabilities',
        icon: Icons.cast_for_education_rounded,
        color: ITColors.teal,
        userCount: 342,
        permissions: ['Create courses', 'Grade assignments', 'Manage students'],
      ),
      UserRole(
        id: 'admin',
        name: 'Admin',
        description: 'System administration',
        icon: Icons.admin_panel_settings_rounded,
        color: ITColors.purple,
        userCount: 12,
        permissions: ['Full system access', 'User management', 'Configuration'],
      ),
      UserRole(
        id: 'it',
        name: 'IT',
        description: 'Technical support and security',
        icon: Icons.engineering_rounded,
        color: ITColors.orange,
        userCount: 8,
        permissions: [
          'Security logs',
          'System monitoring',
          'Backup management',
        ],
      ),
    ];
  }

  List<SecurityPolicy> _getMockPolicies() {
    return [
      SecurityPolicy(
        id: 'mfa',
        name: 'Mandatory MFA',
        description: 'Require multi-factor authentication for all roles',
        isEnabled: true,
      ),
      SecurityPolicy(
        id: 'password',
        name: 'Password Strength',
        description:
            'Minimum 12 characters, mixed case, numbers, symbols required',
        value: 'Strong',
        isEnabled: true,
      ),
      SecurityPolicy(
        id: 'session',
        name: 'Session Timeout',
        description: 'Auto-logout after period of inactivity',
        value: '30 minutes',
        isEnabled: true,
      ),
      SecurityPolicy(
        id: 'ipBlocklist',
        name: 'IP Blocklist',
        description: 'Block access from automatically banned IPs',
        value: '15 blocked IPs',
        configureAction: 'Configure',
      ),
      SecurityPolicy(
        id: 'rateLimit',
        name: 'API Rate Limiting',
        description: '1000 requests per minute per user',
        value: '1000 req/min',
        configureAction: 'Configure',
      ),
    ];
  }

  List<AISecurityInsight> _getMockAIInsights() {
    return [
      AISecurityInsight(
        id: 'ai1',
        title: 'Coordinated Attack Pattern',
        description: 'Multiple IPs from same region targeting admin accounts.',
        severity: IncidentSeverity.warning,
        icon: Icons.group_work_rounded,
      ),
      AISecurityInsight(
        id: 'ai2',
        title: 'Unusual Login Times',
        description: '12 accounts logged in between 2-4 AM unusually.',
        severity: IncidentSeverity.info,
        icon: Icons.schedule_rounded,
      ),
      AISecurityInsight(
        id: 'ai3',
        title: 'Recommendation',
        description:
            'Enable geo-blocking to block non-US logins for admin roles.',
        severity: IncidentSeverity.info,
        icon: Icons.tips_and_updates_rounded,
      ),
    ];
  }

  List<RecentSecurityAction> _getMockRecentActions() {
    final now = DateTime.now();
    return [
      RecentSecurityAction(
        id: 'act1',
        title: 'IP 45.142.212.81 blocked',
        subtitle: 'by System Auto',
        timestamp: now.subtract(const Duration(minutes: 10)),
      ),
      RecentSecurityAction(
        id: 'act2',
        title: 'MFA enforced for Admin role',
        subtitle: 'by s.admin@EduVerse.edu',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      RecentSecurityAction(
        id: 'act3',
        title: 'Student role permissions updated',
        subtitle: 'by admin@EduVerse.edu',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  SecurityStats _getMockStats() {
    return SecurityStats(
      authEvents24h: 1248,
      authEventsTrend: 12,
      failedLogins24h: 1,
      failedLoginsNote: 'Spike from IP 45.142...',
      breachAttempts: 2,
      activeIncidents: 2,
      privilegeChanges7d: 2,
      authorizedChanges: 2,
    );
  }

  List<SecurityLogEntry> get _filteredLogs {
    List<SecurityLogEntry> filtered = _logs;

    // Filter by flagged
    if (_showFlaggedOnly) {
      filtered = filtered.where((log) => log.isFlagged).toList();
    }

    // Filter by high risk
    if (_showHighRiskOnly) {
      filtered = filtered
          .where(
            (log) =>
                log.riskLevel == RiskLevel.high ||
                log.riskLevel == RiskLevel.critical,
          )
          .toList();
    }

    // Filter by event type
    if (_selectedFilter != 'All Events') {
      filtered = filtered.where((log) {
        switch (_selectedFilter) {
          case 'Login':
            return log.eventType == LogEventType.loginSuccess ||
                log.eventType == LogEventType.loginFailed;
          case 'Logout':
            return log.eventType == LogEventType.logout;
          case 'Breach':
            return log.eventType == LogEventType.breachAttempt;
          case 'Permission':
            return log.eventType == LogEventType.permissionChange;
          case 'API':
            return log.eventType == LogEventType.apiAccess;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (log) =>
                log.userName.toLowerCase().contains(query) ||
                log.userEmail.toLowerCase().contains(query) ||
                log.ipAddress.toLowerCase().contains(query) ||
                (log.location?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  List<AccessRequest> get _pendingRequests => _accessRequests
      .where((r) => r.status == AccessRequestStatus.pending)
      .toList();

  List<SecurityIncident> get _activeIncidents => _incidents
      .where(
        (i) =>
            i.status != IncidentStatus.dismissed &&
            i.status != IncidentStatus.resolved,
      )
      .toList();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleApproveRequest(AccessRequest request) {
    setState(() {
      final index = _accessRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _accessRequests[index] = request.copyWith(
          status: AccessRequestStatus.approved,
        );
      }
    });
    _showSnackBar('Approved access request for ${request.userName}');
  }

  void _handleDenyRequest(AccessRequest request) {
    setState(() {
      final index = _accessRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _accessRequests[index] = request.copyWith(
          status: AccessRequestStatus.denied,
        );
      }
    });
    _showSnackBar('Denied access request for ${request.userName}');
  }

  void _handleTogglePolicy(SecurityPolicy policy, bool value) {
    setState(() {
      final index = _policies.indexWhere((p) => p.id == policy.id);
      if (index != -1) {
        _policies[index] = policy.copyWith(isEnabled: value);
      }
    });
    _showSnackBar('${policy.name} ${value ? 'enabled' : 'disabled'}');
  }

  void _handleConfigurePolicy(SecurityPolicy policy) {
    _showSnackBar('Configure ${policy.name}');
  }

  void _handleHideIncident(SecurityIncident incident) {
    setState(() {
      final index = _incidents.indexWhere((i) => i.id == incident.id);
      if (index != -1) {
        _incidents[index] = incident.copyWith(status: IncidentStatus.dismissed);
      }
    });
    _showSnackBar('Incident hidden');
  }

  void _showIncidentDetails(SecurityIncident incident) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ITIncidentDetailSheet(
        isDark: isDark,
        incident: incident,
        onBlockIps: () {
          Navigator.pop(context);
          _showSnackBar('Blocked ${incident.relatedIps.length} related IPs');
        },
        onMarkResolved: () {
          Navigator.pop(context);
          setState(() {
            final index = _incidents.indexWhere((i) => i.id == incident.id);
            if (index != -1) {
              _incidents[index] = incident.copyWith(
                status: IncidentStatus.resolved,
              );
            }
          });
          _showSnackBar('Incident marked as resolved');
        },
        onCreateReport: () {
          Navigator.pop(context);
          _showSnackBar('Creating incident report...');
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _handleLogTap(SecurityLogEntry log) {
    _showSnackBar('Viewing details for ${log.userName}');
  }

  void _handleViewPermissions(UserRole role) {
    _showSnackBar('Viewing permissions for ${role.name}');
  }

  void _handleViewUsers(UserRole role) {
    _showSnackBar('Viewing ${role.userCount} users with ${role.name} role');
  }

  void _handleAIInsightTap(AISecurityInsight insight) {
    _showSnackBar(insight.title);
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
            currentRoute: '/it-admin/security-logs',
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
          ITSecurityLogsAppBar(
            isDark: isDark,
            title: l10n.itSecurityLogsAccessControl,
            subtitle: l10n.itSecurityLogsSubtitle,
            onRefreshTap: _loadData,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats cards
                ITSecurityStatsCards(
                  isDark: isDark,
                  stats: _stats,
                  onViewAllEvents: () {
                    setState(() => _selectedMainTab = 0);
                  },
                  onInvestigateBreaches: () {
                    if (_activeIncidents.isNotEmpty) {
                      _showIncidentDetails(_activeIncidents.first);
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Tab section
                ITSecurityLogsTabSection(
                  isDark: isDark,
                  selectedMainTab: _selectedMainTab,
                  selectedSubTab: _selectedSubTab,
                  onMainTabChanged: (index) {
                    setState(() {
                      _selectedMainTab = index;
                      _selectedSubTab = 0;
                    });
                  },
                  onSubTabChanged: (index) {
                    setState(() => _selectedSubTab = index);
                  },
                ),
                const SizedBox(height: 20),
                // Tab content
                _buildTabContent(isDark),
                const SizedBox(height: 24),
                // Active incidents
                ITActiveIncidentsSection(
                  isDark: isDark,
                  incidents: _activeIncidents,
                  onHide: _handleHideIncident,
                  onViewDetails: _showIncidentDetails,
                ),
                if (_activeIncidents.isNotEmpty) const SizedBox(height: 24),
                // AI Security Insights
                ITAISecurityInsights(
                  isDark: isDark,
                  insights: _aiInsights,
                  onTap: _handleAIInsightTap,
                ),
                if (_aiInsights.isNotEmpty) const SizedBox(height: 24),
                // Recent Security Actions
                ITRecentSecurityActions(
                  isDark: isDark,
                  actions: _recentActions,
                  onViewAll: () =>
                      _showSnackBar('Viewing all security actions'),
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
    switch (_selectedMainTab) {
      case 0:
        return ITSecurityLogsList(
          isDark: isDark,
          logs: _filteredLogs,
          searchQuery: _searchQuery,
          selectedFilter: _selectedFilter,
          showFlaggedOnly: _showFlaggedOnly,
          showHighRiskOnly: _showHighRiskOnly,
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
          onFlaggedOnlyChanged: (value) =>
              setState(() => _showFlaggedOnly = value),
          onHighRiskOnlyChanged: (value) =>
              setState(() => _showHighRiskOnly = value),
          onLogTap: _handleLogTap,
        );
      case 1:
        if (_selectedSubTab == 0) {
          return ITAccessRequestsSection(
            isDark: isDark,
            requests: _pendingRequests,
            onApprove: _handleApproveRequest,
            onDeny: _handleDenyRequest,
            onViewDetails: (request) =>
                _showSnackBar('Viewing details for ${request.userName}'),
          );
        } else {
          return ITRolePermissionsSection(
            isDark: isDark,
            roles: _roles,
            onViewPermissions: _handleViewPermissions,
            onViewUsers: _handleViewUsers,
          );
        }
      case 2:
        return ITSecurityPoliciesSection(
          isDark: isDark,
          policies: _policies,
          onTogglePolicy: _handleTogglePolicy,
          onConfigure: _handleConfigurePolicy,
        );
      default:
        return const SizedBox.shrink();
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
