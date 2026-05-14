import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/language/language_cubit.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/dev_login_credentials.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../models/auth_models.dart';
import '../../services/auth_role_resolver.dart';

TextStyle _iosTextStyle({
  Color? color,
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  double letterSpacing = 0,
  double? height,
  List<Shadow>? shadows,
}) {
  return GoogleFonts.inter(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    shadows: shadows,
    fontFeatures: const [
      FontFeature.enable('ss01'),
      FontFeature.enable('cv11'),
    ],
  );
}

class LoginV2Screen extends StatefulWidget {
  const LoginV2Screen({super.key});

  @override
  State<LoginV2Screen> createState() => _LoginV2ScreenState();
}

class _LoginV2ScreenState extends State<LoginV2Screen>
    with TickerProviderStateMixin {
  static const _systemBlue = Color(0xFF007AFF);
  static const _systemBlueDark = Color(0xFF0A84FF);
  static const _systemGreen = Color(0xFF34C759);
  static const _systemRed = Color(0xFFFF3B30);
  static const _systemGray6 = Color(0xFFF2F2F7);
  static const _darkField = Color(0xFF1C1C1E);
  static const _lightLabel = Color(0xFF3C3C43);
  static const _darkLabel = Color(0xFFEBEBF5);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late final AnimationController _heroController;
  late final AnimationController _contentController;
  late final AnimationController _sheetController;

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _emailTouched = false;

  bool get _emailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool get _emailError {
    return _emailTouched &&
        !_emailFocusNode.hasFocus &&
        _emailController.text.trim().isNotEmpty &&
        !_emailValid;
  }

  bool get _canSubmit {
    return _emailValid && _passwordController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );

    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        _contentController.forward();
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        _sheetController.forward();
      }
    });

    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _emailTouched = true;
      }
      _refresh();
    });
    _passwordFocusNode.addListener(_refresh);
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _sheetController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleLogin() {
    _emailTouched = true;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      ),
    );
  }

  void _fillQuickLoginCredential(DevLoginCredential credential) {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailTouched = false;
      _emailController.text = credential.email;
      _passwordController.text = credential.password;
    });
  }

  Future<void> _showErrorDialog(String message) {
    final l = AppLocalizations.of(context);

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, _, __) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: isDark ? 0.86 : 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.12 : 0.7,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _systemRed.withValues(alpha: 0.2),
                            blurRadius: 32,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _systemRed,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l.error,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message,
                            style: TextStyle(
                              color: (isDark ? _darkLabel : _lightLabel)
                                  .withValues(alpha: 0.72),
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor: _systemBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                MaterialLocalizations.of(
                                  dialogContext,
                                ).okButtonLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.success),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          context.go(AuthRoleResolver.dashboardRouteForUser(state.user));
        } else if (state is AuthError) {
          _showErrorDialog(state.message);
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final overlayStyle = SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: isDark ? Colors.black : _systemGray6,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          );

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: Scaffold(
              backgroundColor: isDark ? Colors.black : _systemGray6,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final useDeviceFrame = constraints.maxWidth >= 600;
                  final frameWidth = math.min(430.0, constraints.maxWidth - 48);
                  final frameHeight = math.min(
                    860.0,
                    constraints.maxHeight - 48,
                  );
                  final content = _LoginV2Content(
                    isDark: isDark,
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocusNode: _emailFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    heroController: _heroController,
                    contentController: _contentController,
                    sheetController: _sheetController,
                    obscurePassword: _obscurePassword,
                    rememberMe: _rememberMe,
                    emailValid: _emailValid,
                    emailError: _emailError,
                    canSubmit: _canSubmit,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onToggleRemember: () {
                      setState(() => _rememberMe = !_rememberMe);
                    },
                    onQuickLoginSelected: _fillQuickLoginCredential,
                    onSubmit: _handleLogin,
                  );

                  if (!useDeviceFrame) {
                    return content;
                  }

                  return Center(
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : _systemGray6,
                        borderRadius: BorderRadius.circular(42),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.12 : 0.85,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 60,
                            offset: const Offset(0, 28),
                          ),
                        ],
                      ),
                      child: content,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginV2Content extends StatelessWidget {
  const _LoginV2Content({
    required this.isDark,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.heroController,
    required this.contentController,
    required this.sheetController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.emailValid,
    required this.emailError,
    required this.canSubmit,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onQuickLoginSelected,
    required this.onSubmit,
  });

  final bool isDark;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final AnimationController heroController;
  final AnimationController contentController;
  final AnimationController sheetController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool emailValid;
  final bool emailError;
  final bool canSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRemember;
  final ValueChanged<DevLoginCredential> onQuickLoginSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final l = AppLocalizations.of(context);
    final compactHero = media.size.height < 760;
    final heroTop = media.padding.top + (compactHero ? 28 : 38);

    return Container(
      color: isDark ? Colors.black : _LoginV2ScreenState._systemGray6,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(
                  height: media.size.height * 0.48,
                  width: double.infinity,
                  child: _HeroImage(isDark: isDark, controller: heroController),
                ),
                Expanded(
                  child: ColoredBox(
                    color: isDark
                        ? Colors.black
                        : _LoginV2ScreenState._systemGray6,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: media.padding.top + 8,
            end: 16,
            child: _TopControls(isDark: isDark),
          ),
          PositionedDirectional(
            start: 28,
            end: 28,
            top: heroTop,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: contentController,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: contentController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _GlassAppIcon(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.appTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _iosTextStyle(
                              color: Colors.white,
                              fontSize: compactHero ? 28 : 31,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                              height: 1.02,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.loginHeroSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _iosTextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontSize: compactHero ? 13 : 14,
                              letterSpacing: -0.12,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.26),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.6),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: sheetController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: _BottomSheetPanel(
                isDark: isDark,
                formKey: formKey,
                emailController: emailController,
                passwordController: passwordController,
                emailFocusNode: emailFocusNode,
                passwordFocusNode: passwordFocusNode,
                obscurePassword: obscurePassword,
                rememberMe: rememberMe,
                emailValid: emailValid,
                emailError: emailError,
                canSubmit: canSubmit,
                onTogglePassword: onTogglePassword,
                onToggleRemember: onToggleRemember,
                onQuickLoginSelected: onQuickLoginSelected,
                onSubmit: onSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.isDark, required this.controller});

  final bool isDark;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.15, end: 1).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
          child: Image.asset(
            'assets/images/login_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x66007AFF), Color(0x4D5856D6), Color(0x4DAF52DE)],
            ),
            backgroundBlendMode: BlendMode.multiply,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.26),
                Colors.transparent,
                isDark ? Colors.black : _LoginV2ScreenState._systemGray6,
              ],
              stops: const [0, 0.56, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return _CircleMenuButton(
              isDark: isDark,
              tooltip: AppLocalizations.of(context).language,
              child: PopupMenuButton<String>(
                tooltip: AppLocalizations.of(context).language,
                onSelected: (langCode) {
                  context.read<LanguageCubit>().changeLanguage(langCode);
                },
                itemBuilder: (context) => [
                  _languageItem('en', 'English', locale.languageCode),
                  _languageItem('ar', 'العربية', locale.languageCode),
                ],
                child: const Icon(Icons.language_rounded, size: 20),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        _CircleMenuButton(
          isDark: isDark,
          tooltip: isDark
              ? AppLocalizations.of(context).lightMode
              : AppLocalizations.of(context).darkMode,
          child: IconButton(
            tooltip: isDark
                ? AppLocalizations.of(context).lightMode
                : AppLocalizations.of(context).darkMode,
            onPressed: () {
              context.read<ThemeBloc>().add(const ToggleThemeEvent());
            },
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _languageItem(
    String value,
    String label,
    String current,
  ) {
    final selected = current == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? _LoginV2ScreenState._systemBlue : null,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_rounded,
              color: _LoginV2ScreenState._systemBlue,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleMenuButton extends StatelessWidget {
  const _CircleMenuButton({
    required this.isDark,
    required this.tooltip,
    required this.child,
  });

  final bool isDark;
  final String tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark ? Colors.white : const Color(0xFF111827);
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDark ? 0.13 : 0.72),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconTheme(
          data: IconThemeData(color: foreground),
          child: DefaultTextStyle(
            style: TextStyle(color: foreground),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassAppIcon extends StatelessWidget {
  const _GlassAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 50,
            offset: const Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: const Center(
                child: Text(
                  'E',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetPanel extends StatelessWidget {
  const _BottomSheetPanel({
    required this.isDark,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.rememberMe,
    required this.emailValid,
    required this.emailError,
    required this.canSubmit,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onQuickLoginSelected,
    required this.onSubmit,
  });

  final bool isDark;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool rememberMe;
  final bool emailValid;
  final bool emailError;
  final bool canSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleRemember;
  final ValueChanged<DevLoginCredential> onQuickLoginSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final l = AppLocalizations.of(context);
    final loading = context.select<AuthBloc, bool>(
      (bloc) => bloc.state is AuthLoading,
    );
    final availableHeight = media.size.height - media.padding.top - 28;
    final double panelHeight = math
        .min(availableHeight, math.max(media.size.height * 0.66, 640))
        .toDouble();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: panelHeight,
        maxHeight: media.size.height - media.padding.top * 0.35,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : _LoginV2ScreenState._systemGray6)
                  .withValues(alpha: isDark ? 0.7 : 0.82),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 60,
                  offset: const Offset(0, -30),
                  spreadRadius: -20,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                math.max(20, media.padding.bottom + 12),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? _LoginV2ScreenState._darkLabel
                                      : _LoginV2ScreenState._lightLabel)
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l.loginTitle,
                      style: _iosTextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.loginSubtitle,
                      style: _iosTextStyle(
                        color:
                            (isDark
                                    ? _LoginV2ScreenState._darkLabel
                                    : _LoginV2ScreenState._lightLabel)
                                .withValues(alpha: 0.6),
                        fontSize: 15,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _GroupedFields(
                      isDark: isDark,
                      emailController: emailController,
                      passwordController: passwordController,
                      emailFocusNode: emailFocusNode,
                      passwordFocusNode: passwordFocusNode,
                      obscurePassword: obscurePassword,
                      emailValid: emailValid,
                      emailError: emailError,
                      onTogglePassword: onTogglePassword,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: emailError
                          ? Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 16,
                                top: 8,
                              ),
                              child: Text(
                                l.invalidEmail,
                                style: _iosTextStyle(
                                  color: _LoginV2ScreenState._systemRed,
                                  fontSize: 13,
                                  letterSpacing: -0.13,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 18),
                    _RememberForgotRow(
                      isDark: isDark,
                      rememberMe: rememberMe,
                      onToggleRemember: onToggleRemember,
                    ),
                    const SizedBox(height: 24),
                    _LoginButton(
                      isDark: isDark,
                      enabled: canSubmit && !loading,
                      loading: loading,
                      onPressed: onSubmit,
                    ),
                    const SizedBox(height: 22),
                    _ReferenceDivider(isDark: isDark),
                    const SizedBox(height: 18),
                    _OutlookButton(isDark: isDark),
                    const SizedBox(height: 22),
                    _QuickLoginMenu(
                      isDark: isDark,
                      onSelected: onQuickLoginSelected,
                    ),
                    const SizedBox(height: 22),
                    _RegisterLink(isDark: isDark),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedFields extends StatelessWidget {
  const _GroupedFields({
    required this.isDark,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.emailValid,
    required this.emailError,
    required this.onTogglePassword,
  });

  final bool isDark;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool emailValid;
  final bool emailError;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labelColor = isDark
        ? _LoginV2ScreenState._darkLabel
        : _LoginV2ScreenState._lightLabel;
    final activeColor = isDark
        ? _LoginV2ScreenState._systemBlueDark
        : _LoginV2ScreenState._systemBlue;
    final passwordControlColor =
        passwordFocusNode.hasFocus || passwordController.text.isNotEmpty
        ? activeColor
        : labelColor.withValues(alpha: 0.4);
    final fieldColor = isDark ? _LoginV2ScreenState._darkField : Colors.white;
    final separatorColor =
        (isDark ? const Color(0xFF545458) : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: isDark ? 0.4 : 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _IosTextField(
              fieldKey: const Key('login-v2-email-field'),
              isDark: isDark,
              controller: emailController,
              focusNode: emailFocusNode,
              hint: l.email,
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              showValidIndicator: emailValid && !emailError,
              showErrorIndicator: emailError,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return l.fieldRequired;
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                  return l.invalidEmail;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                passwordFocusNode.requestFocus();
              },
            ),
            Container(
              height: 1,
              margin: const EdgeInsetsDirectional.only(start: 44),
              color: separatorColor,
            ),
            _IosTextField(
              fieldKey: const Key('login-v2-password-field'),
              isDark: isDark,
              controller: passwordController,
              focusNode: passwordFocusNode,
              hint: l.password,
              icon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              suffix: IconButton(
                key: const Key('login-v2-password-toggle'),
                tooltip: l.password,
                onPressed: onTogglePassword,
                color: passwordControlColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 54,
                ),
                splashRadius: 22,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l.fieldRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IosTextField extends StatelessWidget {
  const _IosTextField({
    required this.fieldKey,
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showValidIndicator = false,
    this.showErrorIndicator = false,
    this.suffix,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showValidIndicator;
  final bool showErrorIndicator;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark
        ? _LoginV2ScreenState._darkLabel
        : _LoginV2ScreenState._lightLabel;
    final activeColor = isDark
        ? _LoginV2ScreenState._systemBlueDark
        : _LoginV2ScreenState._systemBlue;
    final iconColor = showErrorIndicator
        ? _LoginV2ScreenState._systemRed
        : focusNode.hasFocus || controller.text.isNotEmpty
        ? activeColor
        : labelColor.withValues(alpha: 0.4);

    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PositionedDirectional(
            start: 16,
            top: 0,
            bottom: 0,
            child: Center(child: Icon(icon, size: 18, color: iconColor)),
          ),
          TextFormField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: activeColor,
            textAlignVertical: TextAlignVertical.center,
            style: _iosTextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 17,
              letterSpacing: -0.34,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                44,
                15,
                44,
                15,
              ),
              hintText: hint,
              hintStyle: _iosTextStyle(
                color: labelColor.withValues(alpha: 0.4),
                fontSize: 17,
                letterSpacing: -0.34,
              ),
            ),
          ),
          if (suffix != null || showValidIndicator || showErrorIndicator)
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 44,
                child: Center(child: suffix ?? _validityIcon()),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _validityIcon() {
    if (showValidIndicator) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: _LoginV2ScreenState._systemGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
      );
    }
    if (showErrorIndicator) {
      return const Icon(
        Icons.error_outline_rounded,
        color: _LoginV2ScreenState._systemRed,
        size: 20,
      );
    }
    return null;
  }
}

class _RememberForgotRow extends StatelessWidget {
  const _RememberForgotRow({
    required this.isDark,
    required this.rememberMe,
    required this.onToggleRemember,
  });

  final bool isDark;
  final bool rememberMe;
  final VoidCallback onToggleRemember;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Flexible(
          child: InkWell(
            key: const Key('login-v2-remember-toggle'),
            borderRadius: BorderRadius.circular(18),
            onTap: onToggleRemember,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  toggled: rememberMe,
                  label: l.rememberMe,
                  child: _IosSwitch(value: rememberMe),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l.rememberMe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _iosTextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const Key('login-v2-forgot-button'),
              onPressed: () => context.push('/forgot-password'),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? _LoginV2ScreenState._systemBlueDark
                    : _LoginV2ScreenState._systemBlue,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: _iosTextStyle(fontSize: 15, letterSpacing: -0.15),
              ),
              child: Text(
                l.forgotPassword,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IosSwitch extends StatelessWidget {
  const _IosSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 51,
      height: 31,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value
            ? _LoginV2ScreenState._systemGreen
            : const Color(0x52787880),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        alignment: value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.isDark,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool isDark;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final background = enabled
        ? (isDark
              ? _LoginV2ScreenState._systemBlueDark
              : _LoginV2ScreenState._systemBlue)
        : (isDark
              ? _LoginV2ScreenState._systemBlueDark.withValues(alpha: 0.3)
              : _LoginV2ScreenState._systemBlue.withValues(alpha: 0.4));

    return SizedBox(
      height: 54,
      child: FilledButton(
        key: const Key('login-v2-submit-button'),
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          disabledBackgroundColor: background,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: loading
              ? const SizedBox(
                  key: Key('login-v2-loading-indicator'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l.loginButton,
                  key: const Key('login-v2-submit-text'),
                  style: _iosTextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.34,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ReferenceDivider extends StatelessWidget {
  const _ReferenceDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lineColor =
        (isDark ? const Color(0xFF545458) : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: isDark ? 0.4 : 0.12);
    final labelColor =
        (isDark
                ? _LoginV2ScreenState._darkLabel
                : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: 0.6);

    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            l.orContinueWith,
            style: _iosTextStyle(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}

class _OutlookButton extends StatelessWidget {
  const _OutlookButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final background = isDark ? _LoginV2ScreenState._darkField : Colors.white;
    final foreground = isDark ? Colors.white : Colors.black;

    return SizedBox(
      height: 54,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: const Key('login-v2-outlook-button'),
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    (isDark
                            ? const Color(0xFF545458)
                            : _LoginV2ScreenState._lightLabel)
                        .withValues(alpha: isDark ? 0.22 : 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _OutlookGlyph(),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l.signInWithOutlook,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _iosTextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlookGlyph extends StatelessWidget {
  const _OutlookGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 18),
      painter: _OutlookGlyphPainter(),
    );
  }
}

class _OutlookGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFF0078D4);
    final flapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final shadowPaint = Paint()..color = const Color(0xFF005A9E);

    final rect = RRect.fromRectAndRadius(
      Offset(size.width * 0.08, size.height * 0.08) &
          Size(size.width * 0.84, size.height * 0.84),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, bodyPaint);

    final sideRect = RRect.fromRectAndRadius(
      Offset(0, size.height * 0.22) &
          Size(size.width * 0.42, size.height * 0.62),
      const Radius.circular(4),
    );
    canvas.drawRRect(sideRect, shadowPaint);
    canvas.drawRRect(sideRect, bodyPaint..color = const Color(0xFF106EBE));

    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.32)
      ..lineTo(size.width * 0.5, size.height * 0.62)
      ..lineTo(size.width * 0.86, size.height * 0.32);
    canvas.drawPath(path, flapPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickLoginMenu extends StatelessWidget {
  const _QuickLoginMenu({required this.isDark, required this.onSelected});

  final bool isDark;
  final ValueChanged<DevLoginCredential> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final credentials = DevLoginCredentials.all;
    final accent = isDark
        ? _LoginV2ScreenState._systemBlueDark
        : _LoginV2ScreenState._systemBlue;
    final surface = isDark ? _LoginV2ScreenState._darkField : Colors.white;
    final borderColor =
        (isDark ? const Color(0xFF545458) : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: isDark ? 0.24 : 0.12);
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor =
        (isDark
                ? _LoginV2ScreenState._darkLabel
                : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: 0.62);

    if (credentials.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<DevLoginCredential>(
      key: const Key('login-v2-quick-login-menu'),
      tooltip: l.quickLoginDev,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      elevation: 16,
      color: surface,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => credentials
          .map(
            (credential) => PopupMenuItem<DevLoginCredential>(
              value: credential,
              height: 70,
              child: _QuickLoginMenuItem(
                credential: credential,
                isDark: isDark,
                accent: _roleAccent(credential.roleKey, isDark),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 64,
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.bolt_rounded, color: accent, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.quickLoginDev,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _iosTextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.selectRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _iosTextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: secondaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Color _roleAccent(String roleKey, bool isDark) {
    return switch (roleKey) {
      'student' => isDark ? const Color(0xFF64D2FF) : const Color(0xFF007AFF),
      'instructor' =>
        isDark ? const Color(0xFF30D158) : const Color(0xFF10B981),
      'ta' => isDark ? const Color(0xFFFFD60A) : const Color(0xFFF59E0B),
      'admin' => isDark ? const Color(0xFFBF5AF2) : const Color(0xFF8B5CF6),
      _ =>
        isDark
            ? _LoginV2ScreenState._systemBlueDark
            : _LoginV2ScreenState._systemBlue,
    };
  }
}

class _QuickLoginMenuItem extends StatelessWidget {
  const _QuickLoginMenuItem({
    required this.credential,
    required this.isDark,
    required this.accent,
  });

  final DevLoginCredential credential;
  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor =
        (isDark
                ? _LoginV2ScreenState._darkLabel
                : _LoginV2ScreenState._lightLabel)
            .withValues(alpha: 0.62);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_roleIcon(credential.roleKey), color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                credential.labelFor(languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _iosTextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                credential.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _iosTextStyle(color: secondaryColor, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.login_rounded, color: accent, size: 18),
      ],
    );
  }

  IconData _roleIcon(String roleKey) {
    return switch (roleKey) {
      'student' => Icons.school_rounded,
      'instructor' => Icons.person_rounded,
      'ta' => Icons.assignment_ind_rounded,
      'admin' => Icons.admin_panel_settings_rounded,
      _ => Icons.person_rounded,
    };
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = isDark
        ? _LoginV2ScreenState._systemBlueDark
        : _LoginV2ScreenState._systemBlue;

    return Center(
      child: TextButton(
        key: const Key('login-v2-register-button'),
        onPressed: () => context.push('/register'),
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: _iosTextStyle(fontSize: 15, letterSpacing: -0.15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${l.dontHaveAccount} ${l.signUp}',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
