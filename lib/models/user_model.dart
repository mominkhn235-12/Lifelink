import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String bloodGroup;
  final String role; // 'donor', 'requester' or 'admin'
  final bool isAvailable;
  final bool isBlocked;
  final DateTime? lastDonationDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.bloodGroup,
    required this.role,
    this.isAvailable = true,
    this.isBlocked = false,
    this.lastDonationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'bloodGroup': bloodGroup,
      'role': role,
      'isAvailable': isAvailable,
      'isBlocked': isBlocked,
      'lastDonationDate': lastDonationDate == null
          ? null
          : Timestamp.fromDate(lastDonationDate!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      role: map['role'] ?? 'donor',
      isAvailable: map['isAvailable'] ?? true,
      isBlocked: map['isBlocked'] ?? false,
      lastDonationDate: (map['lastDonationDate'] as Timestamp?)?.toDate(),
    );
  }
}