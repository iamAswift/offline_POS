// lib/database/models/supplier_payment_model.dart

class SupplierPaymentModel {
  final int id;
  final int supplierId;
  final DateTime paymentDate;
  final double amount;
  final String paymentMethod; // "cash", "pos", "transfer", etc.
  final String? reference;
  final String? notes;

  SupplierPaymentModel({
    required this.id,
    required this.supplierId,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "supplierId": supplierId,
        "paymentDate": paymentDate.toIso8601String(),
        "amount": amount,
        "paymentMethod": paymentMethod,
        "reference": reference,
        "notes": notes,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SupplierPaymentModel.fromMap(Map<String, dynamic> data) {
    return SupplierPaymentModel(
      id: data['id'] as int,
      supplierId: data['supplierId'] as int,
      paymentDate: DateTime.parse(data['paymentDate'] as String),
      amount: (data['amount'] as num).toDouble(),
      paymentMethod: data['paymentMethod'] as String,
      reference: data['reference'] as String?,
      notes: data['notes'] as String?,
    );
  }
}
