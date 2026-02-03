import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //Onboarding colors
  static const onBoardingprimary = Color(0xFF155DFC);
  static const onBoardingprimaryLight = Color(0xFF2B7FFF);
  static const onBoardingprimaryDark = Color(0xFF1447E6);
  static const onBoardingprimaryDarker = Color(0xFF1C398E);
  static const onBoardingcyan = Color(0xFF00B8DA);
  static const onBoardingcyanLight = Color(0xFF0092B8);
  static const onBoardingpurple = Color(0xFF4F39F6);
  static const onBoardingtextDark = Color(0xFF1D2838);
  static const onBoardingtextMedium = Color(0xFF354152);
  static const onBoardingtextLight = Color(0xFF495565);
  static const onBoardingbackgroundLight = Color(0xFFEEF5FE);
  static const onBoardingbackgroundCyan = Color(0xFFEBFDFE);
  static const onBoardingborderCyan = Color(0xFFA2F3FC);
  static const onBoardingborderBlue = Color(0xFFBDDAFF);
  static const onBoardingborderPurple = Color(0xFFC6D1FF);
  static const onBoardingdivider = Color(0x7FE5E7EB);
  static const onBoardingindicator = Color.fromARGB(255, 150, 188, 253);
  static const onBoardingstarColor = Color(0xFF53EAFD);
  static const onBoardingprimaryGradient = LinearGradient(
    colors: [Color(0xFF2B7FFF), Color(0xFF0092B8)],
  );

  // Onboarding dark mode card colors
  static const onBoardingCardCyanDark = Color(0xFF0D3B47);
  static const onBoardingCardBlueDark = Color(0xFF1A2E5C);
  static const onBoardingCardPurpleDark = Color(0xFF2D1B4E);

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF155CFB), Color(0xFF1347E5), Color(0xFF1B388E)],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppTheme.onBoardingprimary,
      AppTheme.onBoardingprimaryLight,
      AppTheme.onBoardingcyan,
    ],
  );

  static const backgroundGradient = LinearGradient(
    colors: [
      AppTheme.onBoardingbackgroundLight,
      Colors.white,
      AppTheme.onBoardingbackgroundCyan,
    ],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF155DFC), Color(0xFF1447E6), Color(0xFF1C398E)],
  );

  static const iconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.onBoardingprimaryLight, AppTheme.onBoardingcyanLight],
  );

  // Light mode colors
  static const primaryColor = Color(0xFF155DFC); // Blue
  static const primaryLight = Color(0xFF2B7FFF);
  static const secondaryColor = Color(0xFF8B5CF6); // Purple
  static const accentColor = Color(0xFF06B6D4); // Cyan
  static const errorColor = Color(0xFFEF4444);
  static const successColor = Color(0xFF10B981);
  static const warningColor = Color(0xFFF59E0B);
  static const greenSuccess = Color(0xFF00C950);
  static const cardBorder = Color(0xFFE5E7EB);
  static const textLight = Color(0xFF495565);
  static const textMedium = Color(0xFF354152);
  static const textDark = Color(0xFF1D2838);
  static const lightTextSecondary = Color.fromARGB(255, 45, 63, 90);

  // Dark mode colors
  static const darkBg1 = Color(0xFF030712);
  static const darkBg2 = Color(0xFF101828);
  static const darkBg3 = Color(0xFF162456);
  static const darkSurfaceColor = Color(0xFF0F172A);
  static const darkCardColor = Color(0xFF1A2847);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA0AEC0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: darkBg2,
        surface: darkCardColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: darkTextPrimary, displayColor: darkTextPrimary),
      scaffoldBackgroundColor: darkSurfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg2,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkCardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404756)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404756)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary),
        labelStyle: const TextStyle(color: darkTextPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
