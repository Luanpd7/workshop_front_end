class LoginUser {

  LoginUser({ this.email,  this.password,  this.name});


  final String? name;
  final String? email;
  final String? password;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      'email': email,
      'password': password
    };
  }
}