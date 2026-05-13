import 'package:edu_verse/features/walkthrough/role_walkthrough_cubit.dart';
import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalkthroughTarget extends StatefulWidget {
  const WalkthroughTarget({
    super.key,
    required this.id,
    required this.child,
    this.shape = WalkthroughTargetShape.roundedRect,
    this.padding = const EdgeInsets.all(8),
  });

  final String id;
  final Widget child;
  final WalkthroughTargetShape shape;
  final EdgeInsets padding;

  @override
  State<WalkthroughTarget> createState() => _WalkthroughTargetState();
}

class _WalkthroughTargetState extends State<WalkthroughTarget> {
  final GlobalKey _targetKey = GlobalKey();
  RoleWalkthroughCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<RoleWalkthroughCubit>();
    if (_cubit != cubit) {
      _cubit?.unregisterTarget(widget.id, _targetKey);
      _cubit = cubit;
    }
    cubit.registerTarget(widget.id, _targetKey);
  }

  @override
  void didUpdateWidget(covariant WalkthroughTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _cubit?.unregisterTarget(oldWidget.id, _targetKey);
      _cubit?.registerTarget(widget.id, _targetKey);
    }
  }

  @override
  void dispose() {
    _cubit?.unregisterTarget(widget.id, _targetKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _targetKey, child: widget.child);
  }
}

class InstructorWalkthroughRouteMarker extends StatefulWidget {
  const InstructorWalkthroughRouteMarker({
    super.key,
    required this.segmentId,
    required this.child,
  });

  final String segmentId;
  final Widget child;

  @override
  State<InstructorWalkthroughRouteMarker> createState() =>
      _InstructorWalkthroughRouteMarkerState();
}

class TAWalkthroughRouteMarker extends StatefulWidget {
  const TAWalkthroughRouteMarker({
    super.key,
    required this.segmentId,
    required this.child,
  });

  final String segmentId;
  final Widget child;

  @override
  State<TAWalkthroughRouteMarker> createState() =>
      _TAWalkthroughRouteMarkerState();
}

class _InstructorWalkthroughRouteMarkerState
    extends _RoleWalkthroughRouteMarkerState<InstructorWalkthroughRouteMarker> {
  _InstructorWalkthroughRouteMarkerState() : super(WalkthroughRole.instructor);
}

class _TAWalkthroughRouteMarkerState
    extends _RoleWalkthroughRouteMarkerState<TAWalkthroughRouteMarker> {
  _TAWalkthroughRouteMarkerState() : super(WalkthroughRole.ta);
}

abstract class _RoleWalkthroughRouteMarkerState<T extends StatefulWidget>
    extends State<T> {
  _RoleWalkthroughRouteMarkerState(this.role);

  final WalkthroughRole role;

  String get _segmentId {
    final widget = this.widget;
    if (widget is InstructorWalkthroughRouteMarker) return widget.segmentId;
    if (widget is TAWalkthroughRouteMarker) return widget.segmentId;
    throw StateError('Unsupported walkthrough marker');
  }

  Widget get _child {
    final widget = this.widget;
    if (widget is InstructorWalkthroughRouteMarker) return widget.child;
    if (widget is TAWalkthroughRouteMarker) return widget.child;
    throw StateError('Unsupported walkthrough marker');
  }

  @override
  void initState() {
    super.initState();
    _notifyVisible();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSegmentId = oldWidget is InstructorWalkthroughRouteMarker
        ? oldWidget.segmentId
        : oldWidget is TAWalkthroughRouteMarker
        ? oldWidget.segmentId
        : null;
    if (oldSegmentId != _segmentId) {
      _notifyVisible();
    }
  }

  void _notifyVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RoleWalkthroughCubit>().onSegmentVisible(
        role,
        _segmentId,
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) => _child;
}
