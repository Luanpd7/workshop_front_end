import 'package:flutter/foundation.dart';

enum UserRole {
  manager,
  mechanic,
}

class AuthProvider with ChangeNotifier {
  UserRole? _currentRole;
  int? _mechanicId;

  UserRole? get currentRole => _currentRole;
  int? get mechanicId => _mechanicId;
  bool get isManager => _currentRole == UserRole.manager;
  bool get isMechanic => _currentRole == UserRole.mechanic;
  bool get isLoggedIn => _currentRole != null;

  void loginAsManager() {
    _currentRole = UserRole.manager;
    _mechanicId = null;
    notifyListeners();
  }

  void loginAsMechanic(int mechanicId) {
    _currentRole = UserRole.mechanic;
    _mechanicId = mechanicId;
    notifyListeners();
  }

  void logout() {
    _currentRole = null;
    _mechanicId = null;
    notifyListeners();
  }
}


