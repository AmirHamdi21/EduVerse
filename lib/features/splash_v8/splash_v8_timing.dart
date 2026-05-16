import 'package:flutter/material.dart';

class SplashV8Timing {
  const SplashV8Timing._();

  static const int timelineMs = 3800;
  static const Duration timelineDuration = Duration(milliseconds: timelineMs);
  static const Curve motionCurve = Cubic(0.25, 0.1, 0.25, 1);
}
