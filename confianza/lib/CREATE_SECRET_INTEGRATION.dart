/// Ejemplo de cómo integrar CreateSecretScreen en tu app
/// 
/// Este archivo muestra las diferentes formas de acceder a la pantalla de crear secretos
library;

import 'package:flutter/material.dart';
import 'features/secrets/screens/create_secret_screen.dart';

// ============== OPCIÓN 1: Botón FAB (Floating Action Button) ==============
// Agrega esto a tu pantalla principal (HomeScreen):

FloatingActionButton createSecretFAB() {
  return FloatingActionButton(
    onPressed: () {
      // Navega a la pantalla de crear secreto
      // Si usas Navigator.push:
      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (_) => const CreateSecretScreen()),
      // );
      
      // Si usas Go Router:
      // context.go('/create-secret');
    },
    tooltip: 'Compartir un secreto',
    child: const Icon(Icons.add),
  );
}

// ============== OPCIÓN 2: Botón en AppBar ==============
// Agrega esto a tu AppBar:

AppBar appBarWithCreateButton() {
  return AppBar(
    title: const Text('Confianza'),
    actions: [
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Nuevo secreto',
        onPressed: () {
          // Navega a CreateSecretScreen
        },
      ),
    ],
  );
}

// ============== OPCIÓN 3: Usar con Go Router ==============
// Agrega esto a tu router.dart:

/*
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create-secret',
      builder: (context, state) => const CreateSecretScreen(),
    ),
    // ... otras rutas
  ],
);
*/

// ============== OPCIÓN 4: Usar con Navigator ==============
// En cualquier widget:

void navigateToCreateSecret(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const CreateSecretScreen(),
    ),
  );
}

// ============== CÓMO FUNCIONA ==============
/*
1. El usuario abre CreateSecretScreen
2. Llena el formulario (título, descripción, categoría, etc.)
3. Presiona "Publicar"
4. Se obtiene el usuario actual (currentUserProvider)
5. Se crea un objeto Secret con los datos
6. Se llama a createSecretProvider(secret).future
7. El secret se guarda en Firestore en la colección 'secrets'
8. Si es exitoso, muestra un mensaje y vuelve atrás
9. Si falla, muestra un mensaje de error

El SecretService ya maneja todo en la nube:
- Guarda en: firestore.collection('secrets')
- Asigna un ID automático
- Guarda el timestamp de creación
*/

// ============== EJEMPLO: HomeScreen CON BOTÓN ==============

class HomeScreenExample extends StatelessWidget {
  const HomeScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confianza'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Tu espacio seguro para secretos'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navega a CreateSecretScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateSecretScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Compartir un Secreto'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // O usa el FAB
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateSecretScreen(),
            ),
          );
        },
        tooltip: 'Nuevo secreto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
