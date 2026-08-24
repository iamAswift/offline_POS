// lib/database/models/sale_model.dart

class SaleModel {
  final int id;
  final int productId;
  final int quantity;
  final int unitPrice;        // stored in Naira
  final double costPriceAtSale;
  final int totalPrice;

  final String paymentMethod; // "cash", "pos", "transfer", "split"
  final double? cashAmount;
  final double? posAmount;
  final double? transferAmount;

  final String status;        // default "pending"
  final int staffId;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPriceAtSale,
    required this.totalPrice,
    required this.paymentMethod,
    this.cashAmount,
    this.posAmount,
    this.transferAmount,
    required this.status,
    required this.staffId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "productId": productId,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "costPriceAtSale": costPriceAtSale,
        "totalPrice": totalPrice,
        "paymentMethod": paymentMethod,
        "cashAmount": cashAmount,
        "posAmount": posAmount,
        "transferAmount": transferAmount,
        "status": status,
        "staffId": staffId,
        "createdAt": createdAt.toIso8601String(),
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SaleModel.fromMap(Map<String, dynamic> data) {
    return SaleModel(
      id: data['id'] as int,
      productId: data['productId'] as int,
      quantity: data['quantity'] as int,
      unitPrice: data['unitPrice'] as int,
      costPriceAtSale: (data['costPriceAtSale'] as num).toDouble(),
      totalPrice: data['totalPrice'] as int,
      paymentMethod: data['paymentMethod'] as String,
      cashAmount: (data['cashAmount'] as num?)?.toDouble(),
      posAmount: (data['posAmount'] as num?)?.toDouble(),
      transferAmount: (data['transferAmount'] as num?)?.toDouble(),
      status: data['status'] as String,
      staffId: data['staffId'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}
