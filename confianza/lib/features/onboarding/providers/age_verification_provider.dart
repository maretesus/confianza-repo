import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para verificar si el usuario ya pasó la verificación de edad
final hasCompletedAgeVerificationProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('age_verification_completed') ?? false;
});

/// Provider para marcar la verificación como completada
final completeAgeVerificationProvider = Provider((ref) {
  return () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('age_verification_completed', true);
  };
});

/// Calcula la edad a partir de una fecha de nacimiento
int calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;

  // Ajustar si aún no cumplió años este año
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}
