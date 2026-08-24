// lib/database/models/supplier_payment_allocation_model.dart

class SupplierPaymentAllocationModel {
  final int id;
  final int paymentId;
  final int deliveryId;
  final double amount;

  SupplierPaymentAllocationModel({
    required this.id,
    required this.paymentId,
    required this.deliveryId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "paymentId": paymentId,
        "deliveryId": deliveryId,
        "amount": amount,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SupplierPaymentAllocationModel.fromMap(Map<String, dynamic> data) {
    return SupplierPaymentAllocationModel(
      id: data['id'] as int,
      paymentId: data['paymentId'] as int,
      deliveryId: data['deliveryId'] as int,
      amount: (data['amount'] as num).toDouble(),
    );
  }
}
