class PartsReport {
  final double totalPurchased;
  final double totalSold;
  final List<PartItem> parts;

  PartsReport({
    required this.totalPurchased,
    required this.totalSold,
    required this.parts,
  });

  double get profit => totalSold - totalPurchased;

  factory PartsReport.fromJson(Map<String, dynamic> json) {
    return PartsReport(
      totalPurchased: (json['totalPurchased'] ?? 0).toDouble(),
      totalSold: (json['totalSold'] ?? 0).toDouble(),
      parts: (json['parts'] as List<dynamic>?)
          ?.map((item) => PartItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPurchased': totalPurchased,
    'totalSold': totalSold,
    'parts': parts.map((p) => p.toJson()).toList(),
  };
}

class PartItem {
  final String name;
  final String code;
  final int quantity;
  final double total;

  PartItem({
    required this.name,
    required this.code,
    required this.quantity,
    required this.total,
  });

  factory PartItem.fromJson(Map<String, dynamic> json) {
    return PartItem(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      quantity: json['quantity'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'quantity': quantity,
    'total': total,
  };
}

class ServicesReport {
  final int totalServices;
  final double totalRevenue;
  final Map<String, int> servicesByStatus;
  final List<ServiceItem> services;

  ServicesReport({
    required this.totalServices,
    required this.totalRevenue,
    required this.servicesByStatus,
    required this.services,
  });

  factory ServicesReport.fromJson(Map<String, dynamic> json) {
    return ServicesReport(
      totalServices: json['totalServices'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      servicesByStatus: Map<String, int>.from(json['servicesByStatus'] ?? {}),
      services: (json['services'] as List<dynamic>?)
          ?.map((item) => ServiceItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'totalServices': totalServices,
    'totalRevenue': totalRevenue,
    'servicesByStatus': servicesByStatus,
    'services': services.map((s) => s.toJson()).toList(),
  };
}

class ServiceItem {
  final int id;
  final String clientName;
  final String status;
  final double totalCost;

  ServiceItem({
    required this.id,
    required this.clientName,
    required this.status,
    required this.totalCost,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? 0,
      clientName: json['clientName'] ?? '',
      status: json['status'] ?? '',
      totalCost: (json['totalCost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientName': clientName,
    'status': status,
    'totalCost': totalCost,
  };
}
