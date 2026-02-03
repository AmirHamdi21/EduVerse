import 'package:flutter/material.dart';

/// Responsive helper class for adaptive UI sizing across devices
class ResponsiveUtil {
  /// Device breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  final BuildContext context;

  ResponsiveUtil(this.context);

  /// Screen dimensions
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Device orientation
  bool get isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Device type
  bool get isMobile => screenWidth < mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
  bool get isDesktop => screenWidth >= tabletBreakpoint;

  /// Responsive padding/margin (base 4dp unit system)
  double get p2 => 2;
  double get p3 => 3;
  double get p4 => 4;
  double get p5 => 5;
  double get p6 => 6;
  double get p7 => 7;
  double get p8 => 8;
  double get p9 => 9;
  double get p10 => 10;
  double get p11 => 11;
  double get p12 => 12;
  double get p13 => 13;
  double get p14 => 14;
  double get p16 => 16 * scaleFactor;
  double get p18 => 18 * scaleFactor;
  double get p20 => 20 * scaleFactor;
  double get p24 => 24 * scaleFactor;
  double get p32 => 32 * scaleFactor;
  double get p36 => 36 * scaleFactor;
  double get p40 => 40 * scaleFactor;
  double get p44 => 44 * scaleFactor;
  double get p48 => 48 * scaleFactor;
  double get p50 => 50 * scaleFactor;
  double get p56 => 56 * scaleFactor;
  double get p64 => 64 * scaleFactor;
  double get p72 => 72 * scaleFactor;
  double get p80 => 80 * scaleFactor;
  double get p96 => 96 * scaleFactor;
  double get p104 => 104 * scaleFactor;
  double get p112 => 112 * scaleFactor;
  double get p120 => 120 * scaleFactor;
  double get p128 => 128 * scaleFactor;
  double get p136 => 136 * scaleFactor;
  double get p144 => 144 * scaleFactor;
  double get p152 => 152 * scaleFactor;
  double get p160 => 160 * scaleFactor;
  double get p168 => 168 * scaleFactor;
  double get p176 => 176 * scaleFactor;
  double get p184 => 184 * scaleFactor;
  double get p192 => 192 * scaleFactor;
  double get p200 => 200 * scaleFactor;
  double get p208 => 208 * scaleFactor;
  double get p216 => 216 * scaleFactor;
  double get p224 => 224 * scaleFactor;
  double get p232 => 232 * scaleFactor;
  double get p240 => 240 * scaleFactor;
  double get p248 => 248 * scaleFactor;
  double get p256 => 256 * scaleFactor;
  double get p264 => 264 * scaleFactor;
  double get p272 => 272 * scaleFactor;
  double get p280 => 280 * scaleFactor;
  double get p288 => 288 * scaleFactor;
  double get p296 => 296 * scaleFactor;
  double get p304 => 304 * scaleFactor;
  double get p312 => 312 * scaleFactor;
  double get p320 => 320 * scaleFactor;
  double get p328 => 328 * scaleFactor;
  double get p336 => 336 * scaleFactor;
  double get p344 => 344 * scaleFactor;
  double get p352 => 352 * scaleFactor;
  double get p360 => 360 * scaleFactor;
  double get p368 => 368 * scaleFactor;
  double get p376 => 376 * scaleFactor;
  double get p384 => 384 * scaleFactor;
  double get p392 => 392 * scaleFactor;
  double get p400 => 400 * scaleFactor;
  double get p408 => 408 * scaleFactor;
  double get p416 => 416 * scaleFactor;
  double get p424 => 424 * scaleFactor;
  double get p432 => 432 * scaleFactor;
  double get p440 => 440 * scaleFactor;
  double get p448 => 448 * scaleFactor;
  double get p456 => 456 * scaleFactor;
  double get p464 => 464 * scaleFactor;
  double get p472 => 472 * scaleFactor;
  double get p480 => 480 * scaleFactor;
  double get p488 => 488 * scaleFactor;
  double get p496 => 496 * scaleFactor;
  double get p504 => 504 * scaleFactor;
  double get p512 => 512 * scaleFactor;
  double get p520 => 520 * scaleFactor;
  double get p528 => 528 * scaleFactor;
  double get p536 => 536 * scaleFactor;
  double get p544 => 544 * scaleFactor;
  double get p552 => 552 * scaleFactor;
  double get p560 => 560 * scaleFactor;

  /// Responsive font sizes
  double get fontSize8 => 8 * fontScaleFactor;
  double get fontSize10 => 10 * fontScaleFactor;
  double get fontSize11 => 11 * fontScaleFactor;
  double get fontSize12 => 12 * fontScaleFactor;
  double get fontSize13 => 13 * fontScaleFactor;
  double get fontSize14 => 14 * fontScaleFactor;
  double get fontSize16 => 16 * fontScaleFactor;
  double get fontSize18 => 18 * fontScaleFactor;
  double get fontSize20 => 20 * fontScaleFactor;
  double get fontSize24 => 24 * fontScaleFactor;
  double get fontSize28 => 28 * fontScaleFactor;
  double get fontSize32 => 32 * fontScaleFactor;
  double get fontSize40 => 40 * fontScaleFactor;
  double get fontSize48 => 48 * fontScaleFactor;
  double get fontSize56 => 56 * fontScaleFactor;

  /// Responsive border radius
  double get radius4 => 4;
  double get radius6 => 6;
  double get radius8 => 8;
  double get radius10 => 10 * radiusScaleFactor;
  double get radius12 => 12 * radiusScaleFactor;
  double get radius14 => 14 * radiusScaleFactor;
  double get radius16 => 16 * radiusScaleFactor;
  double get radius20 => 20 * radiusScaleFactor;
  double get radius24 => 24 * radiusScaleFactor;

  /// Responsive icon sizes
  double get iconSmall => 16 * iconScaleFactor;
  double get iconMedium => 24 * iconScaleFactor;
  double get iconLarge => 32 * iconScaleFactor;
  double get iconExtraLarge => 48 * iconScaleFactor;

  /// Scale factors based on device
  double get scaleFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.2;
  }

  double get fontScaleFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.05;
    return 1.1;
  }

  double get radiusScaleFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.08;
    return 1.1;
  }

  double get iconScaleFactor {
    if (isMobile) return 1.0;
    if (isTablet) return 1.1;
    return 1.2;
  }

  /// Responsive width calculation
  double responsiveWidth(double percentage) {
    return screenWidth * (percentage / 100);
  }

  /// Responsive height calculation
  double responsiveHeight(double percentage) {
    return screenHeight * (percentage / 100);
  }

  /// Get aspect ratio adjusted width
  double aspectRatioWidth(double baseWidth) {
    return baseWidth * scaleFactor;
  }

  /// Get aspect ratio adjusted height
  double aspectRatioHeight(double baseHeight) {
    return baseHeight * scaleFactor;
  }

  /// Container max width for centered layouts
  double get maxContainerWidth {
    if (isMobile) return screenWidth - p32;
    if (isTablet) return screenWidth * 0.85;
    return 800;
  }

  /// Get responsive padding for content
  EdgeInsets get contentPadding {
    if (isMobile) return EdgeInsets.all(p16);
    if (isTablet) return EdgeInsets.all(p24);
    return EdgeInsets.all(p32);
  }

  /// Get responsive horizontal padding
  EdgeInsets get horizontalPadding {
    if (isMobile) return EdgeInsets.symmetric(horizontal: p16);
    if (isTablet) return EdgeInsets.symmetric(horizontal: p24);
    return EdgeInsets.symmetric(horizontal: p32);
  }

  /// Get responsive vertical padding
  EdgeInsets get verticalPadding {
    if (isMobile) return EdgeInsets.symmetric(vertical: p12);
    if (isTablet) return EdgeInsets.symmetric(vertical: p16);
    return EdgeInsets.symmetric(vertical: p20);
  }

  /// Get number of columns for grid
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }

  /// Responsive button height
  double get buttonHeight {
    if (isMobile) return 56;
    if (isTablet) return 52;
    return 56;
  }

  /// Responsive input field height
  double get inputHeight {
    if (isMobile) return 48;
    if (isTablet) return 52;
    return 56;
  }

  /// Safe area top
  double get safeAreaTop => MediaQuery.of(context).padding.top;

  /// Safe area bottom
  double get safeAreaBottom => MediaQuery.of(context).padding.bottom;

  /// Total safe area
  EdgeInsets get safePadding => MediaQuery.of(context).padding;

  /// Check if device has notch
  bool get hasNotch => safeAreaTop > 24;
}

/// Extension on BuildContext for easier access to ResponsiveUtil
extension ResponsiveContext on BuildContext {
  ResponsiveUtil get responsive => ResponsiveUtil(this);
}
