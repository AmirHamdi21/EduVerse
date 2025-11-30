import 'package:edu_verse/widgets/onBoarding/background_stars.dart';
import 'package:edu_verse/widgets/onBoarding/navigation_buttons.dart';
import 'package:edu_verse/widgets/onBoarding/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/screens/onBoarding/onboarding2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF155CFB), Color(0xFF1347E5), Color(0xFF1B388E)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            BackgroundStars(),

            // Large decorative circles
            Positioned(
              left: 0,
              top: 338.48,
              child: Container(
                width: 383.99,
                height: 383.99,
                decoration: ShapeDecoration(
                  color: const Color(0x3300D3F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(34017000),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -5.85,
              top: 631.49,
              child: Container(
                width: 383.99,
                height: 383.99,
                decoration: ShapeDecoration(
                  color: const Color(0x332B7FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(34017000),
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with logo and skip button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1.01,
                                      color: Color(0x33FFFEFE),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x7500C2FF),
                                      blurRadius: 27.96,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.appName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.skip,
                              style: const TextStyle(
                                color: Color(0xCCFFFEFE),
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Image card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        height: 298,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x3300D2F2), Color(0x332B7FFF)],
                          ),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.01,
                              color: Color(0x33FFFEFE),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x5100C2FF),
                              blurRadius: 71.60,
                              offset: Offset(0, 10),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: -17,
                              top: -39,
                              child: Opacity(
                                opacity: 0.37,
                                child: Container(
                                  width: 213.02,
                                  height: 213.02,
                                  decoration: ShapeDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF00D2F2),
                                        Color(0xFF2B7FFF),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        34017000,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(25),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  "assets/images/panda.png",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        AppLocalizations.of(context)!.onboarding1MainTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        AppLocalizations.of(context)!.onboarding1Description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFDAEAFE),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.62,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        AppLocalizations.of(context)!.poweredByAI,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF53E9FC),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: NavigationButtons(
                        nextOnPressed: () {
                          context.go('/onboarding2');
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    PageIndicator(
                      isActive_1: true,
                      isActive_2: false,
                      isActive_3: false,
                      isActive_4: false,
                    ),
                    // const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
