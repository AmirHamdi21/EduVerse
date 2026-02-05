import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerGenerateButton extends StatefulWidget {
  final bool isDark;

  const SummarizerGenerateButton({
    super.key,
    required this.isDark,
  });

  @override
  State<SummarizerGenerateButton> createState() =>
      _SummarizerGenerateButtonState();
}

class _SummarizerGenerateButtonState extends State<SummarizerGenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<SummarizerCubit, SummarizerState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == SummaryStatus.processing) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }

          if (state.status == SummaryStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            previous.canGenerate != current.canGenerate ||
            previous.status != current.status,
        builder: (context, state) {
          final isProcessing = state.status == SummaryStatus.processing;
          final canGenerate = state.canGenerate;

          return ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: canGenerate || isProcessing
                      ? [const Color(0xFF2B7FFF), const Color(0xFF1447E6)]
                      : [const Color(0xFF64748B), const Color(0xFF475569)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canGenerate || isProcessing
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2B7FFF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canGenerate && !isProcessing
                      ? () => context.read<SummarizerCubit>().generateSummary()
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: isProcessing
                        ? _buildProcessingContent(l10n)
                        : _buildNormalContent(l10n),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNormalContent(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          l10n.summarizerGenerate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingContent(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.summarizerGenerating,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
