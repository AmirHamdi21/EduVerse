import 'package:flutter/material.dart';

class DecorativeCircles extends StatelessWidget {
  const DecorativeCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 338.48,
          child: Container(
            width: 383.99,
            height: 383.99,
            decoration: const BoxDecoration(
              color: Color(0x3300D3F3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -5.85,
          top: 631.49,
          child: Container(
            width: 383.99,
            height: 383.99,
            decoration: const BoxDecoration(
              color: Color(0x332B7FFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -299.99,
          top: -299.99,
          child: Container(
            width: 599.99,
            height: 599.99,
            decoration: const BoxDecoration(
              color: Color(0x4CBEDBFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 44.82,
          top: 692.13,
          child: Container(
            width: 499.99,
            height: 499.99,
            decoration: const BoxDecoration(
              color: Color(0x3FA2F4FD),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
