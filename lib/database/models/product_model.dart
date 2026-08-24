// lib/database/models/product_model.dart

class ProductModel {
  final int id;
  final String? barcode;
  final String name;
  final String? brand;
  final int categoryId;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final String? imagePath;
  final DateTime? expiryDate;

  ProductModel({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    required this.categoryId,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    this.imagePath,
    this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "barcode": barcode,
        "name": name,
        "brand": brand,
        "categoryId": categoryId,
        "unit": unit,
        "costPrice": costPrice,
        "sellingPrice": sellingPrice,
        "stock": stock,
        "imagePath": imagePath,
        "expiryDate": expiryDate?.toIso8601String(),
      };

  // ✅ safer factory: fromMap instead of ProductsData
  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as int,
      barcode: data['barcode'] as String?,
      name: data['name'] as String,
      brand: data['brand'] as String?,
      categoryId: data['categoryId'] as int,
      unit: data['unit'] as String,
      costPrice: (data['costPrice'] as num).toDouble(),
      sellingPrice: (data['sellingPrice'] as num).toDouble(),
      stock: data['stock'] as int,
      imagePath: data['imagePath'] as String?,
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'] as String)
          : null,
    );
  }
}
