
import 'package:flutter/services.dart';




class Service {
  final int? id;
  final int? idUser;
  final int customerId;
  final int vehicleId;
  final List<int> observationIds;
  final List<int> purchaseItemIds;
  final int status;
  final DateTime entryDate;
  final String? imageBytes;

  Service({
    this.id,
    this.idUser,
    required this.customerId,
    required this.vehicleId,
    required this.observationIds,
    required this.purchaseItemIds,
    required this.status,
    required this.entryDate,
    this.imageBytes,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      idUser: json['idUser'],
      customerId: json['customerId'],
      vehicleId: json['vehicleId'],
      observationIds: List<int>.from(json['observationIds']),
      purchaseItemIds: List<int>.from(json['purchaseItemIds']),
      status: json['status'],
      entryDate: DateTime.parse(json['entryDate']),
      imageBytes: json['imageBytes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'observationIds': observationIds,
      'purchaseItemIds': purchaseItemIds,
      'status': status,
      'entryDate': entryDate.toIso8601String(),
      'imageBytes': imageBytes,
    };
  }

  @override
  String toString() {
    return 'Service{customerId: $customerId, vehicleId: $vehicleId, '
        'observationIds: $observationIds, purchaseItemIds: $purchaseItemIds, '
        'status: $status, entryDate: $entryDate, '
        'imageBytes: ${imageBytes != null ? 'Yes (length: ${imageBytes!.length})' : 'No'}}';
  }
}

class Observation {
  final int? id;
  final String? description;
  final DateTime? date;

  Observation({
    this.id,
    this.description,
    this.date,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      description: json['description'],
      date: DateTime.tryParse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Observation{id: $id, observation: $description, date: $date}';
  }
}

class PurchaseItem {
  final int? id;
  final String? part;
  final String? brand;
  final double? unitPrice;
  final int? quantity;
  final double? totalPrice;
  final DateTime? date; // Novo campo

  PurchaseItem({
    this.id,
    this.part,
    this.brand,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    this.date,
  });

  @override
  String toString() {
    return 'PurchaseItem{id: $id, part: $part, brand: $brand, unitPrice: $unitPrice, quantity: $quantity, totalPrice: $totalPrice, date: $date}';
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      part: json['part'],
      brand: json['brand'],
      unitPrice: json['unit_price'] != null
          ? (json['unit_price'] as num).toDouble()
          : null,
      quantity: json['quantity'],
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part': part,
      'brand': brand,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'date': date?.toIso8601String(),
    };
  }
}

class ServiceDetails {
  final int serviceId;
  final DateTime entryDate;
  final DateTime? exitDate;
  final int status;

  final int? customerId;
  final String customerName;
  final String customerSurname;
  final String email;
  final String document;
  final String whatsapp;
  final String customerObservation;

  final int vehicleId;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final String vehicleType;
  final int manufactureYear;
  final int vehicleTypeId;

  final String userName;
  final String userEmail;

  final List<Observation> observations;
   final List<PurchaseItem> purchaseItems;


  final Uint8List? imageBytes;
  final Uint8List? exitImageBytes;

  final double? sumValue;


  ServiceDetails({
    required this.serviceId,
    required this.entryDate,
    this.exitDate,
    required this.status,
    this.customerId,
    required this.customerName,
    required this.customerSurname,
    required this.email,
    required this.document,
    required this.whatsapp,
    required this.customerObservation,
    required this.vehicleType,
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.userEmail,
    required this.userName,
    required this.vehiclePlate,
    required this.manufactureYear,
    required this.vehicleTypeId,
    required  this.observations,
    required this.purchaseItems,
    this.imageBytes,
    this.exitImageBytes,
    this.sumValue,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      serviceId: json['service_id'],
      entryDate: DateTime.parse(json['entry_date']),
      exitDate: json['exit_date'] != null
          ? DateTime.tryParse(json['exit_date'])
          : null,
      status: json['status'] ?? 0,
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      customerSurname: json['customer_surname'] ?? '',
      email: json['email'] ?? '',
      document: json['document'] ?? '',
      vehicleType: json['vehicle_type_name'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      customerObservation: json['customer_observation'] ?? '',
      vehicleId: json['vehicle_id'] ?? 0,
      vehicleModel: json['vehicle_model'] ?? '',
      vehicleColor: json['vehicle_color'] ?? '',
      userEmail: json['user_email'] ?? '',
      userName: json['user_name'] ?? '',
      sumValue: json['sumValue'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      manufactureYear: json['manufacture_year'] ?? 0,
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
      observations: (json['observations'] as List<dynamic>?)
          ?.map((o) => Observation.fromJson(o as Map<String, dynamic>))
          .toList() ??
          [],
      purchaseItems: (json['purchase_items'] as List<dynamic>?)
          ?.map((p) => PurchaseItem.fromJson(p as Map<String, dynamic>))
          .toList() ??
          [],
      imageBytes: json['image'] != null
          ? Uint8List.fromList(List<int>.from(json['image']))
          : Uint8List(0),

      exitImageBytes: json['exit_image'] != null
          ? Uint8List.fromList(List<int>.from(json['exit_image']))
          : Uint8List(0),
    );
  }
}
