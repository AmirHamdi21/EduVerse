import 'package:edu_verse/widgets/onBoarding/page_dot.dart';
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  bool isActive_1;
  bool isActive_2;
  bool isActive_3;
  bool isActive_4;
  PageIndicator({
    super.key,
    required this.isActive_1,
    required this.isActive_2,
    required this.isActive_3,
    required this.isActive_4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PageDot(isActive: isActive_1),
        const SizedBox(width: 8),
        PageDot(isActive: isActive_2),
        const SizedBox(width: 8),
        PageDot(isActive: isActive_3),
        const SizedBox(width: 8),
        PageDot(isActive: isActive_4),
      ],
    );
  }
}
