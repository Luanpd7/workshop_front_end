/// class responsible for address of customer
class Address{

  Address(this.cep, this.city, this.neighborhood, this.road, this.number);

  /// cep of customer
  final String cep;

  /// city of customer
  final String city;

  /// neighborhood of customer
  final String neighborhood;

  /// road of customer
  final String road;

  /// number of customer
  final String number;

  Map<String, dynamic> toJson() {
    return {
      "cep": cep,
      "city": city,
      "neighborhood": neighborhood,
      "road": road,
      "number": number,
    };
  }

  @override
  String toString() {
    return 'Address{cep: $cep, city: $city, neighborhood: $neighborhood, road: $road, number: $number}';
  }
}