/// class responsible for customer info
class Customer {
  Customer(this.name, this.surname, this.whatsapp, this.email, this.document,
      this.observation);

  /// name of customer
  final String name;

  /// surname of customer
  final String surname;

  /// whatsapp of customer
  final String whatsapp;

  /// email of customer
  final String email;

  /// document of customer
  final String document;

  /// observation of customer
  final String observation;

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "surname": surname,
      "whatsapp": whatsapp,
      "email": email,
      "document": document,
      "observation": observation,
    };
  }

  @override
  String toString() {
    return 'Customer{name: $name, surname: $surname, whatsapp: $whatsapp, email: $email, document: $document, observation: $observation}';
  }
}
