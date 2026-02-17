import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../widgets/admin/shared/admin_colors.dart';
import '../../widgets/admin/dashboard/admin_dashboard_barrel.dart';

/// Admin Dashboard Screen
/// Full-featured dashboard for administrators with user management,
/// course management, reports, AI insights, and system health monitoring.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate loading data
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          drawer: const AdminDrawer(),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: _buildContent(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AdminColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const AdminAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const AdminStatsSection(),
                const SizedBox(height: 24),
                const AdminQuickActionsGrid(),
                const SizedBox(height: 24),
                const AdminAIInsightsSection(),
                const SizedBox(height: 24),
                const AdminUserDistributionSection(),
                const SizedBox(height: 24),
                const AdminSystemHealthSection(),
                const SizedBox(height: 24),
                const AdminRecentActivitySection(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AdminColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
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
