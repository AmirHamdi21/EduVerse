import 'package:equatable/equatable.dart';
import 'theme_state.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class InitThemeEvent extends ThemeEvent {
  const InitThemeEvent();
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class SetThemeEvent extends ThemeEvent {
  final bool isDark;

  const SetThemeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}

class SetThemeModeEvent extends ThemeEvent {
  final AppThemeMode mode;

  const SetThemeModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetFontSizeEvent extends ThemeEvent {
  final FontSizeOption fontSize;

  const SetFontSizeEvent(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}
