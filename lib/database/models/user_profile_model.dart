// lib/database/models/user_profile_model.dart

class UserProfileModel {
  final int id;
  final int userId;
  final String? nin;
  final String? phone;
  final String? guarantorName;
  final String? guarantorPhone;
  final double salary;
  final double amountOwed;
  final bool canReceiveStock;
  final bool canCountStock;

  UserProfileModel({
    required this.id,
    required this.userId,
    this.nin,
    this.phone,
    this.guarantorName,
    this.guarantorPhone,
    required this.salary,
    required this.amountOwed,
    required this.canReceiveStock,
    required this.canCountStock,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "nin": nin,
        "phone": phone,
        "guarantorName": guarantorName,
        "guarantorPhone": guarantorPhone,
        "salary": salary,
        "amountOwed": amountOwed,
        "canReceiveStock": canReceiveStock,
        "canCountStock": canCountStock,
      };

  // Safer factory: fromMap instead of relying on generated class
  factory UserProfileModel.fromMap(Map<String, dynamic> data) {
    return UserProfileModel(
      id: data['id'] as int,
      userId: data['userId'] as int,
      nin: data['nin'] as String?,
      phone: data['phone'] as String?,
      guarantorName: data['guarantorName'] as String?,
      guarantorPhone: data['guarantorPhone'] as String?,
      salary: (data['salary'] as num).toDouble(),
      amountOwed: (data['amountOwed'] as num).toDouble(),
      canReceiveStock: data['canReceiveStock'] as bool,
      canCountStock: data['canCountStock'] as bool,
    );
  }
}
