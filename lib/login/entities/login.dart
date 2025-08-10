class User {

  User({this.id, this.email,  this.password,  this.name});


  final int? id;
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  @override
  String toString() {
    return 'User{id $id, name: $name, email: $email, password: $password}';
  }
}

class UserRanking {
  UserRanking({ this.name, this.serviceLength});

  final String? name;
  final String? serviceLength;


  factory UserRanking.fromJson(Map<String, dynamic> json) {
    return UserRanking(
      name: json['name'],
      serviceLength: json['serviceLength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      'serviceLength': serviceLength,
    };
  }
}