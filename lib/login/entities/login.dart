class User {

  User({ this.email,  this.password,  this.name});


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

  @override
  String toString() {
    return 'User{name: $name, email: $email, password: $password}';
  }
}