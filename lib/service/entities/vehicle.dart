class VehicleType {
  final int id;
  final String? name;

  VehicleType({required this.id, this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}



class Vehicle {
  final int? id;
  final String model;
  final String brand;
  final String color;
  final String plate;
  final int manufactureYear;
  final int type;
  final int idCustomer;

  Vehicle({
    this.id,
    required this.model,
    required this.brand,
    required this.color,
    required this.plate,
    required this.manufactureYear,
    required this.type,
    required this.idCustomer,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      model: json['model'],
      brand: json['brand'],
      color: json['color'],
      plate: json['plate'],
      manufactureYear: json['manufacture_year'],
      type: json['vehicle_type_id'],
      idCustomer: json['id_customer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'brand': brand,
      'color': color,
      'plate': plate,
      'manufacture_year': manufactureYear,
      'vehicle_type_id': type,
      'id_customer': idCustomer,
    };
  }

  @override
  String toString() {
    return 'Vehicle{ id $id model: $model, color: $color, plate: $plate, manufactureYear: $manufactureYear, type: $type, }';
  }
}


