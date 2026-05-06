import 'package:flutter/material.dart';

class QuestionBankSkeletons extends StatelessWidget {
  const QuestionBankSkeletons({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          height: 112,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
