class Client {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final DateTime registrationDate;

  Client({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.registrationDate,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    DateTime? registrationDate,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}
