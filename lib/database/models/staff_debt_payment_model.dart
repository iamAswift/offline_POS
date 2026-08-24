// lib/database/models/staff_debt_payment_model.dart

class StaffDebtPaymentModel {
  final int id;
  final int staffId;
  final double amount;
  final String paymentMethod;
  final String? note;
  final int recordedBy;
  final DateTime createdAt;

  StaffDebtPaymentModel({
    required this.id,
    required this.staffId,
    required this.amount,
    required this.paymentMethod,
    this.note,
    required this.recordedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "staffId": staffId,
        "amount": amount,
        "paymentMethod": paymentMethod,
        "note": note,
        "recordedBy": recordedBy,
        "createdAt": createdAt.toIso8601String(),
      };
}

// ✅ Extension to handle nullable cases
extension StaffDebtPaymentModelNullable on StaffDebtPaymentModel? {
  Map<String, dynamic>? toJsonSafe() => this?.toJson();
}
