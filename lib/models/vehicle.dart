class Vehicle {
  final int? id;
  final int clientId;
  final String brand;
  final String model;
  final int year;
  final String? color;
  final String? plate;

  Vehicle({
    this.id,
    required this.clientId,
    required this.brand,
    required this.model,
    required this.year,
    this.color,
    this.plate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int?,
      clientId: json['clientId'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String?,
      plate: json['plate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plate': plate,
    };
  }

  Vehicle copyWith({
    int? id,
    int? clientId,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? plate,
  }) {
    return Vehicle(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plate: plate ?? this.plate,
    );
  }

  String get displayName => '$brand $model ($year)';
  String get plateDisplay => plate ?? 'Sem placa';
  String get colorDisplay => color ?? 'Não informada';
}
