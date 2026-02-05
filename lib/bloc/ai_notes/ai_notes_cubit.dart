import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_notes_models.dart';
import 'ai_notes_state.dart';

class AINoteCubit extends Cubit<AINotesState> {
  AINoteCubit() : super(const AINotesInitial());

  Future<void> loadNotes() async {
    emit(const AINotesLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final notes = _generateSampleNotes();
      final categories = NoteCategories.all;
      final recommendations = _generateSampleRecommendations();
      final stats = _calculateStats(notes);

      emit(AINotesLoaded(
        notes: notes,
        filteredNotes: notes,
        categories: categories,
        recommendations: recommendations,
        stats: stats,
      ));
    } catch (e) {
      emit(AINotesError(message: e.toString()));
    }
  }

  void searchNotes(String query) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.notes,
      currentState.currentFilter,
      currentState.currentSort,
      currentState.selectedCategoryId,
      query,
    );

    emit(currentState.copyWith(
      searchQuery: query,
      filteredNotes: filtered,
    ));
  }

  void applyFilter(NotesFilter filter, {String? categoryId}) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final newCategoryId = filter == NotesFilter.byCourse ? categoryId : null;

    final filtered = _applyFiltersAndSort(
      currentState.notes,
      filter,
      currentState.currentSort,
      newCategoryId,
      currentState.searchQuery,
    );

    emit(currentState.copyWith(
      currentFilter: filter,
      selectedCategoryId: newCategoryId,
      clearSelectedCategory: filter != NotesFilter.byCourse,
      filteredNotes: filtered,
    ));
  }

  void applySort(NotesSort sort) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final filtered = _applyFiltersAndSort(
      currentState.notes,
      currentState.currentFilter,
      sort,
      currentState.selectedCategoryId,
      currentState.searchQuery,
    );

    emit(currentState.copyWith(
      currentSort: sort,
      filteredNotes: filtered,
    ));
  }

  void selectNote(AINote note) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    emit(currentState.copyWith(selectedNote: note));
  }

  void clearSelectedNote() {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    emit(currentState.copyWith(clearSelectedNote: true));
  }

  void toggleFavorite(String noteId) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final updatedNotes = currentState.notes.map((note) {
      if (note.id == noteId) {
        return note.copyWith(isFavorited: !note.isFavorited);
      }
      return note;
    }).toList();

    final filtered = _applyFiltersAndSort(
      updatedNotes,
      currentState.currentFilter,
      currentState.currentSort,
      currentState.selectedCategoryId,
      currentState.searchQuery,
    );

    final stats = _calculateStats(updatedNotes);

    // Update selected note if it's the one being favorited
    AINote? updatedSelectedNote;
    if (currentState.selectedNote?.id == noteId) {
      updatedSelectedNote = updatedNotes.firstWhere((n) => n.id == noteId);
    }

    emit(currentState.copyWith(
      notes: updatedNotes,
      filteredNotes: filtered,
      stats: stats,
      selectedNote: updatedSelectedNote,
    ));
  }

  void toggleNoteExpanded(String noteId) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final updatedNotes = currentState.notes.map((note) {
      if (note.id == noteId) {
        return note.copyWith(isExpanded: !note.isExpanded);
      }
      return note;
    }).toList();

    final filtered = _applyFiltersAndSort(
      updatedNotes,
      currentState.currentFilter,
      currentState.currentSort,
      currentState.selectedCategoryId,
      currentState.searchQuery,
    );

    emit(currentState.copyWith(
      notes: updatedNotes,
      filteredNotes: filtered,
    ));
  }

  Future<void> generateFlashcards(String noteId) async {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    emit(currentState.copyWith(isGeneratingContent: true));
    HapticFeedback.mediumImpact();

    try {
      // Simulate AI generation
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would call an AI service
      emit(currentState.copyWith(
        isGeneratingContent: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isGeneratingContent: false,
        error: 'Failed to generate flashcards: ${e.toString()}',
      ));
    }
  }

  Future<void> regenerateNote(String noteId) async {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    emit(currentState.copyWith(isGeneratingContent: true));
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Simulate regeneration with slightly different content
      final updatedNotes = currentState.notes.map((note) {
        if (note.id == noteId) {
          return note.copyWith(
            updatedAt: DateTime.now(),
            content: '${note.content}\n\n[Regenerated with additional insights]',
          );
        }
        return note;
      }).toList();

      final filtered = _applyFiltersAndSort(
        updatedNotes,
        currentState.currentFilter,
        currentState.currentSort,
        currentState.selectedCategoryId,
        currentState.searchQuery,
      );

      AINote? updatedSelectedNote;
      if (currentState.selectedNote?.id == noteId) {
        updatedSelectedNote = updatedNotes.firstWhere((n) => n.id == noteId);
      }

      emit(currentState.copyWith(
        notes: updatedNotes,
        filteredNotes: filtered,
        selectedNote: updatedSelectedNote,
        isGeneratingContent: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isGeneratingContent: false,
        error: 'Failed to regenerate note: ${e.toString()}',
      ));
    }
  }

  void deleteNote(String noteId) {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    final updatedNotes = currentState.notes.where((n) => n.id != noteId).toList();

    final filtered = _applyFiltersAndSort(
      updatedNotes,
      currentState.currentFilter,
      currentState.currentSort,
      currentState.selectedCategoryId,
      currentState.searchQuery,
    );

    final stats = _calculateStats(updatedNotes);

    emit(currentState.copyWith(
      notes: updatedNotes,
      filteredNotes: filtered,
      stats: stats,
      clearSelectedNote: currentState.selectedNote?.id == noteId,
    ));
  }

  void clearError() {
    final currentState = state;
    if (currentState is! AINotesLoaded) return;

    emit(currentState.copyWith(clearError: true));
  }

  List<AINote> _applyFiltersAndSort(
    List<AINote> notes,
    NotesFilter filter,
    NotesSort sort,
    String? categoryId,
    String searchQuery,
  ) {
    var filtered = List<AINote>.from(notes);

    // Apply filter
    switch (filter) {
      case NotesFilter.all:
        break;
      case NotesFilter.byCourse:
        if (categoryId != null) {
          filtered = filtered.where((n) => n.category.id == categoryId).toList();
        }
        break;
      case NotesFilter.byDate:
        // Already filtered by date via sort
        break;
      case NotesFilter.favorites:
        filtered = filtered.where((n) => n.isFavorited).toList();
        break;
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.summary.toLowerCase().contains(query) ||
            note.category.name.toLowerCase().contains(query) ||
            note.tags.any((t) => t.toLowerCase().contains(query)) ||
            note.keyTopics.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    // Apply sort
    switch (sort) {
      case NotesSort.dateNewest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NotesSort.dateOldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NotesSort.titleAZ:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NotesSort.titleZA:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case NotesSort.courseAZ:
        filtered.sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
    }

    return filtered;
  }

  NotesQuickStats _calculateStats(List<AINote> notes) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return NotesQuickStats(
      totalNotes: notes.length,
      favoritedCount: notes.where((n) => n.isFavorited).length,
      coursesCount: notes.map((n) => n.category.id).toSet().length,
      notesThisWeek: notes.where((n) => n.createdAt.isAfter(weekAgo)).length,
    );
  }

  List<AINote> _generateSampleNotes() {
    return [
      AINote(
        id: 'note_1',
        title: 'Lecture 4 - Machine Learning Basics',
        content: '''This lecture covers fundamental concepts in machine learning, including supervised vs unsupervised learning, model evaluation metrics, and the bias-variance tradeoff.

Key Topics:
• Supervised Learning - Using labeled data to train models
• Unsupervised Learning - Finding patterns in unlabeled data - Model Evaluation - Accuracy, Precision, Recall, F1-Score
• Overfitting and Underfitting

The lecture emphasized the importance of proper data splitting and cross-validation techniques to ensure model generalization.''',
        summary: 'This lecture covers fundamental concepts in machine learning, including supervised vs unsupervised learning, model evaluation metrics, and the bias-variance tradeoff.',
        category: NoteCategories.machineLearning,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isFavorited: true,
        keyTopics: ['Supervised Learning', 'Unsupervised Learning', 'Model Evaluation', 'Bias-Variance Tradeoff'],
        tags: ['ML', 'Basics', 'Fundamentals'],
        source: NoteSource.lecture,
      ),
      AINote(
        id: 'note_2',
        title: 'Summary of Binary Trees',
        content: '''This note covers binary search trees & trees, including properties, traversal methods (in-order, pre-order, post-order), and complexity.

Binary Tree Properties:
• Each node has at most 2 children
• Left subtree values < root
• Right subtree values > root

Time Complexity:
• Search: O(log n) average, O(n) worst
• Insert: O(log n) average, O(n) worst
• Delete: O(log n) average, O(n) worst''',
        summary: 'This note covers binary search trees & trees, including properties, traversal methods (in-order, pre-order, post-order), and complexity.',
        category: NoteCategories.dataStructures,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        keyTopics: ['Binary Trees', 'Traversal', 'Complexity', 'BST'],
        tags: ['Trees', 'Data Structures'],
        source: NoteSource.textbook,
      ),
      AINote(
        id: 'note_3',
        title: 'API Design Principles',
        content: '''A summary of best practices for designing RESTful APIs. Key topics include proper naming conventions, HTTP methods, status codes, and versioning.

REST Principles:
• Use nouns for resources
• Proper HTTP methods (GET, POST, PUT, DELETE)
• Meaningful status codes
• API versioning strategies

Best Practices:
• Consistent naming conventions
• Pagination for large datasets
• Error handling and messages
• Documentation (OpenAPI/Swagger)''',
        summary: 'A summary of best practices for designing RESTful APIs. Key topics include proper naming conventions, HTTP methods, status codes, and versioning.',
        category: NoteCategories.webDevelopment,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        keyTopics: ['REST', 'HTTP Methods', 'API Versioning', 'Status Codes'],
        tags: ['API', 'REST', 'Web'],
        source: NoteSource.article,
      ),
      AINote(
        id: 'note_4',
        title: 'Introduction to Neural Networks',
        content: '''An overview of neural network architecture, including perceptrons, activation functions, backpropagation, and gradient descent.

Network Components:
• Input Layer - receives raw data
• Hidden Layers - feature extraction
• Output Layer - predictions

Activation Functions:
• ReLU - most common for hidden layers
• Sigmoid - binary classification
• Softmax - multi-class classification

Training Process:
• Forward propagation
• Loss calculation
• Backpropagation
• Weight updates''',
        summary: 'An overview of neural network architecture, including perceptrons, activation functions, backpropagation, and gradient descent.',
        category: NoteCategories.deepLearning,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        isFavorited: true,
        keyTopics: ['Neural Networks', 'Activation Functions', 'Backpropagation', 'Gradient Descent'],
        tags: ['Deep Learning', 'Neural Networks'],
        source: NoteSource.lecture,
      ),
      AINote(
        id: 'note_5',
        title: 'Database Normalization',
        content: '''Understanding database normalization forms (1NF, 2NF, 3NF, BCNF) and their importance in reducing data redundancy.

Normal Forms:
• 1NF - Atomic values, no repeating groups
• 2NF - 1NF + no partial dependencies
• 3NF - 2NF + no transitive dependencies
• BCNF - Every determinant is a candidate key

Benefits:
• Reduces data redundancy
• Improves data integrity
• Easier maintenance
• Efficient storage''',
        summary: 'Understanding database normalization forms (1NF, 2NF, 3NF, BCNF) and their importance in reducing data redundancy.',
        category: NoteCategories.databases,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
        keyTopics: ['Normalization', '1NF', '2NF', '3NF', 'BCNF'],
        tags: ['Database', 'SQL', 'Design'],
        source: NoteSource.lecture,
      ),
      AINote(
        id: 'note_6',
        title: 'Algorithms Complexity Analysis',
        content: '''Deep dive into Big O notation, time and space complexity analysis, and common algorithm patterns.

Time Complexity Classes:
• O(1) - Constant time
• O(log n) - Logarithmic
• O(n) - Linear
• O(n log n) - Linearithmic
• O(n²) - Quadratic
• O(2^n) - Exponential

Space Complexity:
• In-place algorithms
• Auxiliary space
• Stack space for recursion''',
        summary: 'Deep dive into Big O notation, time and space complexity analysis, and common algorithm patterns.',
        category: NoteCategories.algorithms,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        keyTopics: ['Big O', 'Time Complexity', 'Space Complexity', 'Analysis'],
        tags: ['Algorithms', 'Complexity'],
        source: NoteSource.lecture,
      ),
    ];
  }

  List<StudyRecommendation> _generateSampleRecommendations() {
    return [
      const StudyRecommendation(
        id: 'rec_1',
        type: RecommendationType.reviewTopic,
        title: 'Review Topic',
        description: 'Overfitting in Neural Networks',
        noteId: 'note_4',
      ),
      const StudyRecommendation(
        id: 'rec_2',
        type: RecommendationType.relatedConcept,
        title: 'Related Concept',
        description: 'Decision Tree Pruning',
        noteId: 'note_1',
        isNew: true,
      ),
      StudyRecommendation(
        id: 'rec_3',
        type: RecommendationType.upcomingQuiz,
        title: 'Upcoming Quiz',
        description: 'Data Structures Midterm',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        isNew: true,
      ),
    ];
  }
}
