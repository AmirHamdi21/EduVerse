import 'package:equatable/equatable.dart';

import '../../models/instructor/teaching_course_model.dart';
import '../../models/labs/lab_model.dart';

abstract class InstructorLabsState extends Equatable {
  const InstructorLabsState();

  @override
  List<Object?> get props => const <Object?>[];
}

class InstructorLabsInitial extends InstructorLabsState {
  const InstructorLabsInitial();
}

class InstructorLabsLoading extends InstructorLabsState {
  const InstructorLabsLoading();
}

class InstructorLabsLoaded extends InstructorLabsState {
  const InstructorLabsLoaded({
    required this.labs,
    required this.filteredLabs,
    required this.searchQuery,
    required this.selectedStatus,
    required this.currentPage,
    required this.hasMorePages,
    required this.isLoadingMore,
    required this.teachingCourses,
    required this.selectedCourseId,
  });

  final List<LabModel> labs;
  final List<LabModel> filteredLabs;
  final String searchQuery;
  final String selectedStatus;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;
  final List<TeachingCourseModel> teachingCourses;
  final int? selectedCourseId;

  InstructorLabsLoaded copyWith({
    List<LabModel>? labs,
    List<LabModel>? filteredLabs,
    String? searchQuery,
    String? selectedStatus,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
    List<TeachingCourseModel>? teachingCourses,
    int? selectedCourseId,
    bool clearSelectedCourse = false,
  }) {
    return InstructorLabsLoaded(
      labs: labs ?? this.labs,
      filteredLabs: filteredLabs ?? this.filteredLabs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      teachingCourses: teachingCourses ?? this.teachingCourses,
      selectedCourseId: clearSelectedCourse
          ? null
          : (selectedCourseId ?? this.selectedCourseId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    labs,
    filteredLabs,
    searchQuery,
    selectedStatus,
    currentPage,
    hasMorePages,
    isLoadingMore,
    teachingCourses,
    selectedCourseId,
  ];
}

class InstructorLabsError extends InstructorLabsState {
  const InstructorLabsError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
