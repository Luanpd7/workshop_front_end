
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';


class Observation {
  final int? id;
  final int serviceId;
  final String description;
  final DateTime date;

  Observation({
    this.id,
    required this.serviceId,
    required this.description,
    required this.date,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      serviceId: json['service_id'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  Observation copyWith({
    int? id,
    int? serviceId,
    String? description,
    DateTime? date,
  }) {
    return Observation(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Observation{id: $id, serviceId: $serviceId, description: $description, date: $date}';
  }
}

class PurchaseItem {
  final int? id;
  final int serviceId;
  final String? part;
  final String? brand;
  final double? unitPrice;
  final int? quantity;
  final double? totalPrice;
  final DateTime? date;

  PurchaseItem({
    this.id,
    required this.serviceId,
    this.part,
    this.brand,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    this.date,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      serviceId: json['service_id'],
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
      'service_id': serviceId,
      'part': part,
      'brand': brand,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'date': date?.toIso8601String(),
    };
  }

  PurchaseItem copyWith({
    int? id,
    int? serviceId,
    String? part,
    String? brand,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    DateTime? date,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      part: part ?? this.part,
      brand: brand ?? this.brand,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'PurchaseItem{id: $id, serviceId: $serviceId, part: $part, brand: $brand, unitPrice: $unitPrice, quantity: $quantity, totalPrice: $totalPrice, date: $date}';
  }
}

class Service {
  final int? id;
  final int? idUser; // id do mecânico
  final int? customerId;
  final int? vehicleId;
  final int? status;
  final DateTime? entryDate;
  final DateTime? exitDate;
  final double? sumValue;

  // Dados do mecânico
  final String? mechanicName;
  final String? mechanicEmail;

  // Dados do cliente
  final String? customerName;
  final String? customerSurname;
  final String? customerDocument;
  final String? customerEmail;
  final String? customerWhatsapp;

  // Dados do veículo
  final String? vehicleModel;
  final String? vehicleBrand;
  final String? vehiclePlate;
  final String? vehicleColor;
  final int? vehicleYear;
  final int? vehicleTypeId;

  // Itens relacionados
  final List<Observation> observations;
  final List<PurchaseItem> purchaseItems;
  final List<ServiceImage> images;

  const Service({
     this.id,
    this.idUser,
    this.customerId,
     this.vehicleId,
     this.status,
     this.entryDate,
    this.exitDate,
    this.sumValue,
    this.mechanicName,
    this.mechanicEmail,
    this.customerName,
    this.customerSurname,
    this.customerDocument,
    this.customerEmail,
    this.customerWhatsapp,
    this.vehicleModel,
    this.vehicleBrand,
    this.vehiclePlate,
    this.vehicleColor,
    this.vehicleYear,
    this.vehicleTypeId,
    this.observations = const [],
    this.purchaseItems = const [],
    this.images = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      idUser: json['idUser'],
      customerId: json['customer_id'],
      vehicleId: json['vehicle_id'],
      status: json['status'],
      entryDate: DateTime.parse(json['entry_date']),
      exitDate:
      json['exit_date'] != null ? DateTime.parse(json['exit_date']) : null,
      sumValue: (json['sumValue'] as num?)?.toDouble(),

      // Dados do mecânico
      mechanicName: json['mechanic_name'],
      mechanicEmail: json['mechanic_email'],

      // Dados do cliente
      customerName: json['customer_name'],
      customerSurname: json['customer_surname'],
      customerDocument: json['customer_document'],
      customerEmail: json['customer_email'],
      customerWhatsapp: json['customer_whatsapp'],

      // Dados do veículo
      vehicleModel: json['vehicle_model'],
      vehicleBrand: json['vehicle_brand'],
      vehiclePlate: json['vehicle_plate'],
      vehicleColor: json['vehicle_color'],
      vehicleYear: json['vehicle_year'],
      vehicleTypeId: json['vehicle_type_id'],

      // Listas
      observations: (json['observations'] as List<dynamic>?)
          ?.map((o) => Observation.fromJson(o))
          .toList() ??
          [],
      purchaseItems: (json['purchase_items'] as List<dynamic>?)
          ?.map((p) => PurchaseItem.fromJson(p))
          .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
          ?.map((i) => ServiceImage.fromJson(i))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'status': status,
      'entry_date': entryDate?.toIso8601String(),
      'exit_date': exitDate?.toIso8601String(),
      'sumValue': sumValue,

      // Dados adicionais
      'mechanic_name': mechanicName,
      'mechanic_email': mechanicEmail,
      'customer_name': customerName,
      'customer_surname': customerSurname,
      'customer_document': customerDocument,
      'customer_email': customerEmail,
      'customer_whatsapp': customerWhatsapp,
      'vehicle_model': vehicleModel,
      'vehicle_brand': vehicleBrand,
      'vehicle_plate': vehiclePlate,
      'vehicle_color': vehicleColor,
      'vehicle_year': vehicleYear,
      'vehicle_type_id': vehicleTypeId,

      // Relacionamentos
      'observations': observations.map((o) => o.toJson()).toList(),
      'purchase_items': purchaseItems.map((p) => p.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }

  Service copyWith({
    int? id,
    int? idUser,
    int? customerId,
    int? vehicleId,
    int? status,
    DateTime? entryDate,
    DateTime? exitDate,
    double? sumValue,
    String? mechanicName,
    String? mechanicEmail,
    String? customerName,
    String? customerSurname,
    String? customerDocument,
    String? customerEmail,
    String? customerWhatsapp,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
    int? vehicleYear,
    int? vehicleTypeId,
    List<Observation>? observations,
    List<PurchaseItem>? purchaseItems,
    List<ServiceImage>? images,
  }) {
    return Service(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      sumValue: sumValue ?? this.sumValue,
      mechanicName: mechanicName ?? this.mechanicName,
      mechanicEmail: mechanicEmail ?? this.mechanicEmail,
      customerName: customerName ?? this.customerName,
      customerSurname: customerSurname ?? this.customerSurname,
      customerDocument: customerDocument ?? this.customerDocument,
      customerEmail: customerEmail ?? this.customerEmail,
      customerWhatsapp: customerWhatsapp ?? this.customerWhatsapp,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      observations: observations ?? this.observations,
      purchaseItems: purchaseItems ?? this.purchaseItems,
      images: images ?? this.images,
    );
  }

  @override
  String toString() {
    return 'Service{id: $id, mechanic: $mechanicName, customer: $customerName, vehicle: $vehicleModel, status: $status}';
  }




}

enum ServiceStatus {
  emAndamento(0, 'Em Andamento'),
  lavacao(1, 'Lavação'),
  finalizado(2, 'Finalizado'),
  emAnalise(3, 'Em Análise');

  final int code;
  final String label;

  const ServiceStatus(this.code, this.label);

  /// Retorna o enum com base no código
  static ServiceStatus fromCode(int code) {
    return ServiceStatus.values.firstWhere(
          (status) => status.code == code,
      orElse: () => ServiceStatus.emAndamento, // padrão
    );
  }
}


class ServiceImage {
  final int? id;
  final int serviceId;
  final String type;
  final Uint8List image;

  ServiceImage({
    this.id,
    required this.serviceId,
    required this.type,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'type': type,
      'image': image,
    };
  }

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      id: json['id'],
      serviceId: json['service_id'],
      type: json['type'],
      image: json['image'],
    );
  }

  ServiceImage copyWith({
    int? id,
    int? serviceId,
    String? type,
    Uint8List? image,
  }) {
    return ServiceImage(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      type: type ?? this.type,
      image: image ?? this.image,
    );
  }

}





class ServiceDetails {
  final int?  serviceId;
  final DateTime? entryDate;
  final DateTime? exitDate;
  final int?  status;
  final int?  userId;
  final double?  sumValue;

  final int?  customerId;
  final String?  customerName;
  final String? customerSurname;
  final String? customerEmail;
  final String? customerDocument;
  final String? customerWhatsapp;
  final String? customerObservation;

  final int?  vehicleId;
  final String?  vehicleModel;
  final String?  vehicleColor;
  final String?  vehiclePlate;
  final int? manufactureYear;
  final String?  vehicleTypeName;

  final String?  mechanicName;
  final String?  mechanicEmail;

  ServiceDetails({
    required this.serviceId,
    this.entryDate,
    this.exitDate,
     this.status,
     this.userId,
     this.sumValue,
     this.customerId,
     this.customerName,
    this.customerSurname,
    this.customerEmail,
    this.customerDocument,
    this.customerWhatsapp,
    this.customerObservation,
     this.vehicleId,
     this.vehicleModel,
     this.vehicleColor,
     this.vehiclePlate,
    this.manufactureYear,
     this.vehicleTypeName,
     this.mechanicName,
     this.mechanicEmail,
  });

  factory ServiceDetails.fromMap(Map<String, dynamic> map) {
    return ServiceDetails(
      serviceId: map['service_id']  ?? 0,
      status: map['status']  ?? 0,

      customerId: map['customer_id'] ?? 0,
      customerName: map['customer_name'] ?? '',
      customerSurname: map['customer_surname'] ?? '',
      customerDocument: map['document'] ?? '',

      vehicleModel: map['vehicle_model'] ?? '',

      mechanicName: map['user_name'] ?? '',
    );
  }



  ServiceStatus get statusEnum => ServiceStatus.fromCode(status!);

  String get statusLabel => statusEnum.label;
}

