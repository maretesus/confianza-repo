import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String secretId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final bool isAnonymous;

  const Comment({
    required this.id,
    required this.secretId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.isAnonymous,
  });

  Map<String, dynamic> toMap() {
    return {
      'secretId': secretId,
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAnonymous': isAnonymous,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    // Procesar createdAt: puede ser Timestamp o String
    DateTime createdAt = DateTime.now();
    final createdAtValue = map['createdAt'];
    
    if (createdAtValue is String) {
      try {
        createdAt = DateTime.parse(createdAtValue);
      } catch (e) {
        print('Error al parsear fecha string: $e');
        createdAt = DateTime.now();
      }
    } else if (createdAtValue != null) {
      try {
        // Si es Timestamp de Firestore, usar toDate()
        createdAt = (createdAtValue as dynamic).toDate();
      } catch (e) {
        print('Error al procesar Timestamp: $e');
        createdAt = DateTime.now();
      }
    }

    return Comment(
      id: id,
      secretId: map['secretId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      createdAt: createdAt,
      isAnonymous: map['isAnonymous'] as bool? ?? true,
    );
  }
}
