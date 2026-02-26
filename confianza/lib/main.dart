import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  // Asegura que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la app con ProviderScope para Riverpod
  runApp(
    const ProviderScope(
      child: ConfidentApp(),
    ),
  );
}
