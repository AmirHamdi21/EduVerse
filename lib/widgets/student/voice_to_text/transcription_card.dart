import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_event.dart';
import '../../../bloc/voice_to_text/voice_to_text_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class TranscriptionCard extends StatefulWidget {
  const TranscriptionCard({super.key});

  @override
  State<TranscriptionCard> createState() => _TranscriptionCardState();
}

class _TranscriptionCardState extends State<TranscriptionCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _transcriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<VoiceToTextBloc, VoiceToTextState>(
          builder: (context, state) {
            if (state.currentTranscription.isEmpty &&
                !state.isRecording &&
                !state.isPaused) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF101828).withOpacity(0.9)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E2939).withOpacity(0.5)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF155DFC), Color(0xFF0092B8)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.text_snippet_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.voiceToTextTranscription,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF3F4F6)
                                    : const Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                        _buildActionButtons(context, state, isDark, l10n),
                      ],
                    ),
                  ),

                  // Transcription Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing)
                          TextField(
                            controller: _transcriptionController
                              ..text = state.currentTranscription,
                            maxLines: null,
                            minLines: 5,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: isDark
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFF101828),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF1E2939)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF155DFC),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0A0A0A)
                                  : const Color(0xFFF8FAFC),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0A0A0A).withOpacity(0.5)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E2939)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 150,
                              maxHeight: 300,
                            ),
                            child: SingleChildScrollView(
                              child: state.currentTranscription.isEmpty
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (state.isRecording)
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation(
                                                isDark
                                                    ? const Color(0xFF51A2FF)
                                                    : const Color(0xFF155DFC),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            state.isRecording
                                                ? (state.speechAvailable
                                                    ? l10n.voiceToTextListening
                                                    : 'Recording audio only...')
                                                : l10n.voiceToTextStartSpeaking,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDark
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFF94A3B8),
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SelectableText(
                                      state.currentTranscription,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: isDark
                                            ? const Color(0xFFF3F4F6)
                                            : const Color(0xFF101828),
                                      ),
                                    ),
                            ),
                          ),

                        // Word Count
                        if (state.currentTranscription.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${state.currentTranscription.split(' ').where((w) => w.isNotEmpty).length} ${l10n.voiceToTextWords}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  '${state.currentTranscription.length} ${l10n.voiceToTextCharacters}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Save Section
                  if (state.currentTranscription.isNotEmpty &&
                      !state.isRecording &&
                      !state.isPaused)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2939).withOpacity(0.3)
                            : const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.voiceToTextSaveRecording,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: l10n.voiceToTextEnterTitle,
                              hintStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0A0A0A)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF1E2939)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF1E2939)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF155DFC),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<VoiceToTextBloc>()
                                        .add(const ClearCurrentTranscription());
                                    _titleController.clear();
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  label: Text(l10n.voiceToTextDiscard),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF155DFC), Color(0xFF0092B8)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF155DFC).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: state.isSaving
                                        ? null
                                        : () {
                                            context.read<VoiceToTextBloc>().add(
                                                  SaveRecording(
                                                    title: _titleController.text,
                                                  ),
                                                );
                                            _titleController.clear();
                                          },
                                    icon: state.isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.save_rounded),
                                    label: Text(
                                      state.isSaving
                                          ? l10n.voiceToTextSaving
                                          : l10n.voiceToTextSave,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    VoiceToTextState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        // Copy Button
        if (state.currentTranscription.isNotEmpty)
          _buildIconButton(
            icon: Icons.copy_rounded,
            tooltip: l10n.voiceToTextCopy,
            color: const Color(0xFF155DFC),
            isDark: isDark,
            onTap: () {
              context.read<VoiceToTextBloc>().add(
                    CopyTranscription(state.currentTranscription),
                  );
            },
          ),

        // Edit Button
        if (state.currentTranscription.isNotEmpty)
          _buildIconButton(
            icon: _isEditing ? Icons.check_rounded : Icons.edit_rounded,
            tooltip: _isEditing ? l10n.save : l10n.edit,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: () {
              if (_isEditing) {
                context.read<VoiceToTextBloc>().add(
                      UpdateTranscription(_transcriptionController.text),
                    );
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),

        // Summarize Button (AI)
        if (state.currentTranscription.isNotEmpty &&
            !state.isRecording &&
            !state.isPaused)
          _buildIconButton(
            icon: Icons.auto_awesome_rounded,
            tooltip: l10n.voiceToTextSummarize,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () {
              // TODO: Implement AI summarization
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.voiceToTextSummarizeComingSoon),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
