class VehicleType {
  final int id;
  final String name;

  VehicleType({required this.id, required this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}



class Vehicle {
  final String model;
  final String color;
  final String plate;
  final int manufactureYear;
  final VehicleType type;

  Vehicle({
    required this.model,
    required this.color,
    required this.plate,
    required this.manufactureYear,
    required this.type,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      model: json['model'],
      color: json['color'],
      plate: json['plate'],
      manufactureYear: json['manufacture_year'],
      type: VehicleType.fromJson(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'color': color,
      'plate': plate,
      'manufacture_year': manufactureYear,
      'type': type.toJson(),
    };
  }
}

