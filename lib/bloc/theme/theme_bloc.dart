import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final StorageService _storageService;

  ThemeBloc({required StorageService storageService})
    : _storageService = storageService,
      super(ThemeInitial(isDark: false)) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDark = !state.isDark;
    await _storageService.setDarkMode(newIsDark);
    emit(ThemeChanged(isDark: newIsDark));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _storageService.setDarkMode(event.isDark);
    emit(ThemeChanged(isDark: event.isDark));
  }

  Future<void> initTheme() async {
    final isDark = await _storageService.getDarkMode();
    emit(ThemeInitial(isDark: isDark));
  }
}
