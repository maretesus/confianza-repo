import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ==================== PROVIDER DE ID ANÓNIMO ====================

/// Provider que retorna el ID único del usuario anónimo
/// Este ID se genera una sola vez y se guarda localmente
final anonymousUserIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Intentar obtener ID existente
  String? existingId = prefs.getString('anonymous_user_id');
  
  if (existingId == null) {
    // Generar nuevo ID único si no existe
    existingId = const Uuid().v4();
    // Guardarlo para futuras sesiones
    await prefs.setString('anonymous_user_id', existingId);
  }
  
  return existingId;
});

/// Provider que proporciona el ID anónimo de forma sincrónica (después de cargarse)
final anonymousUserIdSyncProvider = StateProvider<String?>((ref) {
  return null;
});
