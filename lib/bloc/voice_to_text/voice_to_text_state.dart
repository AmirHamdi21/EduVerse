import 'package:equatable/equatable.dart';
import '../../models/voice_recording_model.dart';
import 'voice_to_text_event.dart';

enum RecordingStatus {
  idle,
  recording,
  paused,
  processing,
}

enum PlaybackStatus {
  stopped,
  playing,
  paused,
}

class VoiceToTextState extends Equatable {
  final bool isInitialized;
  final bool speechAvailable;
  final RecordingStatus recordingStatus;
  final PlaybackStatus playbackStatus;
  final String currentTranscription;
  final Duration recordingDuration;
  final Duration playbackPosition;
  final Duration playbackDuration;
  final List<VoiceRecordingModel> recordings;
  final List<VoiceRecordingModel> filteredRecordings;
  final VoiceRecordingModel? currentPlayingRecording;
  final String? currentAudioPath;
  final List<double> waveformData;
  final String searchQuery;
  final RecordingFilter currentFilter;
  final RecordingSort currentSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditing;
  final String selectedLanguage;

  const VoiceToTextState({
    this.isInitialized = false,
    this.speechAvailable = false,
    this.recordingStatus = RecordingStatus.idle,
    this.playbackStatus = PlaybackStatus.stopped,
    this.currentTranscription = '',
    this.recordingDuration = Duration.zero,
    this.playbackPosition = Duration.zero,
    this.playbackDuration = Duration.zero,
    this.recordings = const [],
    this.filteredRecordings = const [],
    this.currentPlayingRecording,
    this.currentAudioPath,
    this.waveformData = const [],
    this.searchQuery = '',
    this.currentFilter = RecordingFilter.all,
    this.currentSort = RecordingSort.dateNewest,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
    this.selectedLanguage = 'en',
  });

  bool get isRecording => recordingStatus == RecordingStatus.recording;
  bool get isPaused => recordingStatus == RecordingStatus.paused;
  bool get isProcessing => recordingStatus == RecordingStatus.processing;
  bool get isPlaying => playbackStatus == PlaybackStatus.playing;
  bool get isPlaybackPaused => playbackStatus == PlaybackStatus.paused;
  bool get hasTranscription => currentTranscription.isNotEmpty;
  bool get hasRecordings => recordings.isNotEmpty;

  String get formattedRecordingDuration {
    final minutes = recordingDuration.inMinutes;
    final seconds = recordingDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlaybackPosition {
    final minutes = playbackPosition.inMinutes;
    final seconds = playbackPosition.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlaybackDuration {
    final minutes = playbackDuration.inMinutes;
    final seconds = playbackDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get playbackProgress {
    if (playbackDuration.inMilliseconds == 0) return 0;
    return playbackPosition.inMilliseconds / playbackDuration.inMilliseconds;
  }

  VoiceToTextState copyWith({
    bool? isInitialized,
    bool? speechAvailable,
    RecordingStatus? recordingStatus,
    PlaybackStatus? playbackStatus,
    String? currentTranscription,
    Duration? recordingDuration,
    Duration? playbackPosition,
    Duration? playbackDuration,
    List<VoiceRecordingModel>? recordings,
    List<VoiceRecordingModel>? filteredRecordings,
    VoiceRecordingModel? currentPlayingRecording,
    bool clearCurrentPlayingRecording = false,
    String? currentAudioPath,
    bool clearCurrentAudioPath = false,
    List<double>? waveformData,
    String? searchQuery,
    RecordingFilter? currentFilter,
    RecordingSort? currentSort,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? isEditing,
    String? selectedLanguage,
  }) {
    return VoiceToTextState(
      isInitialized: isInitialized ?? this.isInitialized,
      speechAvailable: speechAvailable ?? this.speechAvailable,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      playbackStatus: playbackStatus ?? this.playbackStatus,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      playbackDuration: playbackDuration ?? this.playbackDuration,
      recordings: recordings ?? this.recordings,
      filteredRecordings: filteredRecordings ?? this.filteredRecordings,
      currentPlayingRecording: clearCurrentPlayingRecording
          ? null
          : currentPlayingRecording ?? this.currentPlayingRecording,
      currentAudioPath: clearCurrentAudioPath
          ? null
          : currentAudioPath ?? this.currentAudioPath,
      waveformData: waveformData ?? this.waveformData,
      searchQuery: searchQuery ?? this.searchQuery,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
      isEditing: isEditing ?? this.isEditing,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  @override
  List<Object?> get props => [
        isInitialized,
        speechAvailable,
        recordingStatus,
        playbackStatus,
        currentTranscription,
        recordingDuration,
        playbackPosition,
        playbackDuration,
        recordings,
        filteredRecordings,
        currentPlayingRecording,
        currentAudioPath,
        waveformData,
        searchQuery,
        currentFilter,
        currentSort,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        isEditing,
        selectedLanguage,
      ];
}
