import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String secretId;
  final String email;
  final String reason;
  final String? description;
  final String? secretText;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.secretId,
    required this.email,
    required this.reason,
    this.description,
    this.secretText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'secretId': secretId,
      'email': email,
      'reason': reason,
      'description': description,
      'secretText': secretText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    DateTime createdAt = DateTime.now();
    final createdAtValue = map['createdAt'];

    if (createdAtValue is String) {
      try {
        createdAt = DateTime.parse(createdAtValue);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else if (createdAtValue != null) {
      try {
        createdAt = (createdAtValue as dynamic).toDate();
      } catch (e) {
        createdAt = DateTime.now();
      }
    }

    return Report(
      id: id,
      secretId: map['secretId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      description: map['description'] as String?,
      secretText: map['secretText'] as String?,
      createdAt: createdAt,
    );
  }
}
