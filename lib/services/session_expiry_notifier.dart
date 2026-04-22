import 'dart:async';

class SessionExpiryNotifier {
  SessionExpiryNotifier._();

  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static DateTime? _lastNotificationAt;

  static Stream<String> get stream => _controller.stream;

  static void notify([
    String message = 'Session expired — please sign in again',
  ]) {
    final now = DateTime.now();
    final last = _lastNotificationAt;
    if (last != null && now.difference(last).inMilliseconds < 1500) {
      return;
    }

    _lastNotificationAt = now;
    if (!_controller.isClosed) {
      _controller.add(message);
    }
  }
}
