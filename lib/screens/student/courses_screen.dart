import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';
import '../../widgets/student/courses/course_filter_bar.dart';
import '../../widgets/student/courses/course_search_bar.dart';
import '../../widgets/student/courses/courses_list_view.dart';
import '../../widgets/student/courses/course_model.dart';
import '../../widgets/student/courses/courses_header.dart';
import '../../widgets/student/courses/join_course_button.dart';
import '../../widgets/student/courses/filter_button.dart';
import '../../widgets/student/courses/sort_button.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'progress_desc';
  String _searchQuery = '';

  late List<CourseModel> _allCourses;
  late List<CourseModel> _filteredCourses;

  @override
  void initState() {
    super.initState();
    _initializeCourses();
  }

  void _initializeCourses() {
    _allCourses = [
      CourseModel(
        title: 'Introduction to AI',
        instructor: 'Dr. Alan Turing',
        progress: 0.75,
        nextEvent: 'Next Lecture: Nov 12 – AI Lab 3',
        eventDate: 'Nov 12',
        iconBackgroundColor: const Color(0xFF155DFC),
        courseIcon: Icons.computer,
        primaryButtonLabel: 'Continue',
      ),
      CourseModel(
        title: 'Data Structures',
        instructor: 'Dr. Grace Hopper',
        progress: 0.40,
        nextEvent: 'Next Assignment: Nov 15',
        eventDate: 'Nov 15',
        iconBackgroundColor: Colors.green,
        courseIcon: Icons.folder_open,
        primaryButtonLabel: 'Continue',
      ),
      CourseModel(
        title: 'Neural Networks',
        instructor: 'Dr. Yann LeCun',
        progress: 0.95,
        nextEvent: 'Final Exam: Dec 5',
        eventDate: 'Dec 5',
        iconBackgroundColor: Colors.purple,
        courseIcon: Icons.hub,
        primaryButtonLabel: 'Review',
      ),
      CourseModel(
        title: 'Cybersecurity Ethics',
        instructor: 'Dr. Ada Lovelace',
        progress: 0.15,
        nextEvent: 'Next Lecture: Nov 20',
        eventDate: 'Nov 20',
        iconBackgroundColor: Colors.red,
        courseIcon: Icons.shield,
        primaryButtonLabel: 'Continue',
      ),
      CourseModel(
        title: 'Machine Learning Fundamentals',
        instructor: 'Dr. Andrew Ng',
        progress: 0.60,
        nextEvent: 'Next Lab: Nov 18',
        eventDate: 'Nov 18',
        iconBackgroundColor: Colors.purple,
        courseIcon: Icons.hub,
        primaryButtonLabel: 'Continue',
      ),
      CourseModel(
        title: 'Web Development',
        instructor: 'Dr. Tim Berners-Lee',
        progress: 0.85,
        nextEvent: 'Project Due: Nov 25',
        eventDate: 'Nov 25',
        iconBackgroundColor: Colors.orange,
        courseIcon: Icons.language,
        primaryButtonLabel: 'Continue',
      ),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.instructor.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesFilter =
            _selectedFilter == 'all' ||
            (_selectedFilter == 'completed' && course.progress >= 0.8) ||
            (_selectedFilter == 'lectures' && course.progress < 0.8 && course.progress > 0) ||
            (_selectedFilter == 'labs' && course.progress >= 0.5 && course.progress < 0.8);

        return matchesSearch && matchesFilter;
      }).toList();

      _sortCourses();
    });
  }

  void _sortCourses() {
    switch (_selectedSort) {
      case 'progress_desc':
        _filteredCourses.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'progress_asc':
        _filteredCourses.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case 'title_asc':
        _filteredCourses.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        _filteredCourses.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'event_date':
        _filteredCourses.sort(
          (a, b) => a.eventDateAsNumber.compareTo(b.eventDateAsNumber),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          floatingActionButton: JoinCourseButton(),
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E)
              : const Color(0xFFFAFAFA),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // const CoursesAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      CoursesHeader(
                        title: l10n.myCoursesHeader,
                        subtitle: l10n.allEnrolledCoursesThisSemester,
                      ),
                      const SizedBox(height: 16),
                      CourseSearchBar(
                        onSearchChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterButton(
                            selectedFilter: _selectedFilter,
                            onFilterChanged: (filter) {
                              setState(() {
                                _selectedFilter = filter;
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          SortButton(
                            selectedSort: _selectedSort,
                            onSortChanged: (sort) {
                              setState(() {
                                _selectedSort = sort;
                                _applyFilters();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CourseFilterBar(
                        onFilterChanged: (filter) {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CoursesListView(courses: _filteredCourses),
                      const SizedBox(height: 32),
                      // const JoinCourseButton(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
