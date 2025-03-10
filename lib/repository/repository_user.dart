import 'dart:convert';
import 'package:http/http.dart' as http;

import '../login/entities/login.dart';

class RepositoryUser {
  static const String baseUrl = 'http://localhost:8080';

  Future<bool> addNewUser({
    required String name,
    required String email,
    required String password,
  }) async {
    var user = User(name: name, email: email, password: password);

    try{
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8080/add_usuario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if(response.statusCode == 200) {
        return true;
      }
      return false;
    }catch (e){
      return false;
    }
  }


  Future<bool> getLoginUser(
      {required String email, required String password}) async {
    var user = User(email: email, password: password);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('e $e');
      return false;
    }
  }
}
