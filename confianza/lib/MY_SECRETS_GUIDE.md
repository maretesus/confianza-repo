# 📚 Guía: Ver, Editar y Eliminar Secretos

## 🎯 Resumen

Hemos agregado tres pantallas nuevas para que los usuarios gestionen sus secretos:

1. **MySecretsScreen** - Ver todos tus secretos
2. **EditSecretScreen** - Editar un secreto existente
3. **Eliminación** - Modal para confirmar eliminación

## 🚀 Uso

### 1. Ver Mis Secretos

En el FeedScreen (pantalla principal), ve al AppBar superior derecha y presiona el botón con icono de libro 📖

```
Feed Screen
    ↓
    AppBar (botón de libro) → My Secrets Screen
```

### 2. Editar un Secreto

En MySecretsScreen:
1. Presiona el botón **"Editar"** en la tarjeta del secreto
2. Se abre EditSecretScreen
3. Modifica los campos que quieras
4. Presiona **"Guardar cambios"**
5. Los cambios se guardan en Firestore automáticamente

### 3. Eliminar un Secreto

En MySecretsScreen:
1. Presiona el botón **"Eliminar"** en la tarjeta del secreto
2. Se abre un dialog de confirmación
3. Presiona **"Eliminar"** para confirmar
4. El secreto se elimina de Firestore
5. La lista se actualiza automáticamente

## 📱 Estructura de Archivos

```
lib/features/secrets/screens/
  ├── feed_screen.dart          # ← Agregué botón para ir a Mis Secretos
  ├── create_secret_screen.dart  # ← Crear nuevos secretos
  ├── my_secrets_screen.dart    # ← NUEVO: Ver tus secretos
  └── edit_secret_screen.dart   # ← NUEVO: Editar secretos
  
lib/core/router.dart            # ← Agregué rutas
lib/features/secrets/providers/
  └── secrets_providers.dart    # ← Agregué updateSecretProvider
```

## 🔄 Flujo Completo

```
1. Usuario abre app → FeedScreen (ver todos los secretos)
                    ↓
2. Presiona botón de libro en AppBar
                    ↓
3. Va a MySecretsScreen (ve sus secretos)
                    ↓
4. Opción A - Editar:
   - Presiona "Editar"
   - Se abre EditSecretScreen
   - Modifica campos
   - Presiona "Guardar cambios"
   - Se guarda en Firestore
   - Vuelve a MySecretsScreen
                    ↓
5. Opción B - Eliminar:
   - Presiona "Eliminar"
   - Se abre dialog de confirmación
   - Presiona "Eliminar" para confirmar
   - Se elimina de Firestore
   - La lista se actualiza automáticamente
```

## 📊 Providers Utilizados

```dart
// Ver tus secretos (STREAM = en tiempo real)
userSecretsProvider(userId)

// Actualizar un secreto
updateSecretProvider(secret)

// Eliminar un secreto
deleteSecretProvider(secretId)
```

## 🎨 UI Features

### MySecretsScreen
- ✅ Muestra tarjetas con imágenes/videos del usuario
- ✅ Información de likes, comentarios
- ✅ Botones de editar y eliminar
- ✅ Pull-to-refresh para actualizar lista
- ✅ Empty state si no tiene secretos
- ✅ Categoría con color diferente por categoría

### EditSecretScreen
- ✅ Carga todos los datos del secreto actual
- ✅ Validación de formulario
- ✅ Indicador de carga mientras se guarda
- ✅ Mensajes de éxito/error
- ✅ Botón cancelar

## 💾 Cómo Funciona en Firestore

```javascript
// Cuando EDITAS:
firestore
  └── secrets/{id}/
       - title: "Nuevo título"
       - description: "Nueva descripción"
       - category: "LOVE"
       - videoUrl: "https://..."
       - isAnonymous: true
       // El createdAt NO cambia
       // Los likes y comments se mantienen

// Cuando ELIMINAS:
firestore
  └── secrets/{id} ← Se elimina completamente
```

## ⚙️ Implementación Técnica

### SecretService Methods

```dart
// Obtener secretos del usuario (Stream - tiempo real)
getUserSecrets(String userId) → Stream<List<Secret>>

// Actualizar secreto
updateSecret(Secret secret) → Future<void>

// Eliminar secreto
deleteSecret(String id) → Future<void>
```

### Riverpod Providers

```dart
// Obtener secretos del usuario actual
userSecretsProvider(userId) = StreamProvider

// Actualizar secreto
updateSecretProvider(secret) = FutureProvider

// Eliminar secreto
deleteSecretProvider(secretId) = FutureProvider
```

## 🔒 Seguridad en Firestore

Las reglas ya configuradas permiten:

```javascript
match /secrets/{secretId} {
  allow read: if request.auth.uid != null;
  allow create: if request.auth.uid != null;
  allow update: if request.auth.uid == resource.data.userId;  ← Solo tu usuario
  allow delete: if request.auth.uid == resource.data.userId;  ← Solo tu usuario
}
```

Esto significa:
- ✅ Solo TÚ puedes editar tus secretos
- ✅ Solo TÚ puedes eliminarlos
- ✅ Nadie más puede hacerlo

## 🧪 Cómo Probar

1. Abre la app y registrate/inicia sesión
2. Crea un secreto (botón +)
3. Ve a Feed Screen
4. Presiona botón de libro en AppBar
5. Verás tu secreto en la lista
6. Presiona "Editar" y modifica algo
7. Presiona "Eliminar" y confirma
8. El secreto debe desaparecer

## 🚀 Próximas Mejoras

- [ ] Ver detalles completos del secreto
- [ ] Sistema de comentarios
- [ ] Dar likes desde MySecretsScreen
- [ ] Compartir secreto (copiar link)
- [ ] Historial de ediciones
- [ ] Archivos/borrador

## ❓ Preguntas Frecuentes

**P: ¿Puedo editar los likes/comentarios?**
R: No, son solo lectura. Se actualizan cuando otros usuarios interactúan.

**P: ¿Qué pasa si elimino un secreto?**
R: Se borra completamente de Firestore. No tiene recuperación.

**P: ¿Puedo editar los secretos de otros usuarios?**
R: No, Firestore Rules lo impide. Solo el creador puede editar/eliminar.

**P: ¿Se ve el historial de cambios?**
R: No, pero Firestore guarda automáticamente versiones si lo activas.

---

**¡Todo listo para gestionar tus secretos! 🎉**
