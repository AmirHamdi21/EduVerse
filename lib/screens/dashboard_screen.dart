// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../bloc/auth/auth_bloc.dart';
// import '../bloc/auth/auth_event.dart';
// import '../bloc/auth/auth_state.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() {
//     context.read<AuthBloc>().add(const RefreshUserDataRequested());
//   }

//   Future<void> _handleLogout() async {
//     final shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFEF4444),
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );

//     if (shouldLogout == true && mounted) {
//       context.read<AuthBloc>().add(const LogoutRequested());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthUnauthenticated) {
//           context.go('/login');
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Dashboard'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: _handleLogout,
//             ),
//           ],
//         ),
//         body: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (state is! AuthAuthenticated &&
//                 state is! AuthEmailVerificationNeeded) {
//               return const Center(child: Text('Please login to continue'));
//             }

//             final user = state is AuthAuthenticated
//                 ? state.user
//                 : (state as AuthEmailVerificationNeeded).user;

//             return RefreshIndicator(
//               onRefresh: () async => _loadUserData(),
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Profile Card
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 50,
//                               backgroundColor: Colors.white,
//                               child: user.profilePictureUrl != null
//                                   ? ClipOval(
//                                       child: Image.network(
//                                         user.profilePictureUrl!,
//                                         width: 100,
//                                         height: 100,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     )
//                                   : Text(
//                                       user.initials,
//                                       style: const TextStyle(
//                                         fontSize: 32,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF6366F1),
//                                       ),
//                                     ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               user.fullName,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               user.email,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.white.withOpacity(0.9),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     user.emailVerified
//                                         ? Icons.verified
//                                         : Icons.warning,
//                                     size: 16,
//                                     color: Colors.white,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     user.emailVerified
//                                         ? 'Verified'
//                                         : 'Not Verified',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // User Information
//                       const Text(
//                         'Account Information',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildInfoCard('User ID', '#${user.userId}'),
//                       _buildInfoCard('Email', user.email),
//                       _buildInfoCard('Phone', user.phone ?? 'Not provided'),
//                       _buildInfoCard('Status', user.status),
//                       _buildInfoCard(
//                         'Member Since',
//                         _formatDate(user.createdAt),
//                       ),
//                       if (user.lastLoginAt != null)
//                         _buildInfoCard(
//                           'Last Login',
//                           _formatDate(user.lastLoginAt!),
//                         ),
//                       const SizedBox(height: 24),

//                       // Roles
//                       const Text(
//                         'Roles',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: user.roles.map((role) {
//                           return Chip(
//                             label: Text(role.toUpperCase()),
//                             backgroundColor: const Color(0xFF6366F1),
//                             labelStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 24),

//                       // Permissions
//                       const Text(
//                         'Permissions',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: user.permissions.map((permission) {
//                           return Chip(
//                             avatar: const Icon(
//                               Icons.check_circle,
//                               size: 18,
//                               color: Color(0xFF10B981),
//                             ),
//                             label: Text(
//                               permission.replaceAll('_', ' ').toUpperCase(),
//                             ),
//                             backgroundColor: const Color(
//                               0xFF10B981,
//                             ).withOpacity(0.1),
//                             labelStyle: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 24),

//                       // Logout Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton.icon(
//                           onPressed: _handleLogout,
//                           icon: const Icon(Icons.logout),
//                           label: const Text('Logout'),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: const Color(0xFFEF4444),
//                             side: const BorderSide(
//                               color: Color(0xFFEF4444),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String label, String value) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Flexible(
//               child: Text(
//                 value,
//                 textAlign: TextAlign.right,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateStr;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../config/app_theme.dart';
import '../common/utils/responsive.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    context.read<AuthBloc>().add(const RefreshUserDataRequested());
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final textColor = isDark
              ? AppTheme.darkTextPrimary
              : const Color(0xFF1E293B);
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
            title: Text('Logout', style: TextStyle(color: textColor)),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: textColor)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );

    if (shouldLogout == true && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final bgColor = isDark
              ? AppTheme.darkSurfaceColor
              : const Color(0xFFF8FAFC);
          final textColor = isDark
              ? AppTheme.darkTextPrimary
              : const Color(0xFF1E293B);
          final textSecondaryColor = isDark
              ? AppTheme.darkTextSecondary
              : const Color(0xFF64748B);
          final cardBgColor = isDark ? AppTheme.darkCardColor : Colors.white;

          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
              elevation: 0,
              title: Text(
                'Dashboard',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: responsive.fontSize18),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: textColor, size: responsive.iconMedium),
                  onPressed: _handleLogout,
                ),
              ],
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is! AuthAuthenticated &&
                    state is! AuthEmailVerificationNeeded) {
                  return Center(
                    child: Text(
                      'Please login to continue',
                      style: TextStyle(color: textColor, fontSize: responsive.fontSize16),
                    ),
                  );
                }

                final user = state is AuthAuthenticated
                    ? state.user
                    : (state as AuthEmailVerificationNeeded).user;

                return RefreshIndicator(
                  onRefresh: () async => _loadUserData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(responsive.p20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(responsive.p24),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.darkBg1,
                                        AppTheme.darkBg2,
                                        AppTheme.darkBg3,
                                      ],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFEEF5FE),
                                        Colors.white,
                                        Color(0xFFFAF5FE),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(responsive.radius20),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: responsive.aspectRatioWidth(50),
                                  backgroundColor: Colors.white,
                                  child: user.profilePictureUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            user.profilePictureUrl!,
                                            width: responsive.aspectRatioWidth(100),
                                            height: responsive.aspectRatioHeight(100),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          user.initials,
                                          style: TextStyle(
                                            fontSize: responsive.fontSize32,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                ),
                                SizedBox(height: responsive.p16),
                                Text(
                                  user.fullName,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: responsive.p4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: responsive.p12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.p12,
                                    vertical: responsive.p8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(responsive.radius20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user.emailVerified
                                            ? Icons.verified
                                            : Icons.warning,
                                        size: responsive.iconSmall,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: responsive.p4),
                                      Text(
                                        user.emailVerified
                                            ? 'Verified'
                                            : 'Not Verified',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsive.fontSize12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.p24),

                          // User Information
                          Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: responsive.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: responsive.p16),
                          _buildInfoCard(
                            'User ID',
                            '#${user.userId}',
                            isDark,
                            cardBgColor,
                            textColor,
                            textSecondaryColor,
                            responsive,
                          ),
                          _buildInfoCard(
                            'Email',
                            user.email,
                            isDark,
                            cardBgColor,
                            textColor,
                            textSecondaryColor,
                            responsive,
                          ),
                          _buildInfoCard(
                            'Phone',
                            user.phone ?? 'Not provided',
                            isDark,
                            cardBgColor,
                            textColor,
                            textSecondaryColor,
                            responsive,
                          ),
                          _buildInfoCard(
                            'Status',
                            user.status,
                            isDark,
                            cardBgColor,
                            textColor,
                            textSecondaryColor,
                            responsive,
                          ),
                          _buildInfoCard(
                            'Member Since',
                            _formatDate(user.createdAt),
                            isDark,
                            cardBgColor,
                            textColor,
                            textSecondaryColor,
                            responsive,
                          ),
                          if (user.lastLoginAt != null)
                            _buildInfoCard(
                              'Last Login',
                              _formatDate(user.lastLoginAt!),
                              isDark,
                              cardBgColor,
                              textColor,
                              textSecondaryColor,
                              responsive,
                            ),
                          SizedBox(height: responsive.p24),

                          // Roles
                          Text(
                            'Roles',
                            style: TextStyle(
                              fontSize: responsive.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: responsive.p12),
                          Wrap(
                            spacing: responsive.p8,
                            runSpacing: responsive.p8,
                            children: user.roles.map((role) {
                              return Chip(
                                label: Text(
                                  role.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize14,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF6366F1),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: responsive.p24),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleLogout,
                              icon: Icon(Icons.logout, size: responsive.iconMedium),
                              label: Text('Logout', style: TextStyle(fontSize: responsive.fontSize16)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: responsive.p12),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.p20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    bool isDark,
    Color cardBgColor,
    Color textColor,
    Color textSecondaryColor,
    ResponsiveUtil responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: isDark ? const Color(0xFF404756) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize14,
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: responsive.fontSize14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
