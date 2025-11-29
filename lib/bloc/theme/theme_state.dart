import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  final bool isDark;

  const ThemeState({required this.isDark});

  @override
  List<Object?> get props => [isDark];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial({required super.isDark});
}

class ThemeChanged extends ThemeState {
  const ThemeChanged({required super.isDark});
}
