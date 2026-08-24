// lib/database/models/supplier_model.dart

class SupplierModel {
  final int id;
  final String name;
  final String? contact;
  final String? address;
  final String? notes;

  SupplierModel({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "contact": contact,
        "address": address,
        "notes": notes,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SupplierModel.fromMap(Map<String, dynamic> data) {
    return SupplierModel(
      id: data['id'] as int,
      name: data['name'] as String,
      contact: data['contact'] as String?,
      address: data['address'] as String?,
      notes: data['notes'] as String?,
    );
  }
}
