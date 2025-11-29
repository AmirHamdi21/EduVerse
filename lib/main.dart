import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/config/app_router.dart';
import 'package:edu_verse/config/app_theme.dart';
import 'package:edu_verse/services/api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StorageService _storageService;
  late ThemeBloc _themeBloc;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _themeBloc = ThemeBloc(storageService: _storageService);
    _authBloc = AuthBloc(
      apiService: ApiService(),
      storageService: _storageService,
    );
    // Initialize theme from storage
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await _themeBloc.initTheme();
  }

  @override
  void dispose() {
    _themeBloc.close();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'EduVerse App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
