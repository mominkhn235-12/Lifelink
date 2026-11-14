import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String requesterId;
  final String requesterName;
  final String patientName;
  final String bloodGroup;
  final int units;
  final String hospital;
  final String city;
  final String urgency; // 'normal', 'urgent' or 'critical'
  final String contactPhone;
  final String notes;
  final String status; // 'open', 'accepted', 'fulfilled' or 'cancelled'
  final bool isVerified;
  final String acceptedBy;
  final String acceptedByName;
  final String acceptedByPhone;
  final DateTime? createdAt;

  RequestModel({
    this.id = '',
    required this.requesterId,
    required this.requesterName,
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.hospital,
    required this.city,
    required this.urgency,
    required this.contactPhone,
    this.notes = '',
    this.status = 'open',
    this.isVerified = false,
    this.acceptedBy = '',
    this.acceptedByName = '',
    this.acceptedByPhone = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'units': units,
      'hospital': hospital,
      'city': city,
      'urgency': urgency,
      'contactPhone': contactPhone,
      'notes': notes,
      'status': status,
      'isVerified': isVerified,
      'acceptedBy': acceptedBy,
      'acceptedByName': acceptedByName,
      'acceptedByPhone': acceptedByPhone,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory RequestModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return RequestModel(
      id: doc.id,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      patientName: map['patientName'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      units: map['units'] ?? 1,
      hospital: map['hospital'] ?? '',
      city: map['city'] ?? '',
      urgency: map['urgency'] ?? 'normal',
      contactPhone: map['contactPhone'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'open',
      isVerified: map['isVerified'] ?? false,
      acceptedBy: map['acceptedBy'] ?? '',
      acceptedByName: map['acceptedByName'] ?? '',
      acceptedByPhone: map['acceptedByPhone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}