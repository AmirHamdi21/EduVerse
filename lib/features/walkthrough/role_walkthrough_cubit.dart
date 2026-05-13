import 'dart:async';

import 'package:edu_verse/bloc/auth/auth_bloc.dart';
import 'package:edu_verse/bloc/auth/auth_state.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_bloc.dart';
import 'package:edu_verse/bloc/instructor/instructor_courses_state.dart';
import 'package:edu_verse/bloc/ta/ta_courses_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_courses_state.dart';
import 'package:edu_verse/config/app_router.dart';
import 'package:edu_verse/features/walkthrough/instructor_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/ta_walkthrough_registry.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_service.dart';
import 'package:edu_verse/models/instructor/teaching_course_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleWalkthroughState extends Equatable {
  const RoleWalkthroughState({
    this.isActive = false,
    this.isLoadingPreference = false,
    this.role,
    this.userId,
    this.segmentIndex = 0,
    this.stepIndex = 0,
    this.targetEpoch = 0,
  });

  final bool isActive;
  final bool isLoadingPreference;
  final WalkthroughRole? role;
  final int? userId;
  final int segmentIndex;
  final int stepIndex;
  final int targetEpoch;

  List<WalkthroughSegment> get segments => _segmentsFor(role);

  WalkthroughSegment? get segment {
    final activeSegments = segments;
    if (!isActive ||
        segmentIndex < 0 ||
        segmentIndex >= activeSegments.length) {
      return null;
    }
    return activeSegments[segmentIndex];
  }

  WalkthroughStep? get step {
    final currentSegment = segment;
    if (currentSegment == null ||
        stepIndex < 0 ||
        stepIndex >= currentSegment.steps.length) {
      return null;
    }
    return currentSegment.steps[stepIndex];
  }

  int get totalSteps {
    return segments.fold<int>(0, (sum, segment) => sum + segment.steps.length);
  }

  int get globalStepNumber {
    var number = 0;
    final activeSegments = segments;
    for (var index = 0; index < segmentIndex; index++) {
      number += activeSegments[index].steps.length;
    }
    return number + stepIndex + 1;
  }

  bool get isFirstStep => segmentIndex == 0 && stepIndex == 0;

  bool get isLastStep {
    final activeSegments = segments;
    final currentSegment = segment;
    if (currentSegment == null || activeSegments.isEmpty) return false;
    return segmentIndex == activeSegments.length - 1 &&
        stepIndex == currentSegment.steps.length - 1;
  }

  RoleWalkthroughState copyWith({
    bool? isActive,
    bool? isLoadingPreference,
    WalkthroughRole? role,
    bool clearRole = false,
    int? userId,
    bool clearUserId = false,
    int? segmentIndex,
    int? stepIndex,
    int? targetEpoch,
  }) {
    return RoleWalkthroughState(
      isActive: isActive ?? this.isActive,
      isLoadingPreference: isLoadingPreference ?? this.isLoadingPreference,
      role: clearRole ? null : role ?? this.role,
      userId: clearUserId ? null : userId ?? this.userId,
      segmentIndex: segmentIndex ?? this.segmentIndex,
      stepIndex: stepIndex ?? this.stepIndex,
      targetEpoch: targetEpoch ?? this.targetEpoch,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isActive,
    isLoadingPreference,
    role,
    userId,
    segmentIndex,
    stepIndex,
    targetEpoch,
  ];
}

class RoleWalkthroughCubit extends Cubit<RoleWalkthroughState> {
  RoleWalkthroughCubit({required WalkthroughCompletionService service})
    : _service = service,
      super(const RoleWalkthroughState());

  final WalkthroughCompletionService _service;
  final Map<String, GlobalKey> _targets = <String, GlobalKey>{};
  Timer? _targetRefreshTimer;
  Timer? _scrollTargetTimer;

  void registerTarget(String id, GlobalKey key) {
    _targets[id] = key;
    if (state.step?.targetId == id) {
      _scheduleCurrentTargetScroll(delay: const Duration(milliseconds: 40));
    }
    _refreshTargetSoon();
  }

  void unregisterTarget(String id, GlobalKey key) {
    if (_targets[id] == key) {
      _targets.remove(id);
      _refreshTargetSoon();
    }
  }

  void onSegmentVisible(
    WalkthroughRole role,
    String segmentId,
    BuildContext context,
  ) {
    if (state.isActive) {
      final currentSegment = state.segment;
      if (state.role == role && currentSegment?.id == segmentId) {
        _scheduleCurrentTargetScroll(delay: const Duration(milliseconds: 120));
        _refreshTargetSoon();
      }
      return;
    }

    if (segmentId == _firstSegmentId(role)) {
      unawaited(startIfNeeded(context, role));
    }
  }

  Future<void> startIfNeeded(BuildContext context, WalkthroughRole role) async {
    if (isClosed || state.isActive || state.isLoadingPreference) {
      return;
    }

    final user = _roleUser(context, role);
    if (user == null) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingPreference: true,
        role: role,
        userId: user.userId,
      ),
    );
    final completed = await _service.isCompleted(role, user.userId);
    if (isClosed) return;
    if (completed) {
      emit(
        state.copyWith(
          isLoadingPreference: false,
          isActive: false,
          role: role,
          userId: user.userId,
        ),
      );
      return;
    }

    emit(
      RoleWalkthroughState(
        isActive: true,
        role: role,
        userId: user.userId,
        segmentIndex: 0,
        stepIndex: 0,
        targetEpoch: state.targetEpoch + 1,
      ),
    );
    _scheduleCurrentTargetScroll(delay: const Duration(milliseconds: 120));
  }

  Future<void> next(BuildContext context) async {
    if (!state.isActive) return;
    if (state.isLastStep) {
      await complete(context);
      return;
    }

    final currentSegment = state.segment;
    if (currentSegment == null) return;
    if (state.stepIndex < currentSegment.steps.length - 1) {
      _moveTo(state.segmentIndex, state.stepIndex + 1);
      return;
    }

    final nextIndex = _nextAvailableSegmentIndex(
      context,
      from: state.segmentIndex + 1,
      direction: 1,
    );
    if (nextIndex == null) {
      await complete(context);
      return;
    }

    final route = _routeForSegment(context, nextIndex);
    if (route == null) {
      await complete(context);
      return;
    }
    _moveTo(nextIndex, 0);
    AppRouter.router.go(route);
  }

  void previous(BuildContext context) {
    if (!state.isActive || state.isFirstStep) return;

    if (state.stepIndex > 0) {
      _moveTo(state.segmentIndex, state.stepIndex - 1);
      return;
    }

    final previousIndex = _nextAvailableSegmentIndex(
      context,
      from: state.segmentIndex - 1,
      direction: -1,
    );
    if (previousIndex == null) return;

    final previousSegment = state.segments[previousIndex];
    final route = _routeForSegment(context, previousIndex);
    if (route == null) return;
    _moveTo(previousIndex, previousSegment.steps.length - 1);
    AppRouter.router.go(route);
  }

  Future<void> skip(BuildContext context) async {
    await _finish(context);
  }

  Future<void> complete(BuildContext context) async {
    await _finish(context);
  }

  void cancelActive() {
    if (!state.isActive && !state.isLoadingPreference) return;
    emit(const RoleWalkthroughState());
  }

  Rect? targetRect(String targetId) {
    final key = _targets[targetId];
    final targetContext = key?.currentContext;
    if (targetContext == null) return null;
    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  Future<void> _finish(BuildContext context) async {
    final role = state.role;
    final userId = state.userId ?? _roleUser(context, role)?.userId;
    if (role != null && userId != null && userId > 0) {
      await _service.markCompleted(role, userId);
    }
    if (isClosed) return;
    emit(const RoleWalkthroughState());
  }

  void _moveTo(int segmentIndex, int stepIndex) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isActive: true,
        isLoadingPreference: false,
        segmentIndex: segmentIndex,
        stepIndex: stepIndex,
        targetEpoch: state.targetEpoch + 1,
      ),
    );
    _scheduleCurrentTargetScroll(delay: const Duration(milliseconds: 80));
    _refreshTargetSoon();
  }

  int? _nextAvailableSegmentIndex(
    BuildContext context, {
    required int from,
    required int direction,
  }) {
    var index = from;
    while (index >= 0 && index < state.segments.length) {
      final route = _routeForSegment(context, index);
      if (route != null) return index;
      index += direction;
    }
    return null;
  }

  String? _routeForSegment(BuildContext context, int segmentIndex) {
    final role = state.role;
    if (role == null) return null;
    final segment = _segmentsFor(role)[segmentIndex];
    if (!segment.needsCourse) {
      return segment.route;
    }

    return switch (role) {
      WalkthroughRole.instructor => _instructorCourseRoute(context),
      WalkthroughRole.ta => _taCourseRoute(context),
    };
  }

  String? _instructorCourseRoute(BuildContext context) {
    final coursesState = context.read<InstructorCoursesBloc>().state;
    if (coursesState is! InstructorCoursesLoaded ||
        coursesState.courses.isEmpty) {
      return null;
    }
    final courseId = coursesState.courses.first.courseId;
    if (courseId <= 0) return null;
    return '/instructor/courses/$courseId';
  }

  String? _taCourseRoute(BuildContext context) {
    final coursesState = context.read<TACoursesCubit>().state.coursesStatus;
    if (coursesState is! TASubTabLoaded<List<TeachingCourseModel>> ||
        coursesState.data.isEmpty) {
      return null;
    }
    final courseId = coursesState.data.first.courseId;
    if (courseId <= 0) return null;
    return '/ta/course/$courseId';
  }

  ({int userId})? _roleUser(BuildContext context, WalkthroughRole? role) {
    if (role == null) return null;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    final hasRole = authState.user.roles.any((roleModel) {
      final normalized = roleModel.roleName.trim().toLowerCase();
      return switch (role) {
        WalkthroughRole.instructor =>
          normalized == 'instructor' ||
              normalized == 'teacher' ||
              normalized == 'faculty',
        WalkthroughRole.ta =>
          normalized == 'ta' ||
              normalized == 'teaching_assistant' ||
              normalized == 'teaching assistant',
      };
    });
    if (!hasRole || authState.user.userId <= 0) return null;
    return (userId: authState.user.userId);
  }

  void _refreshTargetSoon() {
    if (isClosed || !state.isActive) return;
    _targetRefreshTimer?.cancel();
    _targetRefreshTimer = Timer(const Duration(milliseconds: 90), () {
      if (isClosed || !state.isActive) return;
      emit(state.copyWith(targetEpoch: state.targetEpoch + 1));
    });
  }

  void _scheduleCurrentTargetScroll({Duration delay = Duration.zero}) {
    if (isClosed || !state.isActive) return;
    _scrollTargetTimer?.cancel();
    _scrollTargetTimer = Timer(delay, () {
      if (isClosed || !state.isActive) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed || !state.isActive) return;
        unawaited(_scrollCurrentTargetIntoView());
      });
    });
  }

  Future<void> _scrollCurrentTargetIntoView() async {
    final step = state.step;
    if (step == null) return;

    final targetContext = _targets[step.targetId]?.currentContext;
    if (targetContext == null) {
      _refreshTargetSoon();
      return;
    }

    try {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: _targetScrollAlignment(step),
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      return;
    }

    if (isClosed || !state.isActive) return;
    emit(state.copyWith(targetEpoch: state.targetEpoch + 1));
  }

  double _targetScrollAlignment(WalkthroughStep step) {
    if (step.shape == WalkthroughTargetShape.circle ||
        step.targetId.endsWith('.create') ||
        step.targetId.endsWith('.composer')) {
      return 0.72;
    }
    return 0.24;
  }

  @override
  Future<void> close() {
    _targetRefreshTimer?.cancel();
    _scrollTargetTimer?.cancel();
    return super.close();
  }
}

List<WalkthroughSegment> _segmentsFor(WalkthroughRole? role) {
  return switch (role) {
    WalkthroughRole.instructor => InstructorWalkthroughRegistry.segments,
    WalkthroughRole.ta => TAWalkthroughRegistry.segments,
    null => const <WalkthroughSegment>[],
  };
}

String _firstSegmentId(WalkthroughRole role) {
  return switch (role) {
    WalkthroughRole.instructor => InstructorWalkthroughIds.dashboard,
    WalkthroughRole.ta => TAWalkthroughIds.dashboard,
  };
}
