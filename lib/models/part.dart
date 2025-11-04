class Part {
  final String code;
  final String name;
  final String brand;
  final double price;
  final int quantity;
  final double total;

  Part({
    required this.code,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      code: json['code'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'brand': brand,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  Part copyWith({
    String? code,
    String? name,
    String? brand,
    double? price,
    int? quantity,
    double? total,
  }) {
    return Part(
      code: code ?? this.code,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }
}
