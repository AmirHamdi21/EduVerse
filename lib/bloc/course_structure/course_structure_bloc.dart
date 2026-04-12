import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/api/course_service.dart';
import 'course_structure_event.dart';
import 'course_structure_state.dart';

class CourseStructureBloc
    extends Bloc<CourseStructureEvent, CourseStructureState> {
  final CourseService _courseService;

  CourseStructureBloc({required CourseService courseService})
    : _courseService = courseService,
      super(const CourseStructureInitial()) {
    on<LoadStructure>(_onLoadStructure);
    on<CreateStructureItem>(_onCreateItem);
    on<UpdateStructureItem>(_onUpdateItem);
    on<DeleteStructureItem>(_onDeleteItem);
    on<ReorderStructureItems>(_onReorderItems);
  }

  Future<void> _onLoadStructure(
    LoadStructure event,
    Emitter<CourseStructureState> emit,
  ) async {
    emit(const StructureLoading());

    try {
      final items = await _courseService.getStructure(event.courseId);
      emit(StructureLoaded(courseId: event.courseId, items: items));
    } catch (error) {
      emit(StructureError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateItem(
    CreateStructureItem event,
    Emitter<CourseStructureState> emit,
  ) async {
    try {
      await _courseService
          .createStructureItem(event.courseId, <String, dynamic>{
            'title': event.title,
            'weekNumber': event.weekNumber,
            if (event.description != null && event.description!.isNotEmpty)
              'description': event.description,
          });
      add(LoadStructure(event.courseId));
    } catch (error) {
      emit(StructureError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateItem(
    UpdateStructureItem event,
    Emitter<CourseStructureState> emit,
  ) async {
    try {
      await _courseService.updateStructureItem(
        event.courseId,
        event.itemId,
        event.payload,
      );
      add(LoadStructure(event.courseId));
    } catch (error) {
      emit(StructureError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteItem(
    DeleteStructureItem event,
    Emitter<CourseStructureState> emit,
  ) async {
    try {
      await _courseService.deleteStructureItem(event.courseId, event.itemId);
      add(LoadStructure(event.courseId));
    } catch (error) {
      emit(StructureError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onReorderItems(
    ReorderStructureItems event,
    Emitter<CourseStructureState> emit,
  ) async {
    try {
      await _courseService.reorderStructureItems(event.courseId, event.itemIds);
      add(LoadStructure(event.courseId));
    } catch (error) {
      emit(StructureError(error.toString().replaceAll('Exception: ', '')));
    }
  }
}
