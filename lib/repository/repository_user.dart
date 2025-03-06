import 'dart:convert';
import 'package:http/http.dart' as http;

import '../login/entities/login.dart';

class RepositoryUser{
     Future<bool> getLoginUser({ required String email, required String password}) async {

       var user = LoginUser(
         email: email,
         password: password
       );

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
 }