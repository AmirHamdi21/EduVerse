import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks a single logical async request stream for route-owned state managers.
///
/// Starting a new request cancels the previous in-flight Dio request and bumps a
/// version counter so stale responses can be ignored safely.
class RouteRequestController {
  int _version = 0;
  CancelToken? _token;

  int begin() {
    cancel('superseded');
    _token = CancelToken();
    return ++_version;
  }

  CancelToken? get token => _token;

  bool isCurrent(int version) {
    return version == _version && !(_token?.isCancelled ?? false);
  }

  void cancel([String reason = 'cancelled']) {
    _version++;
    final token = _token;
    _token = null;

    if (token != null && !token.isCancelled) {
      token.cancel(reason);
    }
  }
}

mixin SafeRouteCubitMixin<State> on Cubit<State> {
  final Set<RouteRequestController> _routeRequestControllers =
      <RouteRequestController>{};

  T trackRouteRequest<T extends RouteRequestController>(T controller) {
    _routeRequestControllers.add(controller);
    return controller;
  }

  void emitIfOpen(State nextState) {
    if (!isClosed) {
      emit(nextState);
    }
  }

  bool isRequestCurrent(RouteRequestController controller, int version) {
    return !isClosed && controller.isCurrent(version);
  }

  @override
  Future<void> close() async {
    for (final controller in _routeRequestControllers) {
      controller.cancel('cubit_closed');
    }
    _routeRequestControllers.clear();
    await super.close();
  }
}
