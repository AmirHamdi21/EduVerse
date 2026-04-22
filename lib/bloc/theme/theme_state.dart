import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

enum FontSizeOption { small, medium, large }

abstract class ThemeState extends Equatable {
  final bool isDark;
  final AppThemeMode themeMode;
  final FontSizeOption fontSize;

  const ThemeState({
    required this.isDark,
    this.themeMode = AppThemeMode.light,
    this.fontSize = FontSizeOption.medium,
  });

  double get fontScale {
    switch (fontSize) {
      case FontSizeOption.small:
        return 0.85;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.15;
    }
  }

  @override
  List<Object?> get props => [isDark, themeMode, fontSize];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial({required super.isDark, super.themeMode, super.fontSize});
}

class ThemeChanged extends ThemeState {
  const ThemeChanged({required super.isDark, super.themeMode, super.fontSize});
}
