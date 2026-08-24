// lib/database/models/settings_model.dart

class SettingsModel {
  final int id;
  final String key;   // e.g. "currency", "low_stock_threshold"
  final String value; // stored as string, parsed by app

  SettingsModel({
    required this.id,
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory SettingsModel.fromMap(Map<String, dynamic> data) {
    return SettingsModel(
      id: data['id'] as int,
      key: data['key'] as String,
      value: data['value'] as String,
    );
  }
}
