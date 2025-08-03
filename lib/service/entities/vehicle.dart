class VehicleType {
  final int id;
  final String name;

  VehicleType({
    required this.id,
    required this.name,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'VehicleType{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is VehicleType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}



class Vehicle {
  final int? id;
  final String model;
  final String color;
  final String plate;
  final int manufactureYear;
  final int type;

  Vehicle({
    this.id,
    required this.model,
    required this.color,
    required this.plate,
    required this.manufactureYear,
    required this.type,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      model: json['model'],
      color: json['color'],
      plate: json['plate'],
      manufactureYear: json['manufacture_year'],
      type: json['vehicle_type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'color': color,
      'plate': plate,
      'manufacture_year': manufactureYear,
      'vehicle_type_id': type,
    };
  }

  @override
  String toString() {
    return 'Vehicle{ id $id model: $model, color: $color, plate: $plate, manufactureYear: $manufactureYear, type: $type, }';
  }
}


