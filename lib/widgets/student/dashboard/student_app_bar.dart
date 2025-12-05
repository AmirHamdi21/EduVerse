import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';

class StudentAppBar extends StatelessWidget {
  const StudentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return SliverAppBar(
          floating: true,
          backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF101727),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF50A2FF), Color(0xFF155CFB)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.appTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101727),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.language,
                    color: isDark ? Colors.white : const Color(0xFF101727),
                  ),
                  onSelected: (String languageCode) {
                    context.read<LanguageCubit>().changeLanguage(languageCode);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'en',
                      child: Row(
                        children: [
                          Icon(
                            locale.languageCode == 'en'
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: locale.languageCode == 'en'
                                ? const Color(0xFF155CFB)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.english),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'ar',
                      child: Row(
                        children: [
                          Icon(
                            locale.languageCode == 'ar'
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: locale.languageCode == 'ar'
                                ? const Color(0xFF155CFB)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.arabic),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: isDark ? Colors.white : const Color(0xFF101727),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : const Color(0xFF101727),
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
