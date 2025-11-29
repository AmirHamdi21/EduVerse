import 'package:edu_verse/common/classes/role_feature.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FeatureCard extends StatelessWidget {
  String title;
  Color badgeColor;
  Color borderColor;
  List<Color> gradientColors;
  List<Color> decorGradient;
  List<RoleFeature> features;
  String tagline;
  Color taglineColor;
  FeatureCard({
    super.key,
    required this.title,
    required this.badgeColor,
    required this.borderColor,
    required this.gradientColors,
    required this.decorGradient,
    required this.features,
    required this.tagline,
    required this.taglineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: decorGradient),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: AppTheme.onBoardingprimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.onBoardingtextDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: badgeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI-Powered',
                              style: TextStyle(fontSize: 12, color: badgeColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.onBoardingtextMedium,
                              height: 1.43,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppTheme.onBoardingdivider, height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 12,
                      color: taglineColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tagline,
                        style: TextStyle(
                          fontSize: 12,
                          color: taglineColor,
                          fontStyle: FontStyle.italic,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
