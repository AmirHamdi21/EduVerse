# Voice to Text Feature Documentation

## Overview

The Voice to Text feature allows students to record audio, transcribe it to text, and manage their recordings. This feature is useful for taking notes during lectures, creating voice memos, and converting spoken content to written text.

## Architecture

### Directory Structure

```
lib/
├── bloc/
│   └── voice_to_text/
│       ├── voice_to_text_cubit.dart    # State management
│       └── voice_to_text_state.dart    # State models and enums
├── screens/
│   └── student/
│       └── voice_to_text/
│           └── voice_to_text_screen.dart   # Main screen
└── widgets/
    └── student/
        └── voice_to_text/
            ├── recordings_list_card.dart      # Recording list item
            ├── transcription_card.dart        # Transcription display
            ├── voice_recording_button.dart    # Recording FAB
            └── waveform_visualizer.dart       # Audio waveform animation
```

### State Management

Uses **Cubit pattern** (flutter_bloc) for predictable state management.

#### VoiceToTextState

```dart
class VoiceToTextState {
  final List<Recording> recordings;
  final Recording? currentRecording;
  final RecordingStatus status;
  final String? transcription;
  final String? errorMessage;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final List<double> waveformData;
  final String searchQuery;
  final RecordingFilter filter;
  final RecordingSortOption sortOption;
}
```

#### Recording Model

```dart
class Recording {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final Duration duration;
  final String? transcription;
  final bool isFavorite;
  final List<String> tags;
}
```

## Features

### 1. Audio Recording

- **Start/Stop Recording**: Tap the microphone button to start/stop recording
- **Pause/Resume**: Pause and resume recording during a session
- **Real-time Duration**: Shows elapsed recording time
- **Waveform Visualization**: Animated waveform during recording

### 2. Audio Playback

- **Play/Pause**: Control audio playback
- **Seek**: Scrub through the audio timeline
- **Playback Speed**: Adjust playback speed (0.5x, 1x, 1.5x, 2x)
- **Position Indicator**: Shows current position and total duration

### 3. Transcription

- **Speech-to-Text**: Convert recorded audio to text
- **Copy Transcription**: Copy text to clipboard
- **Edit Transcription**: Manually edit transcribed text
- **Share**: Share transcription via system share sheet

### 4. Recording Management

- **List View**: View all recordings with search and filter
- **Rename**: Rename recordings
- **Delete**: Delete individual or multiple recordings
- **Favorites**: Mark recordings as favorites
- **Tags**: Add tags to organize recordings

### 5. Search & Filter

- **Search**: Search recordings by name or transcription content
- **Filter Options**:
  - All recordings
  - Favorites only
  - With transcription
  - Recent (last 7 days)
- **Sort Options**:
  - Date (newest/oldest)
  - Name (A-Z/Z-A)
  - Duration (longest/shortest)

## Local Storage

Recordings are stored locally using:
- **Audio Files**: Saved in app documents directory (`{appDocuments}/recordings/`)
- **Metadata**: Persisted to SharedPreferences as JSON

```dart
// Storage path
final directory = await getApplicationDocumentsDirectory();
final recordingsPath = '${directory.path}/recordings';

// Metadata storage key
static const String _storageKey = 'voice_to_text_recordings';
```

## Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `record` | ^5.1.2 | Audio recording |
| `audioplayers` | ^6.1.0 | Audio playback |
| `path_provider` | ^2.1.5 | File system access |
| `shared_preferences` | ^2.3.4 | Metadata persistence |
| `permission_handler` | ^11.3.1 | Microphone permission |
| `speech_to_text` | ^7.0.0 | Speech recognition |

## Permissions

### Android (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (Info.plist)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to transcribe audio</string>
```

## Localization

All UI text is localized in both English and Arabic:

| Key | English | Arabic |
|-----|---------|--------|
| `voiceToText` | Voice to Text | تحويل الصوت إلى نص |
| `startRecording` | Start Recording | بدء التسجيل |
| `stopRecording` | Stop Recording | إيقاف التسجيل |
| `transcribe` | Transcribe | تحويل إلى نص |
| `noRecordings` | No recordings yet | لا توجد تسجيلات بعد |
| `recordingDuration` | Duration | المدة |
| `searchRecordings` | Search recordings | البحث في التسجيلات |

## Theme Support

Supports both light and dark modes:

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | `#F8FAFC` | `#0F172A` |
| Card | `#FFFFFF` | `#1E293B` |
| Primary | `#3B82F6` | `#3B82F6` |
| Recording Active | `#EF4444` | `#EF4444` |

## Error Handling

### Scenarios Handled

1. **Permission Denied**: Shows dialog to request microphone permission
2. **Recording Failed**: Displays error message with retry option
3. **Playback Error**: Shows error toast with file path
4. **Transcription Failed**: Displays error with option to retry
5. **Storage Full**: Warns user before recording if storage is low

### Error State

```dart
if (state.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.errorMessage!),
      action: SnackBarAction(
        label: l10n.tryAgain,
        onPressed: () => cubit.retry(),
      ),
    ),
  );
}
```

## Navigation

### Route

```dart
// In app_router.dart
GoRoute(
  path: '/voice-to-text',
  name: 'voiceToText',
  builder: (context, state) => const VoiceToTextScreen(),
),
```

### Access Points

1. **Student Drawer**: Menu item in navigation drawer
2. **Deep Link**: `eduverse://voice-to-text`

## Performance Optimizations

1. **BlocBuilder with buildWhen**: Only rebuilds when specific state changes
2. **Lazy Loading**: Recordings loaded on-demand
3. **Audio Stream**: Uses streaming for large audio files
4. **Debounced Search**: 300ms debounce on search input
5. **Cached Waveform**: Waveform data cached after generation

## Usage Example

```dart
// Navigate to Voice to Text
context.push('/voice-to-text');

// Start recording programmatically
context.read<VoiceToTextCubit>().startRecording();

// Play a recording
context.read<VoiceToTextCubit>().playRecording(recordingId);
```

## Future Enhancements

- [ ] Cloud sync for recordings
- [ ] Multi-language transcription
- [ ] Real-time transcription during recording
- [ ] Audio editing (trim, merge)
- [ ] Export to various formats (MP3, WAV, M4A)
- [ ] Background recording
- [ ] Widget for quick recording from home screen
