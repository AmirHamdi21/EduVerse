import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final StorageService _storageService;

  ThemeBloc({required StorageService storageService})
    : _storageService = storageService,
      super(ThemeInitial(isDark: false, themeMode: AppThemeMode.light, fontSize: FontSizeOption.medium)) {
    on<InitThemeEvent>(_onInitTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetFontSizeEvent>(_onSetFontSize);
  }

  Future<void> _onInitTheme(
    InitThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final isDark = await _storageService.getDarkMode();
    final fontSizeIndex = await _storageService.getFontSize();
    final fontSize = FontSizeOption.values[fontSizeIndex.clamp(0, 2)];
    emit(ThemeInitial(isDark: isDark, themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light, fontSize: fontSize));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDark = !state.isDark;
    await _storageService.setDarkMode(newIsDark);
    emit(ThemeChanged(isDark: newIsDark, themeMode: newIsDark ? AppThemeMode.dark : AppThemeMode.light, fontSize: state.fontSize));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _storageService.setDarkMode(event.isDark);
    emit(ThemeChanged(isDark: event.isDark, themeMode: event.isDark ? AppThemeMode.dark : AppThemeMode.light, fontSize: state.fontSize));
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    bool isDark;
    if (event.mode == AppThemeMode.system) {
      // Get system brightness
      final brightness = ui.PlatformDispatcher.instance.platformBrightness;
      isDark = brightness == ui.Brightness.dark;
    } else {
      isDark = event.mode == AppThemeMode.dark;
    }
    await _storageService.setDarkMode(isDark);
    emit(ThemeChanged(isDark: isDark, themeMode: event.mode, fontSize: state.fontSize));
  }

  Future<void> _onSetFontSize(
    SetFontSizeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _storageService.setFontSize(event.fontSize.index);
    emit(ThemeChanged(isDark: state.isDark, themeMode: state.themeMode, fontSize: event.fontSize));
  }

  Future<void> initTheme() async {
    add(const InitThemeEvent());
  }
}
