// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/themes/app_colors.dart';
// import '../../../onboarding/presentation/cubit/theme_cubit.dart';
// import '../../../onboarding/presentation/screens/onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _rippleController;
//   late AnimationController _fadeController;

//   late Animation<double> _logoScale;
//   late Animation<double> _logoOpacity;
//   late Animation<double> _rippleScale;
//   late Animation<double> _rippleOpacity;
//   late Animation<double> _textOpacity;
//   late Animation<Offset> _textSlide;
//   late Animation<double> _progressOpacity;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _startAnimationSequence();
//   }

//   void _setupAnimations() {
//     // Logo animation controller
//     _logoController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     // Ripple animation controller
//     _rippleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     // Fade out controller
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     // Logo animations
//     _logoScale = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: 0.0, end: 1.15).chain(
//           CurveTween(curve: Curves.easeOutBack),
//         ),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 1.15, end: 1.0).chain(
//           CurveTween(curve: Curves.easeInOut),
//         ),
//         weight: 40,
//       ),
//     ]).animate(_logoController);

//     _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _logoController,
//         curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
//       ),
//     );

//     // Ripple animations
//     _rippleScale = Tween<double>(begin: 0.8, end: 2.5).animate(
//       CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
//     );

//     _rippleOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
//       CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
//     );

//     // Text animations
//     _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _logoController,
//         curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
//       ),
//     );

//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _logoController,
//         curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
//       ),
//     );

//     // Progress indicator opacity
//     _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _logoController,
//         curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
//       ),
//     );
//   }

//   void _startAnimationSequence() async {
//     // Start logo animation
//     await Future.delayed(const Duration(milliseconds: 200));
//     _logoController.forward();

//     // Start ripple animation
//     await Future.delayed(const Duration(milliseconds: 400));
//     _rippleController.forward();

//     // Wait for splash duration
//     await Future.delayed(const Duration(milliseconds: 2200));

//     // Navigate to onboarding
//     if (mounted) {
//       _fadeController.forward().then((_) {
//         Navigator.pushReplacement(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 const OnboardingScreen(),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               return FadeTransition(opacity: animation, child: child);
//             },
//             transitionDuration: const Duration(milliseconds: 500),
//           ),
//         );
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _rippleController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = context.select<ThemeCubit, bool>(
//       (cubit) => cubit.state.isDarkMode,
//     );

//     // Set system UI overlay style
//     SystemChrome.setSystemUIOverlayStyle(
//       isDarkMode
//           ? SystemUiOverlayStyle.light.copyWith(
//               statusBarColor: Colors.transparent,
//             )
//           : SystemUiOverlayStyle.dark.copyWith(
//               statusBarColor: Colors.transparent,
//             ),
//     );

//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _fadeController,
//         builder: (context, child) {
//           return Opacity(
//             opacity: 1 - _fadeController.value,
//             child: child,
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: isDarkMode
//                   ? [
//                       const Color(0xFF0A0A14),
//                       const Color(0xFF12121F),
//                       const Color(0xFF1A1A2E),
//                     ]
//                   : [
//                       const Color(0xFFF8FAFF),
//                       const Color(0xFFFFFFFF),
//                       const Color(0xFFF0F4FF),
//                     ],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Animated background particles
//               RepaintBoundary(
//                 child: _AnimatedParticles(isDarkMode: isDarkMode),
//               ),
//               // Main content
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Spacer(flex: 3),
//                     // Logo with ripple effect
//                     _buildLogoSection(isDarkMode),
//                     const SizedBox(height: 32),
//                     // App name and tagline
//                     _buildTextSection(isDarkMode),
//                     const Spacer(flex: 2),
//                     // Loading indicator
//                     _buildLoadingSection(isDarkMode),
//                     const SizedBox(height: 48),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoSection(bool isDarkMode) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_logoController, _rippleController]),
//       builder: (context, child) {
//         return SizedBox(
//           width: 180,
//           height: 180,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Ripple effect
//               Transform.scale(
//                 scale: _rippleScale.value,
//                 child: Opacity(
//                   opacity: _rippleOpacity.value,
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: AppColors.primary.withValues(alpha: 0.5),
//                         width: 3,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               // Glow effect
//               Opacity(
//                 opacity: _logoOpacity.value * 0.6,
//                 child: Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.primary.withValues(alpha: 0.4),
//                         blurRadius: 50,
//                         spreadRadius: 10,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Logo container
//               Transform.scale(
//                 scale: _logoScale.value,
//                 child: Opacity(
//                   opacity: _logoOpacity.value,
//                   child: Container(
//                     width: 110,
//                     height: 110,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           AppColors.primary,
//                           Color(0xFF7C4DFF),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.primary.withValues(alpha: 0.4),
//                           blurRadius: 25,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: _LogoIcon(),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTextSection(bool isDarkMode) {
//     return AnimatedBuilder(
//       animation: _logoController,
//       builder: (context, child) {
//         return SlideTransition(
//           position: _textSlide,
//           child: Opacity(
//             opacity: _textOpacity.value,
//             child: Column(
//               children: [
//                 // App name
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [AppColors.primary, Color(0xFF7C4DFF)],
//                   ).createShader(bounds),
//                   child: const Text(
//                     'HabitFlow',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // Tagline
//                 Text(
//                   'Build Better Habits',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                     color: isDarkMode
//                         ? AppColors.darkTextSecondary
//                         : AppColors.lightTextSecondary,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoadingSection(bool isDarkMode) {
//     return AnimatedBuilder(
//       animation: _logoController,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _progressOpacity.value,
//           child: Column(
//             children: [
//               // Custom loading indicator
//               SizedBox(
//                 width: 140,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.0, end: 1.0),
//                     duration: const Duration(milliseconds: 1800),
//                     curve: Curves.easeInOut,
//                     builder: (context, value, child) {
//                       return LinearProgressIndicator(
//                         value: value,
//                         minHeight: 4,
//                         backgroundColor: isDarkMode
//                             ? Colors.white.withValues(alpha: 0.1)
//                             : Colors.black.withValues(alpha: 0.08),
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           AppColors.primary,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Loading text
//               Text(
//                 'Loading...',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: isDarkMode
//                       ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
//                       : AppColors.lightTextSecondary.withValues(alpha: 0.7),
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // ==================== LOGO ICON ====================
// class _LogoIcon extends StatelessWidget {
//   const _LogoIcon();

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       size: const Size(50, 50),
//       painter: _LogoPainter(),
//     );
//   }
// }

// class _LogoPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.5
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;

//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width * 0.35;

//     // Draw circular progress arc (representing habit tracking)
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -math.pi / 2,
//       math.pi * 1.5,
//       false,
//       paint,
//     );

//     // Draw checkmark
//     final checkPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.5
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;

//     final checkPath = Path();
//     checkPath.moveTo(center.dx - 8, center.dy + 2);
//     checkPath.lineTo(center.dx - 2, center.dy + 8);
//     checkPath.lineTo(center.dx + 10, center.dy - 6);

//     canvas.drawPath(checkPath, checkPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // ==================== ANIMATED PARTICLES ====================
// class _AnimatedParticles extends StatefulWidget {
//   final bool isDarkMode;

//   const _AnimatedParticles({required this.isDarkMode});

//   @override
//   State<_AnimatedParticles> createState() => _AnimatedParticlesState();
// }

// class _AnimatedParticlesState extends State<_AnimatedParticles>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final List<_Particle> _particles = [];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 10),
//     )..repeat();

//     // Generate particles
//     final random = math.Random();
//     for (int i = 0; i < 20; i++) {
//       _particles.add(_Particle(
//         x: random.nextDouble(),
//         y: random.nextDouble(),
//         size: random.nextDouble() * 4 + 2,
//         speed: random.nextDouble() * 0.3 + 0.1,
//         opacity: random.nextDouble() * 0.3 + 0.1,
//       ));
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return CustomPaint(
//           size: Size.infinite,
//           painter: _ParticlesPainter(
//             particles: _particles,
//             progress: _controller.value,
//             isDarkMode: widget.isDarkMode,
//           ),
//         );
//       },
//     );
//   }
// }

// class _Particle {
//   final double x;
//   final double y;
//   final double size;
//   final double speed;
//   final double opacity;

//   _Particle({
//     required this.x,
//     required this.y,
//     required this.size,
//     required this.speed,
//     required this.opacity,
//   });
// }

// class _ParticlesPainter extends CustomPainter {
//   final List<_Particle> particles;
//   final double progress;
//   final bool isDarkMode;

//   _ParticlesPainter({
//     required this.particles,
//     required this.progress,
//     required this.isDarkMode,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final particle in particles) {
//       final y = (particle.y + progress * particle.speed) % 1.0;
//       final paint = Paint()
//         ..color = (isDarkMode ? Colors.white : AppColors.primary)
//             .withValues(alpha: particle.opacity)
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         Offset(particle.x * size.width, y * size.height),
//         particle.size,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }
