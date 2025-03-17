import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../login/entities/login.dart';

final Logger _logger = Logger('RepositoryUser');

abstract class IRepositoryUser {

  Future<bool> addNewUser({required User user});

  Future<bool> getLoginUser({required User user});
}

class RepositoryUser implements IRepositoryUser{
  static const String baseUrl = 'http://localhost:8080';

  @override
  Future<bool> addNewUser({
    required User user
  }) async {
    var userBody = jsonEncode(user.toJson());

    try{
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8080/add_usuario'),
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
  Future<bool> getLoginUser(
      {  required User user}) async {
    var userBody = jsonEncode(user.toJson());

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: userBody,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('ERROR : $e');
      return false;
    }
  }
}
