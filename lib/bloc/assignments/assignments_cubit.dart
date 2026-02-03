import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/assignments/assignment_model.dart';
import 'assignments_state.dart';

class AssignmentsCubit extends Cubit<AssignmentsState> {
  AssignmentsCubit() : super(const AssignmentsState());

  Future<void> loadAssignments() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final assignments = _generateDemoAssignments();
      emit(state.copyWith(assignments: assignments, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load assignments: ${e.toString()}',
      ));
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilter(AssignmentsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void clearFilters() {
    emit(state.copyWith(filter: const AssignmentsFilter()));
  }

  void setSortBy(AssignmentsSortBy sortBy) {
    if (state.sortBy == sortBy) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortBy: sortBy, sortAscending: true));
    }
  }

  void setViewMode(AssignmentsViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void toggleBookmark(String assignmentId) {
    try {
      final assignments = state.assignments.map((a) {
        if (a.id == assignmentId) {
          return a.copyWith(isBookmarked: !a.isBookmarked);
        }
        return a;
      }).toList();
      emit(state.copyWith(assignments: assignments));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle bookmark'));
      rethrow;
    }
  }

  void submitAssignment(String assignmentId, List<AssignmentAttachment> files, String? comments) {
    try {
      final index = state.assignments.indexWhere((a) => a.id == assignmentId);
      if (index == -1) {
        throw Exception('Assignment not found');
      }

      final assignment = state.assignments[index];
      final isLate = assignment.dueDate.isBefore(DateTime.now());

      final submission = SubmissionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        submittedAt: DateTime.now(),
        attachments: files,
        comments: comments,
      );

      final assignments = List<AssignmentModel>.from(state.assignments);
      assignments[index] = assignment.copyWith(
        status: isLate ? AssignmentStatus.late : AssignmentStatus.submitted,
        submission: submission,
      );
      emit(state.copyWith(assignments: assignments));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to submit assignment'));
      rethrow;
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  List<AssignmentModel> _generateDemoAssignments() {
    final now = DateTime.now();
    return [
      AssignmentModel(
        id: '1',
        title: 'Database Design Project',
        description: 'Design a complete database system for an e-commerce application including ER diagrams, normalization, and SQL scripts.',
        courseName: 'Database Systems',
        courseCode: 'CS301',
        instructorName: 'Dr. Ahmed Hassan',
        type: AssignmentType.project,
        status: AssignmentStatus.pending,
        priority: AssignmentPriority.high,
        dueDate: now.add(const Duration(days: 3)),
        assignedDate: now.subtract(const Duration(days: 7)),
        maxGrade: 100,
        attachments: [
          AssignmentAttachment(
            id: 'att1',
            name: 'Project_Requirements.pdf',
            url: 'https://example.com/requirements.pdf',
            fileType: 'pdf',
            fileSize: 245000,
          ),
          AssignmentAttachment(
            id: 'att2',
            name: 'Sample_ER_Diagram.png',
            url: 'https://example.com/sample.png',
            fileType: 'png',
            fileSize: 128000,
          ),
        ],
        instructions: [
          'Create ER diagram with at least 10 entities',
          'Apply normalization up to 3NF',
          'Write DDL and DML SQL scripts',
          'Include at least 5 complex queries',
          'Submit as ZIP file',
        ],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      AssignmentModel(
        id: '2',
        title: 'Neural Network Implementation',
        description: 'Implement a multi-layer perceptron from scratch using Python.',
        courseName: 'Machine Learning',
        courseCode: 'CS401',
        instructorName: 'Dr. Sarah Mohamed',
        type: AssignmentType.code,
        status: AssignmentStatus.submitted,
        priority: AssignmentPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
        assignedDate: now.subtract(const Duration(days: 14)),
        maxGrade: 50,
        attachments: [
          AssignmentAttachment(
            id: 'att3',
            name: 'MLP_Starter_Code.py',
            url: 'https://example.com/starter.py',
            fileType: 'py',
            fileSize: 8500,
          ),
        ],
        instructions: [
          'Do not use any ML libraries for the core implementation',
          'Implement forward and backward propagation',
          'Include training and evaluation functions',
          'Test on provided dataset',
        ],
        submission: SubmissionModel(
          id: 'sub1',
          submittedAt: now.subtract(const Duration(days: 1, hours: 2)),
          attachments: [
            AssignmentAttachment(
              id: 'sub_att1',
              name: 'mlp_implementation.py',
              url: 'https://example.com/submission.py',
              fileType: 'py',
              fileSize: 12400,
            ),
          ],
          comments: 'Implemented with additional regularization techniques.',
        ),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      AssignmentModel(
        id: '3',
        title: 'Security Report',
        description: 'Write a comprehensive report on modern cybersecurity threats and mitigation strategies.',
        courseName: 'Network Security',
        courseCode: 'CS450',
        instructorName: 'Prof. Omar Ali',
        type: AssignmentType.document,
        status: AssignmentStatus.graded,
        priority: AssignmentPriority.medium,
        dueDate: now.subtract(const Duration(days: 5)),
        assignedDate: now.subtract(const Duration(days: 20)),
        maxGrade: 30,
        instructions: [
          'Minimum 3000 words',
          'Include at least 10 academic references',
          'Cover at least 5 different threat categories',
          'Propose practical mitigation strategies',
        ],
        submission: SubmissionModel(
          id: 'sub2',
          submittedAt: now.subtract(const Duration(days: 6)),
          attachments: [
            AssignmentAttachment(
              id: 'sub_att2',
              name: 'Security_Report.docx',
              url: 'https://example.com/report.docx',
              fileType: 'docx',
              fileSize: 89000,
            ),
          ],
          grade: 27,
          maxGrade: 30,
          feedback: 'Excellent analysis of modern threats. Good use of references. Minor improvements needed in mitigation section.',
          gradedAt: now.subtract(const Duration(days: 2)),
        ),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      AssignmentModel(
        id: '4',
        title: 'OS Concepts Quiz',
        description: 'Online quiz covering process management and memory allocation.',
        courseName: 'Operating Systems',
        courseCode: 'CS302',
        instructorName: 'Dr. Fatma Ibrahim',
        type: AssignmentType.quiz,
        status: AssignmentStatus.graded,
        priority: AssignmentPriority.low,
        dueDate: now.subtract(const Duration(days: 10)),
        assignedDate: now.subtract(const Duration(days: 12)),
        maxGrade: 20,
        instructions: [
          '20 multiple choice questions',
          'Time limit: 30 minutes',
          'No going back to previous questions',
        ],
        submission: SubmissionModel(
          id: 'sub3',
          submittedAt: now.subtract(const Duration(days: 10)),
          attachments: [],
          grade: 18,
          maxGrade: 20,
          feedback: '18/20 correct answers. Review memory paging concepts.',
          gradedAt: now.subtract(const Duration(days: 9)),
        ),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      AssignmentModel(
        id: '5',
        title: 'React SPA Development',
        description: 'Build a single-page application using React with routing and state management.',
        courseName: 'Web Technologies',
        courseCode: 'CS350',
        instructorName: 'Eng. Youssef Kamal',
        type: AssignmentType.project,
        status: AssignmentStatus.pending,
        priority: AssignmentPriority.urgent,
        dueDate: now.add(const Duration(hours: 12)),
        assignedDate: now.subtract(const Duration(days: 10)),
        maxGrade: 80,
        attachments: [
          AssignmentAttachment(
            id: 'att4',
            name: 'React_Project_Specs.pdf',
            url: 'https://example.com/specs.pdf',
            fileType: 'pdf',
            fileSize: 156000,
          ),
        ],
        instructions: [
          'Use React Router for navigation',
          'Implement Redux for state management',
          'Include at least 5 pages/views',
          'Responsive design required',
          'Deploy to GitHub Pages or Vercel',
        ],
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      AssignmentModel(
        id: '6',
        title: 'Algorithm Analysis',
        description: 'Analyze time and space complexity of sorting algorithms.',
        courseName: 'Data Structures',
        courseCode: 'CS201',
        instructorName: 'Dr. Mohamed Saleh',
        type: AssignmentType.document,
        status: AssignmentStatus.overdue,
        priority: AssignmentPriority.high,
        dueDate: now.subtract(const Duration(days: 2)),
        assignedDate: now.subtract(const Duration(days: 9)),
        maxGrade: 40,
        instructions: [
          'Compare at least 5 sorting algorithms',
          'Provide Big-O analysis for each',
          'Include experimental results with graphs',
          'Submit as PDF',
        ],
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      AssignmentModel(
        id: '7',
        title: 'Image Processing Assignment',
        description: 'Implement basic image processing filters using OpenCV.',
        courseName: 'Computer Vision',
        courseCode: 'CS420',
        instructorName: 'Dr. Nadia Khaled',
        type: AssignmentType.code,
        status: AssignmentStatus.pending,
        priority: AssignmentPriority.medium,
        dueDate: now.add(const Duration(days: 7)),
        assignedDate: now.subtract(const Duration(days: 3)),
        maxGrade: 60,
        attachments: [
          AssignmentAttachment(
            id: 'att5',
            name: 'Test_Images.zip',
            url: 'https://example.com/images.zip',
            fileType: 'zip',
            fileSize: 5200000,
          ),
        ],
        instructions: [
          'Implement Gaussian blur filter',
          'Implement Sobel edge detection',
          'Implement histogram equalization',
          'Compare results with OpenCV built-in functions',
        ],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      AssignmentModel(
        id: '8',
        title: 'Software Design Presentation',
        description: 'Present your team\'s software architecture design for the semester project.',
        courseName: 'Software Engineering',
        courseCode: 'CS320',
        instructorName: 'Dr. Hany Mahmoud',
        type: AssignmentType.presentation,
        status: AssignmentStatus.late,
        priority: AssignmentPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
        assignedDate: now.subtract(const Duration(days: 14)),
        maxGrade: 25,
        instructions: [
          '15-20 minutes presentation',
          'Include UML diagrams',
          'Explain design patterns used',
          'Q&A session expected',
        ],
        submission: SubmissionModel(
          id: 'sub4',
          submittedAt: now.subtract(const Duration(hours: 6)),
          attachments: [
            AssignmentAttachment(
              id: 'sub_att3',
              name: 'Design_Presentation.pptx',
              url: 'https://example.com/presentation.pptx',
              fileType: 'pptx',
              fileSize: 2800000,
            ),
          ],
          comments: 'Submitted late due to team member illness.',
        ),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }
}
