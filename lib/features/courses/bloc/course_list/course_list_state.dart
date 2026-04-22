import 'package:equatable/equatable.dart';

import '../../../../models/core/enrollment_model.dart';

class CourseListState extends Equatable {
  final List<CourseEnrollmentModel> courses;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const CourseListState({
    this.courses = const <CourseEnrollmentModel>[],
    this.isLoading = false,
    this.error,
    this.hasMore = false,
    this.currentPage = 1,
  });

  CourseListState copyWith({
    List<CourseEnrollmentModel>? courses,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasMore,
    int? currentPage,
  }) {
    return CourseListState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    courses,
    isLoading,
    error,
    hasMore,
    currentPage,
  ];
}
