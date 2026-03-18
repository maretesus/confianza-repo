import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea un nuevo reporte
  Future<String> createReport({
    required String secretId,
    required String email,
    required String reason,
    String? description,
    String? secretText,
  }) async {
    try {
      final docRef = await _firestore.collection('reports').add({
        'secretId': secretId,
        'email': email,
        'reason': reason,
        'description': description,
        'secretText': secretText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error creando reporte: $e');
      rethrow;
    }
  }

  /// Obtiene un stream de reportes para un secreto específico
  Stream<List<Report>> watchReportsBySecretId(String secretId) {
    return _firestore
        .collection('reports')
        .where('secretId', isEqualTo: secretId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Report.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
