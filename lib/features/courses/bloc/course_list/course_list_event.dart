import 'package:equatable/equatable.dart';

abstract class CourseListEvent extends Equatable {
  const CourseListEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchCourses extends CourseListEvent {
  const FetchCourses();
}

class RefreshCourses extends CourseListEvent {
  const RefreshCourses();
}
