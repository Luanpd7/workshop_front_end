import 'address.dart';

/// class responsible for customer info
class Customer {
  Customer(
      {this.name,
      this.surname,
      this.whatsapp,
      this.email,
      this.document,
      this.observation,
      this.address});

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
    final customerData = json['Customer'];


    return Customer(
      name: customerData['name'],
      surname: customerData['surname'],
      email: customerData['email'],
      whatsapp: customerData['whatsapp'],
      document: customerData['document'],
      observation: customerData['observation'],
      address: customerData['address'] != null ? Address.fromJson(customerData['address']) : null,
    );
  }


  @override
  String toString() {
    return 'Customer{name: $name, surname: $surname, whatsapp: $whatsapp, email: $email, document: $document, observation: $observation}';
  }
}
