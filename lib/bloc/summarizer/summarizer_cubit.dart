import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'summarizer_state.dart';

class SummarizerCubit extends Cubit<SummarizerState> {
  static const String _summariesKey = 'summarizer_summaries_data';
  final _uuid = const Uuid();
  final _random = Random();

  SummarizerCubit() : super(const SummarizerState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _loadSummaries();
      _applyFilters();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> _loadSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final summariesJson = prefs.getString(_summariesKey);
    
    List<Summary> summaries = [];
    if (summariesJson != null) {
      final List<dynamic> decoded = jsonDecode(summariesJson);
      summaries = decoded.map((e) => Summary.fromJson(e)).toList();
    }

    emit(state.copyWith(
      summaries: summaries,
      isLoading: false,
    ));
  }

  Future<void> _saveSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final summariesJson =
        jsonEncode(state.summaries.map((e) => e.toJson()).toList());
    await prefs.setString(_summariesKey, summariesJson);
  }

  void _applyFilters() {
    var filtered = List<Summary>.from(state.summaries);

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((s) =>
              s.title.toLowerCase().contains(query) ||
              s.content.toLowerCase().contains(query))
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(filteredSummaries: filtered));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void setActiveInputSource(InputSource source) {
    emit(state.copyWith(activeInputSource: source));
  }

  void setTextInput(String text) {
    emit(state.copyWith(textInput: text));
  }

  void setSummarizationType(SummarizationType type) {
    emit(state.copyWith(selectedType: type));
  }

  void clearUploadedFile() {
    emit(state.copyWith(clearUploadedFile: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> uploadFile() async {
    try {
      emit(state.copyWith(
        uploadProgress: const UploadProgress(fileName: ''),
        status: SummaryStatus.uploading,
      ));

      final result = await picker.FilePicker.platform.pickFiles(
        type: picker.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        emit(state.copyWith(
          clearUploadProgress: true,
          status: SummaryStatus.idle,
        ));
        return;
      }

      final platformFile = result.files.first;
      if (platformFile.path == null) {
        emit(state.copyWith(
          errorMessage: 'Failed to get file path',
          status: SummaryStatus.error,
          clearUploadProgress: true,
        ));
        return;
      }

      // Get app directory for storing uploaded files
      final appDir = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory('${appDir.path}/summarizer_uploads');
      if (!await uploadsDir.exists()) {
        await uploadsDir.create(recursive: true);
      }

      final sourceFile = File(platformFile.path!);
      final targetPath =
          '${uploadsDir.path}/${_uuid.v4()}_${platformFile.name}';

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 50));
        emit(state.copyWith(
          uploadProgress: UploadProgress(
            fileName: platformFile.name,
            progress: i / 100,
          ),
        ));
      }

      // Copy file to app storage
      await sourceFile.copy(targetPath);

      final uploadedFile = UploadedFile(
        id: _uuid.v4(),
        name: platformFile.name,
        path: targetPath,
        size: platformFile.size,
        uploadedAt: DateTime.now(),
      );

      emit(state.copyWith(
        uploadedFile: uploadedFile,
        uploadProgress: UploadProgress(
          fileName: platformFile.name,
          progress: 1.0,
          isCompleted: true,
        ),
        status: SummaryStatus.idle,
        activeInputSource: InputSource.file,
      ));

      // Clear upload progress after delay
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(clearUploadProgress: true));
    } catch (e) {
      emit(state.copyWith(
        uploadProgress: UploadProgress(
          fileName: '',
          error: e.toString(),
        ),
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      ));

      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(clearUploadProgress: true));
    }
  }

  Future<void> generateSummary() async {
    if (!state.canGenerate) return;

    try {
      emit(state.copyWith(
        status: SummaryStatus.processing,
        clearError: true,
      ));

      // Simulate AI processing time
      await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(1000)));

      // Generate mock summary based on type
      final summaryContent = _generateMockSummary();
      final keyPoints = _generateMockKeyPoints();

      String title;
      String? sourceFileName;

      if (state.activeInputSource == InputSource.file &&
          state.uploadedFile != null) {
        title = 'Summary of ${state.uploadedFile!.name}';
        sourceFileName = state.uploadedFile!.name;
      } else {
        final words = state.textInput.split(' ');
        title = words.take(5).join(' ');
        if (title.length > 30) {
          title = '${title.substring(0, 30)}...';
        }
        title = 'Summary: $title';
      }

      final summary = Summary(
        id: _uuid.v4(),
        title: title,
        content: summaryContent,
        type: state.selectedType,
        createdAt: DateTime.now(),
        sourceFileName: sourceFileName,
        source: state.activeInputSource,
        keyPoints: keyPoints,
      );

      final updatedSummaries = [summary, ...state.summaries];

      emit(state.copyWith(
        summaries: updatedSummaries,
        currentSummary: summary,
        status: SummaryStatus.completed,
        clearUploadedFile: true,
        textInput: '',
      ));

      await _saveSummaries();
      _applyFilters();
    } catch (e) {
      emit(state.copyWith(
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  String _generateMockSummary() {
    switch (state.selectedType) {
      case SummarizationType.keyPoints:
        return '''
Key Points Summary:

• The lecture covers fundamental concepts and their practical applications in real-world scenarios.

• Main theoretical frameworks are discussed with emphasis on critical thinking and analysis.

• Several case studies demonstrate the effectiveness of the methodologies presented.

• Important connections are drawn between theory and practice.

• The material builds upon previous concepts while introducing new perspectives.

• Assessment criteria and learning outcomes are clearly defined.
''';

      case SummarizationType.brief:
        return '''
This content provides a comprehensive overview of the subject matter, focusing on core principles and their practical applications. The key themes include theoretical foundations, methodological approaches, and real-world case studies. Students are expected to develop critical thinking skills while engaging with the material.
''';

      case SummarizationType.detailed:
        return '''
Detailed Summary:

Introduction:
The content begins with an overview of fundamental concepts, establishing the theoretical framework that will guide subsequent discussions.

Core Concepts:
Several key ideas are explored in depth:
1. Theoretical foundations and their historical development
2. Practical applications across different contexts
3. Methodological considerations and best practices
4. Critical analysis frameworks

Case Studies:
Multiple examples illustrate how these concepts apply in real-world situations, demonstrating both successes and challenges.

Conclusions:
The material emphasizes the importance of integrating theory with practice, encouraging students to develop their analytical skills through hands-on engagement with the subject matter.

Key Takeaways:
Understanding the interconnections between concepts is essential for mastery of the material.
''';

      case SummarizationType.bulletPoints:
        return '''
• Introduction to core concepts
• Theoretical framework overview
• Historical context and development
• Key methodological approaches
• Practical applications
• Case study analysis
• Critical thinking frameworks
• Assessment criteria
• Learning outcomes
• Future directions
''';

      case SummarizationType.mindMap:
        return '''
Central Topic
├── Theory
│   ├── Historical Background
│   ├── Key Principles
│   └── Modern Interpretations
├── Practice
│   ├── Case Studies
│   ├── Applications
│   └── Best Practices
├── Analysis
│   ├── Critical Thinking
│   ├── Evaluation Methods
│   └── Comparative Studies
└── Outcomes
    ├── Learning Goals
    ├── Assessment
    └── Future Research
''';
    }
  }

  List<String> _generateMockKeyPoints() {
    return [
      'Core theoretical concepts explained',
      'Practical applications demonstrated',
      'Case studies analyzed',
      'Critical thinking emphasized',
      'Learning outcomes defined',
    ];
  }

  void selectSummaryForView(Summary summary) {
    emit(state.copyWith(selectedSummaryForView: summary));
  }

  void clearSelectedSummary() {
    emit(state.copyWith(clearSelectedSummary: true));
  }

  void clearCurrentSummary() {
    emit(state.copyWith(clearCurrentSummary: true, status: SummaryStatus.idle));
  }

  Future<void> toggleFavorite(String summaryId) async {
    final updatedSummaries = state.summaries.map((s) {
      if (s.id == summaryId) {
        return s.copyWith(isFavorite: !s.isFavorite);
      }
      return s;
    }).toList();

    // Also update currentSummary if it's the one being toggled
    Summary? updatedCurrentSummary = state.currentSummary;
    if (state.currentSummary != null && state.currentSummary!.id == summaryId) {
      updatedCurrentSummary = state.currentSummary!.copyWith(
        isFavorite: !state.currentSummary!.isFavorite,
      );
    }

    emit(state.copyWith(
      summaries: updatedSummaries,
      currentSummary: updatedCurrentSummary,
    ));
    await _saveSummaries();
    _applyFilters();
  }

  Future<void> deleteSummary(String summaryId) async {
    final updatedSummaries =
        state.summaries.where((s) => s.id != summaryId).toList();
    emit(state.copyWith(summaries: updatedSummaries, clearSelectedSummary: true));
    await _saveSummaries();
    _applyFilters();
  }

  void reset() {
    emit(state.copyWith(
      clearUploadedFile: true,
      textInput: '',
      status: SummaryStatus.idle,
      clearError: true,
      clearCurrentSummary: true,
    ));
  }

  void refresh() {
    _initialize();
  }
}
