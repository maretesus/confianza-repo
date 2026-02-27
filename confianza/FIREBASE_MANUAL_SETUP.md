# 🔥 Configuración Manual de Firebase (Sin CLI)

Si prefieres no instalar Firebase CLI, puedes configurar manualmente tu proyecto.

## 📋 Paso 1: Crear Proyecto en Firebase Console

1. Ve a https://console.firebase.google.com/
2. Haz clic en "Crear un proyecto"
3. Nombre: **Confianza** (puedes usar otro)
4. Desactiva Google Analytics (opcional)
5. Haz clic en "Crear proyecto"
6. Espera a que se cree

## 🔐 Paso 2: Obtener Configuración de Firebase

### Para Android:

1. En Firebase Console, ve a **Project Settings** (ícono ⚙️)
2. Ve a la pestaña **Your apps**
3. Haz clic en App Android (o crea uno si no existe)
4. Descarga `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`

### Para iOS:

1. Haz clic en App iOS en **Your apps**
2. Descarga `GoogleService-Info.plist`
3. Coloca el archivo en: `ios/Runner/GoogleService-Info.plist`

### Para Web y Windows:
Necesitarás el objeto de configuración JSON.

## 📝 Paso 3: Completar firebase_options.dart

### Opción A: Desde Project Settings

1. En Firebase Console, ve a **Project Settings**
2. Desplázate hasta abajo, verás un bloque con tu configuración
3. Copia cada valor según tu plataforma

### Opción B: Usar valores de ejemplo

```dart
// Para completar firebase_options.dart, necesitarás estos valores:
// - apiKey: De Firebase Console → Project Settings
// - appId: Del archivo google-services.json o GoogleService-Info.plist
// - projectId: Nombre de tu proyecto en Firebase
// - authDomain: {projectId}.firebaseapp.com
// - storageBucket: {projectId}.appspot.com
// - messagingSenderId: Se encuentra en firebase console
```

## 🎯 Paso 4: Habilitar Servicios en Firebase Console

### 1. Habilitar Firestore:
- Ve a **Firestore Database**
- Haz clic en **Create Database**
- Selecciona ubicación
- Elige **Testing Mode** (para desarrollo)
- Click crear

### 2. Habilitar Authentication:
- Ve a **Authentication**
- Click en **Get Started**
- Habilita **Email/Password**

## 🔒 Paso 5: Configurar Reglas de Firestore

Ve a **Firestore Database** → **Rules** y reemplaza con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios: solo pueden leer/escribir sus propios datos
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId;
    }

    // Secretos: todos pueden leer, solo autenticados pueden crear
    match /secrets/{secretId} {
      allow read: if request.auth.uid != null;
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📱 Paso 6: Instalar dependencias

```bash
flutter pub get
```

## ✅ Paso 7: Verificar que funciona

1. Abre Android Studio / Xcode u otro emulador
2. Ejecuta: `flutter run`
3. La app debe conectarse a Firebase automáticamente
4. Prueba registrarte / iniciar sesión
5. Verifica en Firebase Console que los usuarios se crean en `users` collection

---

## 🔍 Dónde encontrar tus credenciales en Firebase

### Opción 1: Project Settings
1. Haz clic en el ⚙️ (engranaje)
2. Ve a **Project Settings**
3. En la sección **Your apps**, selecciona tu plataforma
4. Verás todos los valores necesarios

### Opción 2: Desde google-services.json
Abre `google-services.json` descargado, contiene algo como:
```json
{
  "type": "service_account",
  "project_id": "confianza-xxxxx",
  "private_key_id": "...",
  ...
}
```

### Opción 3: Desde GoogleService-Info.plist
Si descargaste el `.plist`, abrelo con un editor de texto.

---

## 📊 Ejemplo Completo de firebase_options.dart

Aquí está como se vería completado:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890ABCDEFG',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'confianza-xxxxx',
    storageBucket: 'confianza-xxxxx.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890ABCDEFG',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'confianza-xxxxx',
    storageBucket: 'confianza-xxxxx.appspot.com',
    iosBundleId: 'com.example.confianza',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890ABCDEFG',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'confianza-xxxxx',
    authDomain: 'confianza-xxxxx.firebaseapp.com',
    storageBucket: 'confianza-xxxxx.appspot.com',
    measurementId: 'G-1234567890',
  );

  // macos, windows similares a ios/android
}
```

---

## 🚀 Listo!

Una vez completados estos pasos puedes ejecutar:

```bash
flutter run
```

¡Tu app estará conectada a Firebase Firestore! 🎉
