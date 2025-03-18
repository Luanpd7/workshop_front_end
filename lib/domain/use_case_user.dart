import 'package:workshop_front_end/repository/repository_user.dart';
import '../login/entities/login.dart';

class UseCaseUser {
  final IRepositoryUser repository;

  UseCaseUser(this.repository);

  Future<bool> addNewUser({required User user}) =>
      repository.addNewUser(user: user);

  Future<User?> getLoginUser({required User user}) =>
      repository.getLoginUser(user: user);
}
