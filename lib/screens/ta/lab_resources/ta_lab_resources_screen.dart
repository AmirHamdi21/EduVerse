import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TALabResourcesScreen extends StatelessWidget {
  const TALabResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/lab-resources'),
          appBar: AppBar(
            backgroundColor: TAColors.cardColor(isDark),
            elevation: 0,
            title: Text(
              l10n.taLabResTitle,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: IconThemeData(color: TAColors.textPrimaryColor(isDark)),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                onPressed: () =>
                    context.read<ThemeBloc>().add(ToggleThemeEvent()),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TAColors.cardColor(isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TAColors.borderColor(
                        isDark,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: TAColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: TAColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'TA lab resources are not available as a standalone library yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The previous screen was a mock placeholder. Use the TA labs flow to manage real lab instructions and grading until an API-backed resources experience is added.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
