// lib/database/models/supplier_delivery_model.dart

class SupplierDeliveryModel {
  final int id;
  final int supplierId;
  final DateTime deliveryDate;
  final String? invoiceNumber;
  final double totalAmount;
  final String? notes;

  SupplierDeliveryModel({
    required this.id,
    required this.supplierId,
    required this.deliveryDate,
    this.invoiceNumber,
    required this.totalAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "supplierId": supplierId,
        "deliveryDate": deliveryDate.toIso8601String(),
        "invoiceNumber": invoiceNumber,
        "totalAmount": totalAmount,
        "notes": notes,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SupplierDeliveryModel.fromMap(Map<String, dynamic> data) {
    return SupplierDeliveryModel(
      id: data['id'] as int,
      supplierId: data['supplierId'] as int,
      deliveryDate: DateTime.parse(data['deliveryDate'] as String),
      invoiceNumber: data['invoiceNumber'] as String?,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      notes: data['notes'] as String?,
    );
  }
}
