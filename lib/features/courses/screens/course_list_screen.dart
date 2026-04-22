import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/courses/courses_bloc.dart';
import '../../../models/core/enrollment_model.dart';
import '../../../widgets/student/course_list/course_card.dart';
import '../../../widgets/student/course_list/empty_courses_message.dart';
import '../bloc/course_list/course_list_bloc.dart';
import '../bloc/course_list/course_list_event.dart';
import '../bloc/course_list/course_list_state.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatelessWidget {
  final CourseListBloc? bloc;
  final bool autoFetch;

  const CourseListScreen({super.key, this.bloc, this.autoFetch = true});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<CourseListBloc>.value(
        value: bloc!,
        child: _CourseListBody(autoFetch: autoFetch),
      );
    }

    final enrollmentService = context.read<CoursesBloc>().enrollmentService;

    return BlocProvider<CourseListBloc>(
      create: (_) => CourseListBloc(enrollmentService: enrollmentService),
      child: _CourseListBody(autoFetch: autoFetch),
    );
  }
}

class _CourseListBody extends StatefulWidget {
  final bool autoFetch;

  const _CourseListBody({required this.autoFetch});

  @override
  State<_CourseListBody> createState() => _CourseListBodyState();
}

class _CourseListBodyState extends State<_CourseListBody> {
  @override
  void initState() {
    super.initState();
    if (widget.autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<CourseListBloc>().add(const FetchCourses());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: BlocBuilder<CourseListBloc, CourseListState>(
        builder: (context, state) {
          if (state.isLoading && state.courses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.courses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(state.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CourseListBloc>().add(
                          const RefreshCourses(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.courses.isEmpty) {
            return const EmptyCoursesMessage();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CourseListBloc>().add(const RefreshCourses());
            },
            child: ListView.builder(
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final enrollment = state.courses[index];
                return CourseCard(
                  enrollment: enrollment,
                  onTap: () => _openCourseDetail(context, enrollment),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openCourseDetail(
    BuildContext context,
    CourseEnrollmentModel enrollment,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseDetailScreen(enrollment: enrollment),
      ),
    );
  }
}
