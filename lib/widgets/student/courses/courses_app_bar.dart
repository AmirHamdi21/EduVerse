import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class CoursesAppBar extends StatelessWidget {
  const CoursesAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return SliverAppBar(
          floating: true,
          backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
          elevation: 0.5,
          toolbarHeight: 80,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                iosBackIcon(context),
                color: isDark ? Colors.white : const Color(0xFF101727),
              ),
              onPressed: () => safeBack(context, '/dashboard'),
            ),
          ),
          title: Text(
            l10n.myCoursesHeader,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101727),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
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
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : const Color(0xFF101727),
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
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
          ],
        );
      },
    );
  }
}
