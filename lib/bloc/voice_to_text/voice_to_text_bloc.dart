import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../../models/voice_recording_model.dart';
import 'voice_to_text_event.dart';
import 'voice_to_text_state.dart';

class VoiceToTextBloc extends Bloc<VoiceToTextEvent, VoiceToTextState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Uuid _uuid = const Uuid();

  Timer? _recordingTimer;
  Timer? _waveformTimer;
  StreamSubscription<Duration>? _playbackPositionSubscription;
  StreamSubscription<Duration>? _playbackDurationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  static const String _storageKey = 'voice_recordings';

  VoiceToTextBloc() : super(const VoiceToTextState()) {
    on<InitializeVoiceToText>(_onInitialize);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<CancelRecording>(_onCancelRecording);
    on<UpdateTranscription>(_onUpdateTranscription);
    on<SaveRecording>(_onSaveRecording);
    on<LoadRecordings>(_onLoadRecordings);
    on<DeleteRecording>(_onDeleteRecording);
    on<PlayRecording>(_onPlayRecording);
    on<PausePlayback>(_onPausePlayback);
    on<ResumePlayback>(_onResumePlayback);
    on<StopPlayback>(_onStopPlayback);
    on<SeekPlayback>(_onSeekPlayback);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<UpdatePlaybackDuration>(_onUpdatePlaybackDuration);
    on<ToggleFavorite>(_onToggleFavorite);
    on<UpdateRecordingTitle>(_onUpdateRecordingTitle);
    on<EditTranscription>(_onEditTranscription);
    on<SearchRecordings>(_onSearchRecordings);
    on<FilterRecordings>(_onFilterRecordings);
    on<SortRecordings>(_onSortRecordings);
    on<UpdateRecordingDuration>(_onUpdateRecordingDuration);
    on<UpdateWaveformData>(_onUpdateWaveformData);
    on<GenerateSummary>(_onGenerateSummary);
    on<CopyTranscription>(_onCopyTranscription);
    on<ClearCurrentTranscription>(_onClearCurrentTranscription);
    on<ChangeLanguage>(_onChangeLanguage);

    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _playbackPositionSubscription = _audioPlayer.onPositionChanged.listen(
      (position) => add(UpdatePlaybackPosition(position)),
    );

    _playbackDurationSubscription = _audioPlayer.onDurationChanged.listen(
      (duration) => add(UpdatePlaybackDuration(duration)),
    );

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      playerState,
    ) {
      if (playerState == PlayerState.completed) {
        add(const StopPlayback());
      }
    });
  }

  void _onChangeLanguage(
    ChangeLanguage event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(state.copyWith(selectedLanguage: event.language));
  }

  Future<void> _onInitialize(
    InitializeVoiceToText event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Initialize speech recognition with options
      bool speechAvailable = false;
      try {
        speechAvailable = await _speech.initialize(
          onError: (error) {
            // Log but don't emit error for transient issues
            if (error.permanent) {
              add(UpdateTranscription(''));
            }
          },
          onStatus: (status) {
            // Handle status changes if needed
          },
          debugLogging: false,
        );
      } catch (e) {
        // Speech recognition not available, continue without it
        speechAvailable = false;
      }

      emit(
        state.copyWith(
          isInitialized: true,
          speechAvailable: speechAvailable,
          isLoading: false,
        ),
      );

      add(const LoadRecordings());
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to initialize: $e',
        ),
      );
    }
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      // Check microphone permission
      if (!await _audioRecorder.hasPermission()) {
        emit(state.copyWith(errorMessage: 'Microphone permission denied'));
        return;
      }

      // Get recording directory
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final audioPath =
          '${recordingsDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start audio recording with WAV format (most compatible)
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: audioPath,
      );

      // Start speech recognition (wrap in try-catch as it may fail on some devices)
      if (state.speechAvailable) {
        try {
          final localeId = state.selectedLanguage == 'ar' ? 'ar-SA' : 'en-US';
          await _speech.listen(
            onResult: (result) {
              add(UpdateTranscription(result.recognizedWords));
            },
            localeId: localeId,
            listenFor: const Duration(minutes: 30),
            pauseFor: const Duration(seconds: 3),
            listenOptions: stt.SpeechListenOptions(
              partialResults: true,
              cancelOnError: false,
              listenMode: stt.ListenMode.dictation,
              autoPunctuation: true,
            ),
          );
        } catch (e) {
          // Speech recognition failed to start, continue with audio recording only
        }
      }

      emit(
        state.copyWith(
          recordingStatus: RecordingStatus.recording,
          currentAudioPath: audioPath,
          recordingDuration: Duration.zero,
          currentTranscription: '',
          waveformData: [],
          clearErrorMessage: true,
        ),
      );

      // Start recording timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(
          UpdateRecordingDuration(
            state.recordingDuration + const Duration(seconds: 1),
          ),
        );
      });

      // Start waveform simulation
      _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final random = Random();
        final newWaveformData = List<double>.from(state.waveformData);
        newWaveformData.add(random.nextDouble() * 0.8 + 0.2);
        if (newWaveformData.length > 50) {
          newWaveformData.removeAt(0);
        }
        add(UpdateWaveformData(newWaveformData));
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to start recording: $e'));
    }
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      emit(state.copyWith(recordingStatus: RecordingStatus.processing));

      _recordingTimer?.cancel();
      _waveformTimer?.cancel();

      // Stop speech recognition
      await _speech.stop();

      // Stop audio recording
      await _audioRecorder.stop();

      // Auto-save the recording if we have an audio path
      if (state.currentAudioPath != null) {
        final recording = VoiceRecordingModel(
          id: _uuid.v4(),
          title: 'Recording ${DateTime.now().toString().substring(0, 16)}',
          transcription: state.currentTranscription,
          audioFilePath: state.currentAudioPath!,
          duration: state.recordingDuration,
          createdAt: DateTime.now(),
          tags: [],
          isFavorite: false,
        );

        final updatedRecordings = [recording, ...state.recordings];
        await _saveRecordingsToStorage(updatedRecordings);

        emit(
          state.copyWith(
            recordingStatus: RecordingStatus.idle,
            recordings: updatedRecordings,
            filteredRecordings: _applyFiltersAndSort(
              updatedRecordings,
              state.searchQuery,
              state.currentFilter,
              state.currentSort,
            ),
            currentTranscription: '',
            recordingDuration: Duration.zero,
            clearCurrentAudioPath: true,
            waveformData: [],
            successMessage: 'Recording saved successfully',
          ),
        );
      } else {
        emit(state.copyWith(recordingStatus: RecordingStatus.idle));
      }
    } catch (e) {
      emit(
        state.copyWith(
          recordingStatus: RecordingStatus.idle,
          errorMessage: 'Failed to stop recording: $e',
        ),
      );
    }
  }

  Future<void> _onPauseRecording(
    PauseRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      _recordingTimer?.cancel();
      _waveformTimer?.cancel();
      await _speech.stop();
      await _audioRecorder.pause();

      emit(state.copyWith(recordingStatus: RecordingStatus.paused));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pause recording: $e'));
    }
  }

  Future<void> _onResumeRecording(
    ResumeRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await _audioRecorder.resume();

      if (state.speechAvailable) {
        try {
          final localeId = state.selectedLanguage == 'ar' ? 'ar-SA' : 'en-US';
          await _speech.listen(
            onResult: (result) {
              add(
                UpdateTranscription(
                  state.currentTranscription.isNotEmpty
                      ? '${state.currentTranscription} ${result.recognizedWords}'
                      : result.recognizedWords,
                ),
              );
            },
            localeId: localeId,
            listenFor: const Duration(minutes: 30),
            pauseFor: const Duration(seconds: 3),
            listenOptions: stt.SpeechListenOptions(
              partialResults: true,
              cancelOnError: false,
              listenMode: stt.ListenMode.dictation,
              autoPunctuation: true,
            ),
          );
        } catch (e) {
          // Speech recognition failed to start, continue with audio recording only
        }
      }

      emit(state.copyWith(recordingStatus: RecordingStatus.recording));

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(
          UpdateRecordingDuration(
            state.recordingDuration + const Duration(seconds: 1),
          ),
        );
      });

      _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final random = Random();
        final newWaveformData = List<double>.from(state.waveformData);
        newWaveformData.add(random.nextDouble() * 0.8 + 0.2);
        if (newWaveformData.length > 50) {
          newWaveformData.removeAt(0);
        }
        add(UpdateWaveformData(newWaveformData));
      });
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to resume recording: $e'));
    }
  }

  Future<void> _onCancelRecording(
    CancelRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      _recordingTimer?.cancel();
      _waveformTimer?.cancel();

      await _speech.stop();
      await _audioRecorder.stop();

      // Delete the audio file if it exists
      if (state.currentAudioPath != null) {
        final file = File(state.currentAudioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      emit(
        state.copyWith(
          recordingStatus: RecordingStatus.idle,
          currentTranscription: '',
          recordingDuration: Duration.zero,
          waveformData: [],
          clearCurrentAudioPath: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to cancel recording: $e'));
    }
  }

  void _onUpdateTranscription(
    UpdateTranscription event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(state.copyWith(currentTranscription: event.transcription));
  }

  Future<void> _onSaveRecording(
    SaveRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    if (state.currentAudioPath == null || state.currentTranscription.isEmpty) {
      emit(state.copyWith(errorMessage: 'Nothing to save'));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true));

      final recording = VoiceRecordingModel(
        id: _uuid.v4(),
        title: event.title.isNotEmpty
            ? event.title
            : 'Recording ${DateTime.now().toString().substring(0, 16)}',
        transcription: state.currentTranscription,
        audioFilePath: state.currentAudioPath!,
        duration: state.recordingDuration,
        createdAt: DateTime.now(),
        tags: event.tags,
      );

      final updatedRecordings = [recording, ...state.recordings];
      await _saveRecordingsToStorage(updatedRecordings);

      emit(
        state.copyWith(
          recordings: updatedRecordings,
          filteredRecordings: _applyFiltersAndSort(
            updatedRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
          isSaving: false,
          currentTranscription: '',
          recordingDuration: Duration.zero,
          waveformData: [],
          clearCurrentAudioPath: true,
          successMessage: 'Recording saved successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save recording: $e',
        ),
      );
    }
  }

  Future<void> _onLoadRecordings(
    LoadRecordings event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      final recordingsJson = prefs.getStringList(_storageKey) ?? [];

      final recordings = recordingsJson
          .map((json) => VoiceRecordingModel.fromJson(jsonDecode(json)))
          .toList();

      // Verify audio files exist
      final validRecordings = <VoiceRecordingModel>[];
      for (final recording in recordings) {
        final file = File(recording.audioFilePath);
        if (await file.exists()) {
          validRecordings.add(recording);
        }
      }

      emit(
        state.copyWith(
          recordings: validRecordings,
          filteredRecordings: _applyFiltersAndSort(
            validRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load recordings: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteRecording(
    DeleteRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      final recording = state.recordings.where(
        (r) => r.id == event.recordingId,
      ).firstOrNull;

      if (recording == null) {
        emit(state.copyWith(errorMessage: 'Recording not found'));
        return;
      }

      // Delete audio file
      final file = File(recording.audioFilePath);
      if (await file.exists()) {
        await file.delete();
      }

      final updatedRecordings = state.recordings
          .where((r) => r.id != event.recordingId)
          .toList();
      await _saveRecordingsToStorage(updatedRecordings);

      emit(
        state.copyWith(
          recordings: updatedRecordings,
          filteredRecordings: _applyFiltersAndSort(
            updatedRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
          successMessage: 'Recording deleted',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete recording: $e'));
    }
  }

  Future<void> _onPlayRecording(
    PlayRecording event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      // Stop current playback if any
      await _audioPlayer.stop();

      final file = File(event.recording.audioFilePath);
      if (!await file.exists()) {
        emit(state.copyWith(errorMessage: 'Audio file not found'));
        return;
      }

      await _audioPlayer.play(DeviceFileSource(event.recording.audioFilePath));

      emit(
        state.copyWith(
          playbackStatus: PlaybackStatus.playing,
          currentPlayingRecording: event.recording,
          playbackPosition: Duration.zero,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to play recording: $e'));
    }
  }

  Future<void> _onPausePlayback(
    PausePlayback event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await _audioPlayer.pause();
      emit(state.copyWith(playbackStatus: PlaybackStatus.paused));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pause playback: $e'));
    }
  }

  Future<void> _onResumePlayback(
    ResumePlayback event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await _audioPlayer.resume();
      emit(state.copyWith(playbackStatus: PlaybackStatus.playing));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to resume playback: $e'));
    }
  }

  Future<void> _onStopPlayback(
    StopPlayback event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await _audioPlayer.stop();
      emit(
        state.copyWith(
          playbackStatus: PlaybackStatus.stopped,
          playbackPosition: Duration.zero,
          clearCurrentPlayingRecording: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to stop playback: $e'));
    }
  }

  Future<void> _onSeekPlayback(
    SeekPlayback event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await _audioPlayer.seek(event.position);
      emit(state.copyWith(playbackPosition: event.position));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to seek: $e'));
    }
  }

  void _onUpdatePlaybackPosition(
    UpdatePlaybackPosition event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(state.copyWith(playbackPosition: event.position));
  }

  void _onUpdatePlaybackDuration(
    UpdatePlaybackDuration event,
    Emitter<VoiceToTextState> emit,
  ) {
    if (state.playbackDuration != event.duration) {
      emit(state.copyWith(playbackDuration: event.duration));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      final updatedRecordings = state.recordings.map((r) {
        if (r.id == event.recordingId) {
          return r.copyWith(isFavorite: !r.isFavorite);
        }
        return r;
      }).toList();

      await _saveRecordingsToStorage(updatedRecordings);

      emit(
        state.copyWith(
          recordings: updatedRecordings,
          filteredRecordings: _applyFiltersAndSort(
            updatedRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update favorite: $e'));
    }
  }

  Future<void> _onUpdateRecordingTitle(
    UpdateRecordingTitle event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      final updatedRecordings = state.recordings.map((r) {
        if (r.id == event.recordingId) {
          return r.copyWith(title: event.newTitle, updatedAt: DateTime.now());
        }
        return r;
      }).toList();

      await _saveRecordingsToStorage(updatedRecordings);

      emit(
        state.copyWith(
          recordings: updatedRecordings,
          filteredRecordings: _applyFiltersAndSort(
            updatedRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
          successMessage: 'Title updated',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update title: $e'));
    }
  }

  Future<void> _onEditTranscription(
    EditTranscription event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      final updatedRecordings = state.recordings.map((r) {
        if (r.id == event.recordingId) {
          return r.copyWith(
            transcription: event.newTranscription,
            updatedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();

      await _saveRecordingsToStorage(updatedRecordings);

      emit(
        state.copyWith(
          recordings: updatedRecordings,
          filteredRecordings: _applyFiltersAndSort(
            updatedRecordings,
            state.searchQuery,
            state.currentFilter,
            state.currentSort,
          ),
          successMessage: 'Transcription updated',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update transcription: $e'));
    }
  }

  void _onSearchRecordings(
    SearchRecordings event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredRecordings: _applyFiltersAndSort(
          state.recordings,
          event.query,
          state.currentFilter,
          state.currentSort,
        ),
      ),
    );
  }

  void _onFilterRecordings(
    FilterRecordings event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(
      state.copyWith(
        currentFilter: event.filter,
        filteredRecordings: _applyFiltersAndSort(
          state.recordings,
          state.searchQuery,
          event.filter,
          state.currentSort,
        ),
      ),
    );
  }

  void _onSortRecordings(SortRecordings event, Emitter<VoiceToTextState> emit) {
    emit(
      state.copyWith(
        currentSort: event.sort,
        filteredRecordings: _applyFiltersAndSort(
          state.recordings,
          state.searchQuery,
          state.currentFilter,
          event.sort,
        ),
      ),
    );
  }

  void _onUpdateRecordingDuration(
    UpdateRecordingDuration event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(state.copyWith(recordingDuration: event.duration));
  }

  void _onUpdateWaveformData(
    UpdateWaveformData event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(state.copyWith(waveformData: event.waveformData));
  }

  Future<void> _onGenerateSummary(
    GenerateSummary event,
    Emitter<VoiceToTextState> emit,
  ) async {
    // TODO: Implement AI summary generation
    emit(state.copyWith(successMessage: 'Summary feature coming soon!'));
  }

  Future<void> _onCopyTranscription(
    CopyTranscription event,
    Emitter<VoiceToTextState> emit,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: event.transcription));
      emit(state.copyWith(successMessage: 'Copied to clipboard'));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to copy: $e'));
    }
  }

  void _onClearCurrentTranscription(
    ClearCurrentTranscription event,
    Emitter<VoiceToTextState> emit,
  ) {
    emit(
      state.copyWith(
        currentTranscription: '',
        recordingDuration: Duration.zero,
        waveformData: [],
        clearCurrentAudioPath: true,
      ),
    );
  }

  List<VoiceRecordingModel> _applyFiltersAndSort(
    List<VoiceRecordingModel> recordings,
    String searchQuery,
    RecordingFilter filter,
    RecordingSort sort,
  ) {
    var filtered = List<VoiceRecordingModel>.from(recordings);

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(query) ||
            r.transcription.toLowerCase().contains(query) ||
            r.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    // Apply filter
    final now = DateTime.now();
    switch (filter) {
      case RecordingFilter.favorites:
        filtered = filtered.where((r) => r.isFavorite).toList();
        break;
      case RecordingFilter.today:
        filtered = filtered.where((r) {
          return r.createdAt.year == now.year &&
              r.createdAt.month == now.month &&
              r.createdAt.day == now.day;
        }).toList();
        break;
      case RecordingFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((r) => r.createdAt.isAfter(weekAgo)).toList();
        break;
      case RecordingFilter.thisMonth:
        filtered = filtered.where((r) {
          return r.createdAt.year == now.year && r.createdAt.month == now.month;
        }).toList();
        break;
      case RecordingFilter.all:
        break;
    }

    // Apply sort
    switch (sort) {
      case RecordingSort.dateNewest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case RecordingSort.dateOldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case RecordingSort.durationLongest:
        filtered.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case RecordingSort.durationShortest:
        filtered.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case RecordingSort.alphabetical:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  }

  Future<void> _saveRecordingsToStorage(
    List<VoiceRecordingModel> recordings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final recordingsJson = recordings
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, recordingsJson);
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _waveformTimer?.cancel();
    _playbackPositionSubscription?.cancel();
    _playbackDurationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    return super.close();
  }
}
