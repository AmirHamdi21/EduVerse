import 'package:edu_verse/common/classes/start_data.dart';
import 'package:edu_verse/widgets/onBoarding/build_star.dart';
import 'package:flutter/material.dart';

class BackgroundStars extends StatelessWidget {
  final stars = [
    StarData(201.89, 418.56, 5.38, 0.66),
    StarData(237.87, 224.73, 4.49, 0.35),
    StarData(308.48, 32.60, 5.12, 0.56),
    StarData(302.68, 488.80, 4.11, 0.22),
    StarData(207.72, 316.28, 4.01, 0.20),
    StarData(5.36, 306.77, 5.12, 0.41),
    StarData(320.46, 191.05, 5.71, 0.53),
    StarData(134.48, 354.13, 5.56, 0.73),
    StarData(237.54, 49.31, 3.99, 0.20),
    StarData(222.45, 522.81, 5.04, 0.53),
    StarData(114.91, 300.22, 5.10, 0.55),
    StarData(21.92, 25.71, 4.19, 0.24),
    StarData(354.31, 109.88, 4.90, 0.48),
    StarData(250.89, 622.96, 4.86, 0.36),
    StarData(339.71, 55.71, 4.51, 0.35),
    StarData(248.35, 202.46, 4.96, 0.38),
  ];
  BackgroundStars({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: stars.map((star) => BuildStar(data: star)).toList(),
      ),
    );
  }
}
