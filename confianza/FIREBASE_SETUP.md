# 🔥 Firebase Setup Guide - Confianza

Esta guía te ayudará a configurar Firebase y conectar tu app Flutter con Firestore.

## 1️⃣ Crear Proyecto en Firebase Console

### Paso 1: Acceder a Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Inicia sesión con tu cuenta de Google
3. Haz clic en "Crear un proyecto"

### Paso 2: Configurar el Proyecto
1. **Nombre del proyecto**: `Confianza` (o el que prefieras)
2. Acepta los términos y haz clic en "Continuar"
3. Desactiva "Google Analytics" (opcional, para desarrollo inicial) → "Crear proyecto"
4. Espera a que se cree el proyecto

---

## 2️⃣ Configurar Firebase para Flutter

### ⚠️ Opción A: Automática (Recomendado - pero requiere Firebase CLI)

Si tienes Node.js y npm instalados, ejecuta:

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Navega a la carpeta del proyecto
cd confianza

# Ejecuta la configuración
flutterfire configure
```

**Este comando automatiza todo** y actualiza `firebase_options.dart` automáticamente.

---

### ✅ Opción B: Manual (Más simple)

Si no quieres instalar Firebase CLI, puedes configurar manualmente:

#### Paso 1: Obtener credenciales de Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Abre tu proyecto
3. Ve a **Project Settings** (ícono de engranaje)
4. Copia el objeto JSON de configuración de tu plataforma
El archivo [firebase_options.dart](./lib/firebase_options.dart) debe tener valores reales como:
```dart
apiKey: 'AIzaSyD...'
appId: '1:123456:android:...'
projectId: 'confianza-xxxxx'
storageBucket: 'confianza-xxxxx.appspot.com'
```

Si ves `YOUR_...` todavía, lee **[FIREBASE_MANUAL_SETUP.md](./FIREBASE_MANUAL_SETUP.md)** para hacer la configuración manualmente sin Firebase CLI.

---

## 3️⃣ Configurar Firestore Database

### Paso 1: Crear Firestore Database
1. En Firebase Console, ve a **Firestore Database**
2. Haz clic en **"Crear base de datos"**
3. Selecciona tu ubicación (ej: us-central1)
4. Modo de seguridad: **TESTING** (para desarrollo)
   ```
   allow read, write: if true;
   ```

### Paso 2: Crear Colecciones (Estructura)
Firestore usará estas colecciones:

#### **Colección: `users`**
Documento de ejemplo:
```
users/
  {uid}/
    - email: "user@example.com"
    - username: "Anónimo_a1b2c3d4"
    - createdAt: 2024-02-26T10:30:00Z
```

#### **Colección: `secrets`**
Documento de ejemplo:
```
secrets/
  {secretId}/
    - userId: "uid_del_usuario"
    - title: "Mi primer secreto"
    - description: "Descripción del secreto"
    - videoUrl: "https://storage.googleapis.com/..."
    - category: "LOVE"
    - likes: 124
    - comments: 23
    - createdAt: 2024-02-26T10:30:00Z
    - isAnonymous: true
```

---

## 4️⃣ Configurar Seguridad (Firestore Rules)

### Reglas para Desarrollo (Testing)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios: solo pueden leer/escribir sus propios documentos
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }

    // Secretos: todos pueden leer, solo autenticados pueden escribir
    match /secrets/{secretId} {
      allow read: if request.auth.uid != null;
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### Reglas para Producción (más seguras)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }

    // Secretos
    match /secrets/{secretId} {
      allow read: if request.auth.uid != null && request.auth.uid != null;
      allow create: if request.auth.uid != null && 
                       request.resource.data.userId == request.auth.uid &&
                       request.resource.data.createdAt == request.time;
      allow update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 5️⃣ Configurar Authentication (Firebase Auth)

### Paso 1: Habilitar Email/Password
1. En Firebase Console, ve a **Authentication**
2. Ve a la pestaña **Sign-in method**
3. Habilita **Email/Password**

### Paso 2: Prueba de Autenticación
El código en [AuthService](./lib/features/auth/services/auth_service.dart) ya maneja:
- Registro con email/password
- Login con email/password
- Guardar usuario en Firestore automáticamente

---

## 6️⃣ Instalar Dependencias

Ejecuta en la terminal del proyecto:
```bash
flutter pub get
```

Esto instalará:
- ✅ `firebase_core: ^2.28.0`
- ✅ `cloud_firestore: ^4.16.0`
- ✅ `firebase_auth: ^4.18.0`

---

## 7️⃣ Ejecutar la App

```bash
flutter run
```

### Primera ejecución
- Firebase se inicializará automáticamente
- Verá el emulador/dispositivo conectarse a Firestore
- Los usuarios pueden registrarse/iniciar sesión
- Los secretos se guardan en Firestore en tiempo real

---

## 📁 Estructura de Código Añadida

```
lib/
  firebase_options.dart           # ← Configuración de Firebase (generada)
  
  features/
    auth/                         # ← NUEVO: Autenticación
      models/
        user.dart                 # Modelo de usuario
      services/
        auth_service.dart         # Lógica de Firebase Auth
      providers/
        auth_providers.dart       # Providers de Riverpod para auth
    
    secrets/
      models/
        secret.dart               # ← ACTUALIZADO: cambios para Firestore
      services/
        secret_service.dart       # ← REEMPLAZADO: ahora usa Firestore
      providers/
        secrets_providers.dart    # ← ACTUALIZADO: ahora usa Streams
```

---

## 🐛 Troubleshooting

### Error: "You don't have permission to access..."
**Solución**: Ve a Firestore Rules en Firebase Console y asegúrate que permitas reads/writes. Comienza con testing mode.

### Error: "MissingPluginException"
**Solución**: Ejecuta `flutter clean` y luego `flutter pub get`

### Error: "Unable to locate Android SDK"
**Solución**: Asegúrate que tienes Android SDK configurado o usa emulador iOS

### Los datos no sincronizado
**Verificar**:
1. ¿Está Firestore creado en Firebase Console?
2. ¿Las Firestore Rules permiten reads/writes?
3. ¿El usuario está autenticado?

---

## 📊 Flujo de la App Ahora

```
1. Usuario abre app
   ↓
2. AuthStateProvider observa si hay usuario autenticado
   ↓
3. Si NO hay usuario → Muestra pantalla de Login/Register
   ↓
4. Usuario se registra/inicia sesión con Firebase Auth
   ↓
5. Automáticamente se crea documento en Firestore `users/{uid}`
   ↓
6. Si SÍ hay usuario → Muestra secretos desde Firestore en TIEMPO REAL
   ↓
7. Los secretos se actualizan automáticamente cuando otros usuarios añaden/modifican
```

---

## ✅ Tareas Completadas

- ✅ Dependencias Firebase añadidas a `pubspec.yaml`
- ✅ Firebase inicializado en `main.dart`
- ✅ `firebase_options.dart` creado (necesita configuración)
- ✅ `AuthService` implementado con Firebase Auth
- ✅ `AuthProviders` creados con Riverpod
- ✅ Modelo `Secret` actualizado para Firestore
- ✅ `SecretService` reemplazado para usar Firestore en lugar de mock data
- ✅ `secretsProvider` cambió a Streams (actualizaciones en tiempo real)
- ✅ Guía de setup

## 🎯 Próximos Pasos

### ⚡ Camino Rápido (Recomendado):
1. **Lee [FIREBASE_MANUAL_SETUP.md](./FIREBASE_MANUAL_SETUP.md)** - es mucho más simple
   - No requiere instalar Firebase CLI
   - Solo copia y pega valores de Firebase Console
   - Toma ~15 minutos

### 🔧 Camino Automático (requiere Node.js):
1. Ejecutar `flutterfire configure` 
2. Crear proyecto en Firebase Console
3. Configurar Firestore Database
4. Configurar reglas de seguridad
5. Probar login/registro
6. Probar crear/ver secretos

¡Tu app ya está lista para funcionar con Firebase! 🚀
