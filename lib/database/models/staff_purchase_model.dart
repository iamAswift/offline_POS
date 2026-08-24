// lib/database/models/staff_purchase_model.dart

class StaffPurchaseModel {
  final int id;
  final int staffId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String paymentType; // "cash" or "credit"
  final double amountPaid;
  final double debtAmount;
  final int? saleId;
  final String? note;
  final DateTime createdAt;

  StaffPurchaseModel({
    required this.id,
    required this.staffId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.paymentType,
    required this.amountPaid,
    required this.debtAmount,
    this.saleId,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "staffId": staffId,
        "productId": productId,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "totalAmount": totalAmount,
        "paymentType": paymentType,
        "amountPaid": amountPaid,
        "debtAmount": debtAmount,
        "saleId": saleId,
        "note": note,
        "createdAt": createdAt.toIso8601String(),
      };

  // Safer factory: fromMap instead of relying on generated class
  factory StaffPurchaseModel.fromMap(Map<String, dynamic> data) {
    return StaffPurchaseModel(
      id: data['id'] as int,
      staffId: data['staffId'] as int,
      productId: data['productId'] as int,
      quantity: data['quantity'] as int,
      unitPrice: (data['unitPrice'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      paymentType: data['paymentType'] as String,
      amountPaid: (data['amountPaid'] as num).toDouble(),
      debtAmount: (data['debtAmount'] as num).toDouble(),
      saleId: data['saleId'] as int?,
      note: data['note'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
