import 'package:equatable/equatable.dart';
import '../../models/voice_recording_model.dart';

abstract class VoiceToTextEvent extends Equatable {
  const VoiceToTextEvent();

  @override
  List<Object?> get props => [];
}

class InitializeVoiceToText extends VoiceToTextEvent {
  const InitializeVoiceToText();
}

class StartRecording extends VoiceToTextEvent {
  const StartRecording();
}

class StopRecording extends VoiceToTextEvent {
  const StopRecording();
}

class PauseRecording extends VoiceToTextEvent {
  const PauseRecording();
}

class ResumeRecording extends VoiceToTextEvent {
  const ResumeRecording();
}

class CancelRecording extends VoiceToTextEvent {
  const CancelRecording();
}

class UpdateTranscription extends VoiceToTextEvent {
  final String transcription;

  const UpdateTranscription(this.transcription);

  @override
  List<Object?> get props => [transcription];
}

class SaveRecording extends VoiceToTextEvent {
  final String title;
  final List<String> tags;

  const SaveRecording({required this.title, this.tags = const []});

  @override
  List<Object?> get props => [title, tags];
}

class LoadRecordings extends VoiceToTextEvent {
  const LoadRecordings();
}

class DeleteRecording extends VoiceToTextEvent {
  final String recordingId;

  const DeleteRecording(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

class PlayRecording extends VoiceToTextEvent {
  final VoiceRecordingModel recording;

  const PlayRecording(this.recording);

  @override
  List<Object?> get props => [recording];
}

class PausePlayback extends VoiceToTextEvent {
  const PausePlayback();
}

class ResumePlayback extends VoiceToTextEvent {
  const ResumePlayback();
}

class StopPlayback extends VoiceToTextEvent {
  const StopPlayback();
}

class SeekPlayback extends VoiceToTextEvent {
  final Duration position;

  const SeekPlayback(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdatePlaybackPosition extends VoiceToTextEvent {
  final Duration position;

  const UpdatePlaybackPosition(this.position);

  @override
  List<Object?> get props => [position];
}

class UpdatePlaybackDuration extends VoiceToTextEvent {
  final Duration duration;

  const UpdatePlaybackDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class ToggleFavorite extends VoiceToTextEvent {
  final String recordingId;

  const ToggleFavorite(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

class UpdateRecordingTitle extends VoiceToTextEvent {
  final String recordingId;
  final String newTitle;

  const UpdateRecordingTitle({
    required this.recordingId,
    required this.newTitle,
  });

  @override
  List<Object?> get props => [recordingId, newTitle];
}

class EditTranscription extends VoiceToTextEvent {
  final String recordingId;
  final String newTranscription;

  const EditTranscription({
    required this.recordingId,
    required this.newTranscription,
  });

  @override
  List<Object?> get props => [recordingId, newTranscription];
}

class SearchRecordings extends VoiceToTextEvent {
  final String query;

  const SearchRecordings(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterRecordings extends VoiceToTextEvent {
  final RecordingFilter filter;

  const FilterRecordings(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SortRecordings extends VoiceToTextEvent {
  final RecordingSort sort;

  const SortRecordings(this.sort);

  @override
  List<Object?> get props => [sort];
}

class UpdateRecordingDuration extends VoiceToTextEvent {
  final Duration duration;

  const UpdateRecordingDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class UpdateWaveformData extends VoiceToTextEvent {
  final List<double> waveformData;

  const UpdateWaveformData(this.waveformData);

  @override
  List<Object?> get props => [waveformData];
}

class GenerateSummary extends VoiceToTextEvent {
  final String recordingId;

  const GenerateSummary(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

class CopyTranscription extends VoiceToTextEvent {
  final String transcription;

  const CopyTranscription(this.transcription);

  @override
  List<Object?> get props => [transcription];
}

class ClearCurrentTranscription extends VoiceToTextEvent {
  const ClearCurrentTranscription();
}

class ChangeLanguage extends VoiceToTextEvent {
  final String language;

  const ChangeLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

enum RecordingFilter { all, favorites, today, thisWeek, thisMonth }

enum RecordingSort {
  dateNewest,
  dateOldest,
  durationLongest,
  durationShortest,
  alphabetical,
}
