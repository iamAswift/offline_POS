// lib/database/models/stock_movement_model.dart

class StockMovementModel {
  final int id;
  final int productId;
  final int? supplierId;
  final String type;          // "purchase", "sale", "return", "adjustment"
  final int? deliveryId;
  final int quantity;
  final double unitPrice;
  final DateTime date;

  StockMovementModel({
    required this.id,
    required this.productId,
    this.supplierId,
    required this.type,
    this.deliveryId,
    required this.quantity,
    required this.unitPrice,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "productId": productId,
        "supplierId": supplierId,
        "type": type,
        "deliveryId": deliveryId,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "date": date.toIso8601String(),
      };

  // Safer factory: fromMap instead of relying on generated class
  factory StockMovementModel.fromMap(Map<String, dynamic> data) {
    return StockMovementModel(
      id: data['id'] as int,
      productId: data['productId'] as int,
      supplierId: data['supplierId'] as int?,
      type: data['type'] as String,
      deliveryId: data['deliveryId'] as int?,
      quantity: data['quantity'] as int,
      unitPrice: (data['unitPrice'] as num).toDouble(),
      date: DateTime.parse(data['date'] as String),
    );
  }
}
