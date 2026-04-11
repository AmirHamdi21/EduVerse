import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/api/course_service.dart';
import '../../../../services/api/material_service.dart';
import '../../../../models/materials/course_material_model.dart';
import '../../../../models/materials/material_bundle_model.dart';
import 'course_detail_event.dart';
import 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final CourseService _courseService;
  final MaterialService _materialService;

  CourseDetailBloc({
    required CourseService courseService,
    required MaterialService materialService,
  }) : _courseService = courseService,
       _materialService = materialService,
       super(const CourseDetailState()) {
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadStructure>(_onLoadStructure);
    on<LoadMaterials>(_onLoadMaterials);
    on<ExpandWeek>(_onExpandWeek);
    on<SwitchTab>(_onSwitchTab);
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetail event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTabIndex: event.initialTabIndex,
        isLoadingStructure: true,
        isLoadingMaterials: true,
        clearError: true,
      ),
    );

    await Future.wait<void>(<Future<void>>[
      _fetchStructure(event.courseId, emit),
      _fetchMaterials(event.courseId, emit),
    ]);
  }

  Future<void> _onLoadStructure(
    LoadStructure event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingStructure: true, clearError: true));
    await _fetchStructure(event.courseId, emit);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingMaterials: true, clearError: true));
    await _fetchMaterials(event.courseId, emit, weekNumber: event.weekNumber);
  }

  void _onExpandWeek(ExpandWeek event, Emitter<CourseDetailState> emit) {
    emit(state.copyWith(selectedWeekIndex: event.weekIndex));
  }

  void _onSwitchTab(SwitchTab event, Emitter<CourseDetailState> emit) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  Future<void> _fetchStructure(
    dynamic courseId,
    Emitter<CourseDetailState> emit,
  ) async {
    try {
      final structure = await _courseService.getCourseStructure(courseId);
      emit(
        state.copyWith(
          structure: structure,
          isLoadingStructure: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingStructure: false, error: _toMessage(e)));
    }
  }

  Future<void> _fetchMaterials(
    dynamic courseId,
    Emitter<CourseDetailState> emit, {
    int? weekNumber,
  }) async {
    try {
      final materials = await _materialService.getMaterials(
        courseId,
        weekNumber: weekNumber,
      );

      final merged = _mergeMaterials(
        existing: state.materials,
        incoming: materials,
      );

      emit(
        state.copyWith(
          materials: merged,
          bundles: MaterialBundleModel.detectBundles(merged),
          isLoadingMaterials: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMaterials: false, error: _toMessage(e)));
    }
  }

  List<CourseMaterialModel> _mergeMaterials({
    required List<CourseMaterialModel> existing,
    required List<CourseMaterialModel> incoming,
  }) {
    if (existing.isEmpty) {
      return incoming;
    }

    final map = <String, CourseMaterialModel>{
      for (final material in existing) material.materialId: material,
    };

    for (final material in incoming) {
      map[material.materialId] = material;
    }

    final merged = map.values.toList();
    merged.sort((a, b) {
      final weekCompare = (a.weekNumber ?? 0).compareTo(b.weekNumber ?? 0);
      if (weekCompare != 0) return weekCompare;
      return (a.orderIndex ?? 0).compareTo(b.orderIndex ?? 0);
    });

    return merged;
  }

  String _toMessage(Object error) {
    final raw = error.toString();
    return raw
        .replaceAll('Exception: ', '')
        .replaceAll('DioException ', '')
        .trim();
  }
}
