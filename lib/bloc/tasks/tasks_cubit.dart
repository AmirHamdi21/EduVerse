import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/models/task_model.dart';
import 'package:edu_verse/bloc/tasks/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(const TasksInitial());

  void loadTasks() {
    try {
      emit(TasksLoading(
        tasks: state.tasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));

      // Simulated tasks data for demo
      final tasks = _generateDemoTasks();

      emit(TasksLoaded(
        tasks: tasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      emit(TasksError(
        message: 'Failed to load tasks: ${e.toString()}',
        tasks: state.tasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void setFilter(TasksFilter filter) {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void clearFilters() {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: const TasksFilter(),
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void setSort(TasksSortBy sortBy, {bool? ascending}) {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: state.filter,
        sortBy: sortBy,
        sortAscending: ascending ?? state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void toggleSortOrder() {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: !state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void setViewMode(TasksViewMode mode) {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: mode,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state is TasksLoaded || state is TasksError) {
      final currentTasks = state.tasks;
      emit(TasksLoaded(
        tasks: currentTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: query,
      ));
    }
  }

  void addTask(TaskModel task) {
    try {
      if (task.title.trim().isEmpty) {
        throw ArgumentError('Task title cannot be empty');
      }
      
      final currentTasks = state.tasks;
      // Check for duplicate IDs
      if (currentTasks.any((t) => t.id == task.id)) {
        throw ArgumentError('Task with this ID already exists');
      }
      
      emit(TasksLoaded(
        tasks: [...currentTasks, task],
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  void updateTask(TaskModel updatedTask) {
    try {
      if (updatedTask.title.trim().isEmpty) {
        throw ArgumentError('Task title cannot be empty');
      }
      
      final currentTasks = state.tasks;
      final taskExists = currentTasks.any((t) => t.id == updatedTask.id);
      
      if (!taskExists) {
        throw ArgumentError('Task not found');
      }
      
      final updatedTasks = currentTasks.map((task) {
        return task.id == updatedTask.id ? updatedTask : task;
      }).toList();
      
      emit(TasksLoaded(
        tasks: updatedTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  void deleteTask(String taskId) {
    try {
      if (taskId.isEmpty) {
        throw ArgumentError('Task ID cannot be empty');
      }
      
      final currentTasks = state.tasks;
      final taskExists = currentTasks.any((t) => t.id == taskId);
      
      if (!taskExists) {
        throw ArgumentError('Task not found');
      }
      
      final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
      
      emit(TasksLoaded(
        tasks: updatedTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  void toggleTaskStatus(String taskId) {
    try {
      if (taskId.isEmpty) {
        throw ArgumentError('Task ID cannot be empty');
      }
      
      final currentTasks = state.tasks;
      final taskExists = currentTasks.any((t) => t.id == taskId);
      
      if (!taskExists) {
        throw ArgumentError('Task not found');
      }
      
      final updatedTasks = currentTasks.map((task) {
        if (task.id == taskId) {
          if (task.status == TaskStatus.completed) {
            return task.copyWith(
              status: TaskStatus.pending,
              clearCompletedAt: true,
            );
          } else {
            return task.copyWith(
              status: TaskStatus.completed,
              completedAt: DateTime.now(),
            );
          }
        }
        return task;
      }).toList();
      
      emit(TasksLoaded(
        tasks: updatedTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  void toggleBookmark(String taskId) {
    try {
      if (taskId.isEmpty) {
        throw ArgumentError('Task ID cannot be empty');
      }
      
      final currentTasks = state.tasks;
      final taskExists = currentTasks.any((t) => t.id == taskId);
      
      if (!taskExists) {
        throw ArgumentError('Task not found');
      }
      
      final updatedTasks = currentTasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(isBookmarked: !task.isBookmarked);
        }
        return task;
      }).toList();
      
      emit(TasksLoaded(
        tasks: updatedTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  void updateTaskProgress(String taskId, TaskStatus newStatus) {
    try {
      if (taskId.isEmpty) {
        throw ArgumentError('Task ID cannot be empty');
      }
      
      final currentTasks = state.tasks;
      final taskExists = currentTasks.any((t) => t.id == taskId);
      
      if (!taskExists) {
        throw ArgumentError('Task not found');
      }
      
      final updatedTasks = currentTasks.map((task) {
        if (task.id == taskId) {
          if (newStatus == TaskStatus.completed) {
            return task.copyWith(
              status: newStatus,
              completedAt: DateTime.now(),
            );
          } else {
            return task.copyWith(
              status: newStatus,
              clearCompletedAt: true,
            );
          }
        }
        return task;
      }).toList();
      
      emit(TasksLoaded(
        tasks: updatedTasks,
        filter: state.filter,
        sortBy: state.sortBy,
        sortAscending: state.sortAscending,
        viewMode: state.viewMode,
        searchQuery: state.searchQuery,
      ));
    } catch (e) {
      rethrow;
    }
  }

  List<TaskModel> _generateDemoTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: '1',
        title: 'Complete Math Assignment',
        description: 'Solve chapters 5-7 problems',
        courseName: 'Advanced Mathematics',
        courseCode: 'MATH301',
        category: TaskCategory.assignment,
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
        estimatedMinutes: 120,
        subtasks: ['Chapter 5', 'Chapter 6', 'Chapter 7'],
        completedSubtasks: ['Chapter 5'],
      ),
      TaskModel(
        id: '2',
        title: 'Physics Lab Report',
        description: 'Write report on wave interference experiment',
        courseName: 'Physics II',
        courseCode: 'PHY202',
        category: TaskCategory.lab,
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        dueDate: now.add(const Duration(hours: 12)),
        createdAt: now.subtract(const Duration(days: 5)),
        estimatedMinutes: 180,
      ),
      TaskModel(
        id: '3',
        title: 'Read Chapter 8 - Data Structures',
        description: 'Binary trees and graph algorithms',
        courseName: 'Computer Science',
        courseCode: 'CS301',
        category: TaskCategory.reading,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 1)),
        estimatedMinutes: 60,
      ),
      TaskModel(
        id: '4',
        title: 'Midterm Exam Preparation',
        description: 'Study chapters 1-6 for the midterm',
        courseName: 'Advanced Mathematics',
        courseCode: 'MATH301',
        category: TaskCategory.exam,
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 7)),
        estimatedMinutes: 480,
        isBookmarked: true,
      ),
      TaskModel(
        id: '5',
        title: 'Group Project Presentation',
        description: 'Prepare slides for the marketing strategy project',
        courseName: 'Business Management',
        courseCode: 'BUS401',
        category: TaskCategory.project,
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 14)),
        estimatedMinutes: 240,
        subtasks: [
          'Research',
          'Draft slides',
          'Add visuals',
          'Practice presentation'
        ],
        completedSubtasks: ['Research', 'Draft slides'],
        isBookmarked: true,
      ),
      TaskModel(
        id: '6',
        title: 'Submit Literature Review',
        description: 'Final review of research papers',
        courseName: 'Research Methods',
        courseCode: 'RES201',
        category: TaskCategory.assignment,
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        dueDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
        completedAt: now.subtract(const Duration(days: 2)),
        estimatedMinutes: 90,
      ),
      TaskModel(
        id: '7',
        title: 'Chemistry Lab Quiz',
        description: 'Online quiz about organic compounds',
        courseName: 'Chemistry',
        courseCode: 'CHE201',
        category: TaskCategory.exam,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
        estimatedMinutes: 45,
      ),
      TaskModel(
        id: '8',
        title: 'Programming Assignment 3',
        description: 'Implement sorting algorithms in Python',
        courseName: 'Computer Science',
        courseCode: 'CS301',
        category: TaskCategory.assignment,
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 6)),
        estimatedMinutes: 150,
        attachmentUrl: 'https://example.com/assignment3.pdf',
      ),
    ];
  }
}
