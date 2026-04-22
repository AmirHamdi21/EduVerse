import 'ai_notes_models.dart';

/// Base state for AI Notes
abstract class AINotesState {
  const AINotesState();
}

/// Initial state
class AINotesInitial extends AINotesState {
  const AINotesInitial();
}

/// Loading state
class AINotesLoading extends AINotesState {
  const AINotesLoading();
}

/// Loaded state with data
class AINotesLoaded extends AINotesState {
  final List<AINote> notes;
  final List<AINote> filteredNotes;
  final List<NoteCategory> categories;
  final List<StudyRecommendation> recommendations;
  final NotesQuickStats stats;
  final NotesFilter currentFilter;
  final NotesSort currentSort;
  final String? selectedCategoryId;
  final String searchQuery;
  final AINote? selectedNote;
  final bool isGeneratingContent;
  final String? error;

  const AINotesLoaded({
    required this.notes,
    required this.filteredNotes,
    required this.categories,
    required this.recommendations,
    required this.stats,
    this.currentFilter = NotesFilter.all,
    this.currentSort = NotesSort.dateNewest,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.selectedNote,
    this.isGeneratingContent = false,
    this.error,
  });

  AINotesLoaded copyWith({
    List<AINote>? notes,
    List<AINote>? filteredNotes,
    List<NoteCategory>? categories,
    List<StudyRecommendation>? recommendations,
    NotesQuickStats? stats,
    NotesFilter? currentFilter,
    NotesSort? currentSort,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    AINote? selectedNote,
    bool clearSelectedNote = false,
    bool? isGeneratingContent,
    String? error,
    bool clearError = false,
  }) {
    return AINotesLoaded(
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      categories: categories ?? this.categories,
      recommendations: recommendations ?? this.recommendations,
      stats: stats ?? this.stats,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedNote: clearSelectedNote
          ? null
          : (selectedNote ?? this.selectedNote),
      isGeneratingContent: isGeneratingContent ?? this.isGeneratingContent,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Error state
class AINotesError extends AINotesState {
  final String message;

  const AINotesError({required this.message});
}
