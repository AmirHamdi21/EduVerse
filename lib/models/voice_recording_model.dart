import 'package:equatable/equatable.dart';

class VoiceRecordingModel extends Equatable {
  final String id;
  final String title;
  final String transcription;
  final String? summary;
  final String audioFilePath;
  final Duration duration;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final bool isFavorite;

  const VoiceRecordingModel({
    required this.id,
    required this.title,
    required this.transcription,
    this.summary,
    required this.audioFilePath,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.isFavorite = false,
  });

  VoiceRecordingModel copyWith({
    String? id,
    String? title,
    String? transcription,
    String? summary,
    String? audioFilePath,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return VoiceRecordingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      transcription: transcription ?? this.transcription,
      summary: summary ?? this.summary,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'transcription': transcription,
      'summary': summary,
      'audioFilePath': audioFilePath,
      'duration': duration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  factory VoiceRecordingModel.fromJson(Map<String, dynamic> json) {
    return VoiceRecordingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      transcription: json['transcription'] as String,
      summary: json['summary'] as String?,
      audioFilePath: json['audioFilePath'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        transcription,
        summary,
        audioFilePath,
        duration,
        createdAt,
        updatedAt,
        tags,
        isFavorite,
      ];
}
