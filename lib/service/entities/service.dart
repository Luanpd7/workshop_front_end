import '../../customer/entities/customer.dart';
import 'vehicle.dart';

class Service {
  final int? id;
  final Vehicle vehicle;
  final Customer customer;
  final DateTime entryDate;
  final List<Observation> observations; // <- atualizado
  final List<PurchaseItem> purchaseItems;
  final int status;
  final String? imagePath;

  Service({
     this.id,
    required this.vehicle,
    required this.customer,
    required this.entryDate,
    required this.observations,
    required this.purchaseItems,
    required this.status,
    this.imagePath,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      customer: Customer.fromJson(json['customer']),
      entryDate: DateTime.parse(json['date']),
      observations: (json['observations'] as List)
          .map((obs) => Observation.fromJson(obs))
          .toList(),
      purchaseItems: (json['purchase_items'] as List)
          .map((item) => PurchaseItem.fromJson(item))
          .toList(),
      status: json['status'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle': vehicle.toJson(),
      'customer': customer.toJson(),
      'date': entryDate.toIso8601String(),
      'observations': observations.map((obs) => obs.toJson()).toList(),
      'purchase_items': purchaseItems.map((item) => item.toJson()).toList(),
      'status': status,
      'imagePath': imagePath,
    };
  }
}



class Observation {
  final int? id;
  final String? observation;
  final DateTime? date;

  Observation({
     this.id,
     this.observation,
    this.date,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      observation: json['observation'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'observation': observation,
      'date': date,
    };
  }
}

class PurchaseItem {
  final int? id;
  final String? part;
  final String? brand;
  final double? unitPrice;
  final int? quantity;
  final double? totalPrice;

  PurchaseItem({
     this.id,
     this.part,
     this.brand,
     this.unitPrice,
     this.quantity,
     this.totalPrice,
  });

  factory PurchaseItem.autoTotal({
    required int id,
    required String part,
    required String brand,
    required double unitPrice,
    required int quantity,
  }) {
    return PurchaseItem(
      id: id,
      part: part,
      brand: brand,
      unitPrice: unitPrice,
      quantity: quantity,
      totalPrice: unitPrice * quantity,
    );
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      part: json['part'],
      brand: json['brand'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'],
      totalPrice: (json['total_price'] as num).toDouble(),
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
    };
  }
}




