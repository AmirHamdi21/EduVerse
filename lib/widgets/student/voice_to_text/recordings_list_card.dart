import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_bloc.dart';
import '../../../bloc/voice_to_text/voice_to_text_event.dart';
import '../../../bloc/voice_to_text/voice_to_text_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../models/voice_recording_model.dart';
import '../../../generated_l10n/app_localizations.dart';

class RecordingsListCard extends StatelessWidget {
  const RecordingsListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return BlocBuilder<VoiceToTextBloc, VoiceToTextState>(
          builder: (context, state) {
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
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFDBEAFE),
                                    const Color(0xFFCEFAFE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: const Color(0xFF155DFC),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.voiceToTextRecentRecordings,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF162456).withOpacity(0.3)
                                : const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF193CB8)
                                  : const Color(0xFFBEDBFF),
                            ),
                          ),
                          child: Text(
                            '${state.filteredRecordings.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF51A2FF)
                                  : const Color(0xFF1447E6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter & Sort Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFilterDropdown(
                            context,
                            state,
                            isDark,
                            l10n,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildSortButton(context, state, isDark, l10n),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recordings List
                  if (state.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.filteredRecordings.isEmpty)
                    _buildEmptyState(isDark, l10n)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: state.filteredRecordings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recording = state.filteredRecordings[index];
                        return _RecordingItem(
                          recording: recording,
                          isPlaying:
                              state.currentPlayingRecording?.id == recording.id,
                          playbackStatus: state.playbackStatus,
                          playbackProgress:
                              state.currentPlayingRecording?.id == recording.id
                              ? state.playbackProgress
                              : 0,
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    VoiceToTextState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2939).withOpacity(0.5)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RecordingFilter>(
          value: state.currentFilter,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF101828),
          ),
          dropdownColor: isDark ? const Color(0xFF1E2939) : Colors.white,
          items: RecordingFilter.values.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(_getFilterLabel(filter, l10n)),
            );
          }).toList(),
          onChanged: (filter) {
            if (filter != null) {
              context.read<VoiceToTextBloc>().add(FilterRecordings(filter));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortButton(
    BuildContext context,
    VoiceToTextState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return PopupMenuButton<RecordingSort>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2939).withOpacity(0.5)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          Icons.sort_rounded,
          size: 20,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
      color: isDark ? const Color(0xFF1E2939) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => RecordingSort.values.map((sort) {
        return PopupMenuItem(
          value: sort,
          child: Row(
            children: [
              if (state.currentSort == sort)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Color(0xFF155DFC),
                ),
              if (state.currentSort == sort) const SizedBox(width: 8),
              Text(
                _getSortLabel(sort, l10n),
                style: TextStyle(
                  color: state.currentSort == sort
                      ? const Color(0xFF155DFC)
                      : (isDark ? Colors.white : const Color(0xFF101828)),
                  fontWeight: state.currentSort == sort
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (sort) {
        context.read<VoiceToTextBloc>().add(SortRecordings(sort));
      },
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2939).withOpacity(0.5)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_none_rounded,
              size: 48,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.voiceToTextNoRecordings,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.voiceToTextNoRecordingsDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(RecordingFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case RecordingFilter.all:
        return l10n.all;
      case RecordingFilter.favorites:
        return l10n.voiceToTextFavorites;
      case RecordingFilter.today:
        return l10n.today;
      case RecordingFilter.thisWeek:
        return l10n.thisWeek;
      case RecordingFilter.thisMonth:
        return l10n.voiceToTextThisMonth;
    }
  }

  String _getSortLabel(RecordingSort sort, AppLocalizations l10n) {
    switch (sort) {
      case RecordingSort.dateNewest:
        return l10n.voiceToTextNewest;
      case RecordingSort.dateOldest:
        return l10n.voiceToTextOldest;
      case RecordingSort.durationLongest:
        return l10n.voiceToTextLongest;
      case RecordingSort.durationShortest:
        return l10n.voiceToTextShortest;
      case RecordingSort.alphabetical:
        return l10n.voiceToTextAlphabetical;
    }
  }
}

class _RecordingItem extends StatelessWidget {
  final VoiceRecordingModel recording;
  final bool isPlaying;
  final PlaybackStatus playbackStatus;
  final double playbackProgress;

  const _RecordingItem({
    required this.recording,
    required this.isPlaying,
    required this.playbackStatus,
    required this.playbackProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF101828).withOpacity(0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPlaying
                  ? const Color(0xFF155DFC).withOpacity(0.5)
                  : (isDark
                        ? const Color(0xFF1E2939)
                        : const Color(0xFFE5E7EB)),
              width: isPlaying ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? const Color(0xFF155DFC).withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Play Button / Icon
                    GestureDetector(
                      onTap: () {
                        final bloc = context.read<VoiceToTextBloc>();
                        if (isPlaying) {
                          if (playbackStatus == PlaybackStatus.playing) {
                            bloc.add(const PausePlayback());
                          } else {
                            bloc.add(const ResumePlayback());
                          }
                        } else {
                          bloc.add(PlayRecording(recording));
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPlaying
                                ? [
                                    const Color(0xFF155DFC),
                                    const Color(0xFF0092B8),
                                  ]
                                : [
                                    const Color(0xFFDBEAFE),
                                    const Color(0xFFCEFAFE),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isPlaying && playbackStatus == PlaybackStatus.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isPlaying
                              ? Colors.white
                              : const Color(0xFF155DFC),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recording.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFF3F4F6)
                                        : const Color(0xFF101828),
                                  ),
                                ),
                              ),
                              if (recording.isFavorite)
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recording.formattedDuration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recording.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions Menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      color: isDark ? const Color(0xFF1E2939) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                recording.isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 20,
                                color: const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                recording.isFavorite
                                    ? l10n.voiceToTextRemoveFavorite
                                    : l10n.voiceToTextAddFavorite,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 20,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF101828),
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.voiceToTextCopy),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        final bloc = context.read<VoiceToTextBloc>();
                        switch (value) {
                          case 'favorite':
                            bloc.add(ToggleFavorite(recording.id));
                            break;
                          case 'copy':
                            bloc.add(
                              CopyTranscription(recording.transcription),
                            );
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, recording, l10n);
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Playback Progress Bar
              if (isPlaying)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: playbackProgress,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2939)
                              : const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF155DFC),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Transcription Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0A0A0A).withOpacity(0.5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Text(
                  recording.transcription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    VoiceRecordingModel recording,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.voiceToTextDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<VoiceToTextBloc>().add(
                DeleteRecording(recording.id),
              );
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
