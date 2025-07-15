import 'address.dart';

/// class responsible for customer info
class Customer {
  Customer(
      {this.id,
      this.name,
      this.surname,
      this.whatsapp,
      this.email,
      this.document,
      this.observation,
      this.address});

  final int? id;

  /// name of customer
  final String? name;

  /// surname of customer
  final String? surname;

  /// whatsapp of customer
  final String? whatsapp;

  /// email of customer
  final String? email;

  /// document of customer
  final String? document;

  /// observation of customer
  final String? observation;

  /// address of customer
  final Address? address;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "surname": surname,
      "whatsapp": whatsapp,
      "email": email,
      "document": document,
      "observation": observation,
      "address": address,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      whatsapp: json['whatsapp'],
      document: json['document'],
      observation: json['observation'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }


  @override
  String toString() {
    return 'Customer{id: $id, name: $name, surname: $surname, whatsapp: $whatsapp, email: $email, document: $document, observation: $observation, address: $address}';
  }
}
