/// Classe responsável por tornar o id do usuário principal
class UserContext {
  static final UserContext _instance = UserContext._internal();

  factory UserContext() {
    return _instance;
  }

  UserContext._internal();

  int? _currentUserId;

  int? get id => _currentUserId;


  set id(int? userId) {
    _currentUserId = userId;
  }

  void clearId() {
    _currentUserId = null;
  }
}