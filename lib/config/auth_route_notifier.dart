import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';

enum AuthRouteStatus { unknown, authenticated, unauthenticated }

class AuthRouteNotifier extends ChangeNotifier {
  AuthRouteStatus _status = AuthRouteStatus.unknown;
  UserDto? _user;

  AuthRouteStatus get status => _status;
  UserDto? get user => _user;

  void setAuthenticated(UserDto user) {
    _status = AuthRouteStatus.authenticated;
    _user = user;
    notifyListeners();
  }

  void setUnauthenticated() {
    _status = AuthRouteStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }
}

final AuthRouteNotifier authRouteNotifier = AuthRouteNotifier();
