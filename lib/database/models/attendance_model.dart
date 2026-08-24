// lib/database/models/attendance_model.dart

class AttendanceModel {
  final int id;
  final int userId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? notes;
  final DateTime createdAt;
  final int? correctedByUserId;
  final DateTime? correctedAt;
  final String? correctionNote;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.clockIn,
    this.clockOut,
    this.notes,
    required this.createdAt,
    this.correctedByUserId,
    this.correctedAt,
    this.correctionNote,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "clockIn": clockIn.toIso8601String(),
        "clockOut": clockOut?.toIso8601String(),
        "notes": notes,
        "createdAt": createdAt.toIso8601String(),
        "correctedByUserId": correctedByUserId,
        "correctedAt": correctedAt?.toIso8601String(),
        "correctionNote": correctionNote,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory AttendanceModel.fromMap(Map<String, dynamic> data) {
    return AttendanceModel(
      id: data['id'] as int,
      userId: data['userId'] as int,
      clockIn: DateTime.parse(data['clockIn'] as String),
      clockOut: data['clockOut'] != null
          ? DateTime.parse(data['clockOut'] as String)
          : null,
      notes: data['notes'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      correctedByUserId: data['correctedByUserId'] as int?,
      correctedAt: data['correctedAt'] != null
          ? DateTime.parse(data['correctedAt'] as String)
          : null,
      correctionNote: data['correctionNote'] as String?,
    );
  }
}
