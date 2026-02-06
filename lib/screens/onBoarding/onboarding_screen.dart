import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_theme.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../common/utils/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipToEnd() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        SystemChrome.setSystemUIOverlayStyle(
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );

        return Scaffold(
          body: Stack(
            children: [
              // Animated background
              _AnimatedBackground(
                controller: _backgroundController,
                isDark: isDark,
              ),
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Header with skip button
                    _buildHeader(isDark, l10n, responsive),
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                          _contentController.reset();
                          _contentController.forward();
                        },
                        children: [
                          _OnboardingPage1(
                            controller: _contentController,
                            isDark: isDark,
                            l10n: l10n,
                            responsive: responsive,
                          ),
                          _OnboardingPage2(
                            controller: _contentController,
                            isDark: isDark,
                            l10n: l10n,
                            responsive: responsive,
                          ),
                          _OnboardingPage3(
                            controller: _contentController,
                            isDark: isDark,
                            l10n: l10n,
                            responsive: responsive,
                          ),
                          _OnboardingPage4(
                            controller: _contentController,
                            isDark: isDark,
                            l10n: l10n,
                            responsive: responsive,
                          ),
                        ],
                      ),
                    ),
                    // Bottom section with indicators and buttons
                    _buildBottomSection(isDark, l10n, responsive),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: responsive.p8),
              Text(
                'EduVerse',
                style: TextStyle(
                  fontSize: responsive.fontSize18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          // Skip button
          if (_currentPage < 3)
            TextButton(
              onPressed: _skipToEnd,
              child: Text(
                l10n.skip,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    bool isDark,
    AppLocalizations l10n,
    ResponsiveUtil responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.p24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF2563EB))
                      : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          SizedBox(height: responsive.p24),
          // Action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage < 3 ? l10n.continueButton : l10n.getStarted,
                    style: TextStyle(
                      fontSize: responsive.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: responsive.p8),
                  Icon(
                    _currentPage < 3
                        ? Icons.arrow_forward_rounded
                        : Icons.rocket_launch_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.p16),
          // Sign in link
          if (_currentPage == 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.alreadyHaveAccount,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    l10n.signIn,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ==================== PAGE 1: Welcome ====================
class _OnboardingPage1 extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;

  const _OnboardingPage1({
    required this.controller,
    required this.isDark,
    required this.l10n,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              _buildIllustration(),
              SizedBox(height: responsive.p32),
              // Title
              Text(
                l10n.onboardingTitle1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
              SizedBox(height: responsive.p16),
              // Description
              Text(
                l10n.onboardingDescription1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF162456)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
                .withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
            ),
          ),
          // Floating elements
          Positioned(
            top: 40,
            right: 40,
            child: _FloatingIcon(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFF59E0B),
              size: 32,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 30,
            child: _FloatingIcon(
              icon: Icons.school_rounded,
              color: const Color(0xFF10B981),
              size: 28,
            ),
          ),
          Positioned(
            top: 80,
            left: 50,
            child: _FloatingIcon(
              icon: Icons.psychology_rounded,
              color: const Color(0xFF8B5CF6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PAGE 2: AI-Powered Learning ====================
class _OnboardingPage2 extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;

  const _OnboardingPage2({
    required this.controller,
    required this.isDark,
    required this.l10n,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Feature cards
              _buildFeatureShowcase(),
              SizedBox(height: responsive.p32),
              // Title
              Text(
                l10n.onboardingTitle2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
              SizedBox(height: responsive.p16),
              // Description
              Text(
                l10n.onboardingDescription2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureShowcase() {
    final features = [
      _FeatureItem(
        icon: Icons.quiz_rounded,
        title: 'AI Quiz Generator',
        color: const Color(0xFF8B5CF6),
      ),
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Smart Flashcards',
        color: const Color(0xFF3B82F6),
      ),
      _FeatureItem(
        icon: Icons.summarize_rounded,
        title: 'AI Summarizer',
        color: const Color(0xFF10B981),
      ),
    ];

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central AI brain
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset('assets/logo/ai_logo.png', fit: BoxFit.contain),
          ),
          // // Feature cards around
          // ...List.generate(features.length, (index) {
          //   final angle = (index * 120 - 90) * math.pi / 180;
          //   final radius = 90.0;
          //   return Positioned(
          //     left: 100 + radius * math.cos(angle),
          //     top: 50 + radius * math.sin(angle),
          //     child: _FeatureChip(feature: features[index], isDark: isDark),
          //   );
          // }),
        ],
      ),
    );
  }
}

// ==================== PAGE 3: Track Progress ====================
class _OnboardingPage3 extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;

  const _OnboardingPage3({
    required this.controller,
    required this.isDark,
    required this.l10n,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress visualization
              _buildProgressVisualization(),
              SizedBox(height: responsive.p32),
              // Title
              Text(
                l10n.onboardingTitle3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
              SizedBox(height: responsive.p16),
              // Description
              Text(
                l10n.onboardingDescription3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressVisualization() {
    return Container(
      width: 280,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: '95%',
                label: 'Attendance',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
              _StatItem(
                value: 'A+',
                label: 'Grade',
                color: const Color(0xFF3B82F6),
                isDark: isDark,
              ),
              _StatItem(
                value: '12',
                label: 'Courses',
                color: const Color(0xFF8B5CF6),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '78%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.78,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Achievement badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.emoji_events_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Top Performer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PAGE 4: Get Started ====================
class _OnboardingPage4 extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final AppLocalizations l10n;
  final ResponsiveUtil responsive;

  const _OnboardingPage4({
    required this.controller,
    required this.isDark,
    required this.l10n,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success illustration
              _buildSuccessIllustration(),
              SizedBox(height: responsive.p32),
              // Title
              Text(
                l10n.onboardingTitle4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
              SizedBox(height: responsive.p16),
              // Description
              Text(
                l10n.onboardingDescription4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: responsive.p24),
              // Feature highlights
              _buildFeatureHighlights(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.rocket_launch_rounded,
            size: 80,
            color: Colors.white,
          ),
          // Sparkles
          ...List.generate(6, (index) {
            final angle = index * 60 * math.pi / 180;
            final radius = 80.0;
            return Positioned(
              left: 100 + radius * math.cos(angle) - 8,
              top: 100 + radius * math.sin(angle) - 8,
              child: Icon(
                Icons.star_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final highlights = [
      {'icon': Icons.check_circle_rounded, 'text': 'Free to get started'},
      {'icon': Icons.check_circle_rounded, 'text': 'AI-powered features'},
      {'icon': Icons.check_circle_rounded, 'text': 'Track your progress'},
    ];

    return Column(
      children: highlights.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                color: const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                item['text'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _FloatingIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final Color color;

  _FeatureItem({required this.icon, required this.title, required this.color});
}

class _FeatureChip extends StatelessWidget {
  final _FeatureItem feature;
  final bool isDark;

  const _FeatureChip({required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: feature.color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, color: feature.color, size: 16),
          const SizedBox(width: 6),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ==================== ANIMATED BACKGROUND ====================
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;

  const _AnimatedBackground({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFEFF6FF),
                  Color(0xFFF8FAFC),
                ],
              ),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _BackgroundPainter(
              progress: controller.value,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _BackgroundPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating circles
    final circles = [
      {'x': 0.1, 'y': 0.2, 'r': 80.0, 'speed': 0.3},
      {'x': 0.8, 'y': 0.3, 'r': 60.0, 'speed': 0.5},
      {'x': 0.3, 'y': 0.7, 'r': 100.0, 'speed': 0.2},
      {'x': 0.9, 'y': 0.8, 'r': 50.0, 'speed': 0.4},
    ];

    for (final circle in circles) {
      final x = circle['x'] as double;
      final y =
          (circle['y'] as double) +
          math.sin(progress * 2 * math.pi * (circle['speed'] as double)) * 0.05;
      final r = circle['r'] as double;

      paint.color = (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
          .withOpacity(isDark ? 0.05 : 0.03);

      canvas.drawCircle(Offset(x * size.width, y * size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
