import 'package:equatable/equatable.dart';

import '../../../../models/core/course_model.dart';
import '../../../../models/core/course_structure_model.dart';
import '../../../../models/materials/course_material_model.dart';
import '../../../../models/materials/material_bundle_model.dart';

class CourseDetailState extends Equatable {
  final CourseModel? course;
  final List<CourseStructureModel> structure;
  final List<CourseMaterialModel> materials;
  final Map<String, MaterialBundleModel> bundles;
  final int selectedWeekIndex;
  final bool isLoadingStructure;
  final bool isLoadingMaterials;
  final String? error;
  final int selectedTabIndex;

  const CourseDetailState({
    this.course,
    this.structure = const <CourseStructureModel>[],
    this.materials = const <CourseMaterialModel>[],
    this.bundles = const <String, MaterialBundleModel>{},
    this.selectedWeekIndex = 0,
    this.isLoadingStructure = false,
    this.isLoadingMaterials = false,
    this.error,
    this.selectedTabIndex = 0,
  });

  CourseDetailState copyWith({
    CourseModel? course,
    List<CourseStructureModel>? structure,
    List<CourseMaterialModel>? materials,
    Map<String, MaterialBundleModel>? bundles,
    int? selectedWeekIndex,
    bool? isLoadingStructure,
    bool? isLoadingMaterials,
    String? error,
    bool clearError = false,
    int? selectedTabIndex,
  }) {
    return CourseDetailState(
      course: course ?? this.course,
      structure: structure ?? this.structure,
      materials: materials ?? this.materials,
      bundles: bundles ?? this.bundles,
      selectedWeekIndex: selectedWeekIndex ?? this.selectedWeekIndex,
      isLoadingStructure: isLoadingStructure ?? this.isLoadingStructure,
      isLoadingMaterials: isLoadingMaterials ?? this.isLoadingMaterials,
      error: clearError ? null : (error ?? this.error),
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  bool get isLoading => isLoadingStructure || isLoadingMaterials;

  @override
  List<Object?> get props => <Object?>[
    course,
    structure,
    materials,
    bundles,
    selectedWeekIndex,
    isLoadingStructure,
    isLoadingMaterials,
    error,
    selectedTabIndex,
  ];
}
