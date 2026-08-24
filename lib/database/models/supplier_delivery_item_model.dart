// lib/database/models/supplier_delivery_item_model.dart

class SupplierDeliveryItemModel {
  final int id;
  final int deliveryId;
  final int productId;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final DateTime? expiryDate;

  SupplierDeliveryItemModel({
    required this.id,
    required this.deliveryId,
    required this.productId,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "deliveryId": deliveryId,
        "productId": productId,
        "quantity": quantity,
        "unitCost": unitCost,
        "totalCost": totalCost,
        "expiryDate": expiryDate?.toIso8601String(),
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SupplierDeliveryItemModel.fromMap(Map<String, dynamic> data) {
    return SupplierDeliveryItemModel(
      id: data['id'] as int,
      deliveryId: data['deliveryId'] as int,
      productId: data['productId'] as int,
      quantity: data['quantity'] as int,
      unitCost: (data['unitCost'] as num).toDouble(),
      totalCost: (data['totalCost'] as num).toDouble(),
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'] as String)
          : null,
    );
  }
}
