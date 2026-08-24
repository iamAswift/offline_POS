// lib/database/models/category_model.dart

class CategoryModel {
  final int id;
  final String name;
  final String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "imagePath": imagePath,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] as int,
      name: data['name'] as String,
      imagePath: data['imagePath'] as String?,
    );
  }
}
