import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../login/entities/login.dart';

final Logger _logger = Logger('RepositoryUser');

abstract class IRepositoryUser {

  Future<bool> addNewUser({required User user});

  Future<User?> getLoginUser({required User user});
}

class RepositoryUser implements IRepositoryUser{
  static const String baseUrl = 'http://192.168.1.11:8080';

  @override
  Future<bool> addNewUser({
    required User user
  }) async {
    var userBody = jsonEncode(user.toJson());

    try{
      final response = await http.post(
        Uri.parse('$baseUrl/add_usuario'),
        headers: {'Content-Type': 'application/json'},
        body: userBody,
      );

      if(response.statusCode == 200) {
        return true;
      }
      return false;
    }catch (e){
      _logger.severe('ERROR : $e');
      return false;
    }
  }


  @override
  Future<User?> getLoginUser(
      {  required User user}) async {
    var userBody = jsonEncode(user.toJson());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: userBody,
      );


      if (response.statusCode == 200) {

        var body = jsonDecode(response.body);
        var userData = body['user'];
        return User.fromJson(userData);
      }

    } catch (e) {
      _logger.severe('ERROR : $e');
    }
    return null;
  }
}
