import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/labs/lab_model.dart';
import 'labs_state.dart';

class LabsCubit extends Cubit<LabsState> {
  LabsCubit() : super(const LabsState());

  Future<void> loadLabs() async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final labs = _generateDemoLabs();
      emit(state.copyWith(labs: labs, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load labs: ${e.toString()}',
      ));
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilter(LabsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void clearFilters() {
    emit(state.copyWith(filter: const LabsFilter()));
  }

  void setSortBy(LabsSortBy sortBy) {
    if (state.sortBy == sortBy) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortBy: sortBy, sortAscending: true));
    }
  }

  void setViewMode(LabsViewMode viewMode) {
    emit(state.copyWith(viewMode: viewMode));
  }

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void toggleBookmark(String labId) {
    try {
      final labs = state.labs.map((lab) {
        if (lab.id == labId) {
          return lab.copyWith(isBookmarked: !lab.isBookmarked);
        }
        return lab;
      }).toList();
      emit(state.copyWith(labs: labs));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle bookmark'));
      rethrow;
    }
  }

  void updateLabStatus(String labId, LabStatus status) {
    try {
      final index = state.labs.indexWhere((l) => l.id == labId);
      if (index == -1) {
        throw Exception('Lab not found');
      }

      final labs = List<LabModel>.from(state.labs);
      labs[index] = labs[index].copyWith(status: status);
      emit(state.copyWith(labs: labs));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update lab status'));
      rethrow;
    }
  }

  void submitLabReport(String labId, String reportUrl) {
    try {
      final index = state.labs.indexWhere((l) => l.id == labId);
      if (index == -1) {
        throw Exception('Lab not found');
      }

      final labs = List<LabModel>.from(state.labs);
      labs[index] = labs[index].copyWith(
        reportUrl: reportUrl,
        status: LabStatus.completed,
      );
      emit(state.copyWith(labs: labs));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to submit report'));
      rethrow;
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  List<LabModel> _generateDemoLabs() {
    final now = DateTime.now();
    return [
      LabModel(
        id: '1',
        title: 'Database Design Lab',
        description: 'Hands-on practice with ER diagrams and normalization techniques',
        courseName: 'Database Systems',
        courseCode: 'CS301',
        instructorName: 'Dr. Ahmed Hassan',
        type: LabType.physical,
        status: LabStatus.upcoming,
        scheduledDate: now.add(const Duration(days: 2, hours: 10)),
        duration: const Duration(hours: 2),
        location: 'Lab Building A, Room 105',
        materials: ['Laptop', 'MySQL Workbench', 'Lab Manual Chapter 4'],
        objectives: [
          'Create ER diagrams for given scenarios',
          'Apply normalization rules (1NF, 2NF, 3NF)',
          'Design efficient database schemas',
        ],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      LabModel(
        id: '2',
        title: 'Machine Learning Practical',
        description: 'Implementing neural networks using TensorFlow',
        courseName: 'Machine Learning',
        courseCode: 'CS401',
        instructorName: 'Dr. Sarah Mohamed',
        type: LabType.virtual,
        status: LabStatus.inProgress,
        scheduledDate: now.subtract(const Duration(hours: 1)),
        duration: const Duration(hours: 3),
        virtualLink: 'https://meet.google.com/abc-defg-hij',
        materials: ['Python 3.9+', 'TensorFlow 2.x', 'Jupyter Notebook'],
        objectives: [
          'Build a simple neural network',
          'Train model on MNIST dataset',
          'Evaluate model performance',
        ],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      LabModel(
        id: '3',
        title: 'Network Security Lab',
        description: 'Practicing firewall configuration and intrusion detection',
        courseName: 'Network Security',
        courseCode: 'CS450',
        instructorName: 'Prof. Omar Ali',
        type: LabType.hybrid,
        status: LabStatus.upcoming,
        scheduledDate: now.add(const Duration(days: 5, hours: 14)),
        duration: const Duration(hours: 2, minutes: 30),
        location: 'Security Lab, Building C',
        virtualLink: 'https://zoom.us/j/123456789',
        materials: ['Wireshark', 'VirtualBox', 'Kali Linux VM'],
        objectives: [
          'Configure iptables firewall rules',
          'Set up Snort IDS',
          'Analyze network traffic',
        ],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabModel(
        id: '4',
        title: 'Operating Systems Lab',
        description: 'Process scheduling algorithms implementation',
        courseName: 'Operating Systems',
        courseCode: 'CS302',
        instructorName: 'Dr. Fatma Ibrahim',
        type: LabType.physical,
        status: LabStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 3)),
        duration: const Duration(hours: 2),
        location: 'Lab Building B, Room 201',
        materials: ['C Compiler', 'Linux Environment'],
        objectives: [
          'Implement FCFS scheduling',
          'Implement Round Robin scheduling',
          'Compare algorithm performance',
        ],
        grade: 18,
        maxGrade: 20,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      LabModel(
        id: '5',
        title: 'Web Development Workshop',
        description: 'Building responsive web applications with React',
        courseName: 'Web Technologies',
        courseCode: 'CS350',
        instructorName: 'Eng. Youssef Kamal',
        type: LabType.virtual,
        status: LabStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 7)),
        duration: const Duration(hours: 3),
        virtualLink: 'https://teams.microsoft.com/l/meetup-join/...',
        materials: ['Node.js', 'React', 'VS Code'],
        objectives: [
          'Set up React development environment',
          'Create functional components',
          'Implement state management',
        ],
        grade: 25,
        maxGrade: 25,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      LabModel(
        id: '6',
        title: 'Data Structures Implementation',
        description: 'Implementing tree and graph data structures',
        courseName: 'Data Structures',
        courseCode: 'CS201',
        instructorName: 'Dr. Mohamed Saleh',
        type: LabType.physical,
        status: LabStatus.missed,
        scheduledDate: now.subtract(const Duration(days: 10)),
        duration: const Duration(hours: 2),
        location: 'Lab Building A, Room 102',
        materials: ['Java SDK', 'Eclipse IDE'],
        objectives: [
          'Implement binary search tree',
          'Implement graph traversal algorithms',
        ],
        createdAt: now.subtract(const Duration(days: 17)),
      ),
      LabModel(
        id: '7',
        title: 'Computer Vision Lab',
        description: 'Image processing and object detection',
        courseName: 'Computer Vision',
        courseCode: 'CS420',
        instructorName: 'Dr. Nadia Khaled',
        type: LabType.virtual,
        status: LabStatus.upcoming,
        scheduledDate: now.add(const Duration(days: 1, hours: 9)),
        duration: const Duration(hours: 2, minutes: 30),
        virtualLink: 'https://meet.google.com/xyz-uvwx-yz',
        materials: ['OpenCV', 'Python', 'Sample Images Dataset'],
        objectives: [
          'Apply image filters',
          'Implement edge detection',
          'Basic object detection',
        ],
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      LabModel(
        id: '8',
        title: 'Software Testing Lab',
        description: 'Unit testing and test-driven development',
        courseName: 'Software Engineering',
        courseCode: 'CS320',
        instructorName: 'Dr. Hany Mahmoud',
        type: LabType.physical,
        status: LabStatus.upcoming,
        scheduledDate: now.add(const Duration(days: 4, hours: 11)),
        duration: const Duration(hours: 2),
        location: 'Lab Building A, Room 108',
        materials: ['JUnit', 'Mockito', 'IntelliJ IDEA'],
        objectives: [
          'Write unit tests',
          'Practice TDD methodology',
          'Achieve code coverage targets',
        ],
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }
}
