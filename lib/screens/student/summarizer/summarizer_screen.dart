import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/summarizer/summarizer_app_bar.dart';
import '../../../widgets/student/summarizer/summarizer_input_section.dart';
import '../../../widgets/student/summarizer/summarizer_type_selector.dart';
import '../../../widgets/student/summarizer/summarizer_generate_button.dart';
import '../../../widgets/student/summarizer/summarizer_result_section.dart';
import '../../../widgets/student/summarizer/summarizer_history_section.dart';
import '../../../widgets/student/summarizer/summarizer_upload_overlay.dart';

class SummarizerScreen extends StatefulWidget {
  const SummarizerScreen({super.key});

  @override
  State<SummarizerScreen> createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends State<SummarizerScreen>
    with SingleTickerProviderStateMixin {
  late SummarizerCubit _summarizerCubit;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _summarizerCubit = SummarizerCubit();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _summarizerCubit.close();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _summarizerCubit,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previous, current) => previous.isDark != current.isDark,
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0A0A0A)
                : const Color(0xFFF9FAFB),
            body: Stack(
              children: [
                // Background gradient
                _buildBackground(isDark),
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      SummarizerAppBar(isDark: isDark),
                      Expanded(child: _buildContent(isDark, l10n)),
                    ],
                  ),
                ),
                // Upload overlay
                const SummarizerUploadOverlay(),
              ],
            ),
            floatingActionButton: _buildFAB(isDark, l10n),
          );
        },
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A0A0A), const Color(0xFF030712)]
                : [const Color(0xFFF9FAFB), Colors.white],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return BlocBuilder<SummarizerCubit, SummarizerState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentSummary != current.currentSummary,
      builder: (context, state) {
        return CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Input section (file upload + text input)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _animationController,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: SummarizerInputSection(isDark: isDark),
                ),
              ),
            ),

            // Summarization type selector
            SliverToBoxAdapter(child: SummarizerTypeSelector(isDark: isDark)),

            // Generate button
            SliverToBoxAdapter(child: SummarizerGenerateButton(isDark: isDark)),

            // Result section (shows current summary or empty state)
            SliverToBoxAdapter(child: SummarizerResultSection(isDark: isDark)),

            // History section
            SliverToBoxAdapter(child: SummarizerHistorySection(isDark: isDark)),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return BlocBuilder<SummarizerCubit, SummarizerState>(
      buildWhen: (previous, current) =>
          previous.currentSummary != current.currentSummary,
      builder: (context, state) {
        if (state.currentSummary != null) {
          return FloatingActionButton(
            onPressed: () {
              _summarizerCubit.clearCurrentSummary();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            backgroundColor: const Color(0xFF3B82F6),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
