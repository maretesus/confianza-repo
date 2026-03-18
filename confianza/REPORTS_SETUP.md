# 📋 Guía Rápida: Sistema de Reportes con Emails

## ¿Qué se implementó?

El sistema permite que usuarios reporten secretos inapropiados indicando su email. Los reportes se envían automáticamente a **firebaseconfident@gmail.com**.

---

## 🎯 Paso 1: Actualizar Firestore Rules

Ve a **Firebase Console** → **Firestore Database** → **Rules** y actualiza:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Secretos: solo lectura pública, escribir si autenticado
    match /secrets/{secretId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }

    // Reportes: cualquiera puede crear
    match /reports/{reportId} {
      allow create: if true;
      allow read: if request.auth.token.admin == true;
    }

    // Comentarios: lectura pública, crear si existe
    match /secrets/{secretId}/comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null || request.auth == null;
    }

    // Usuarios: acceso propio
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Luego haz clic en **Publish**.

---

## 🚀 Paso 2: Desplegar Cloud Functions

### 2.1 Instalar Firebase CLI (si no lo tienes)
```bash
npm install -g firebase-tools
firebase login
```

### 2.2 Ir a la carpeta de functions
```bash
cd functions
npm install
```

### 2.3 Configurar SendGrid API Key

1. **Crea cuenta en SendGrid** (https://sendgrid.com/)
   - Sign up gratis
   - Verifica email
   
2. **Genera API Key**
   - Login en SendGrid
   - Settings → API Keys
   - Create API Key
   - Nombre: "Confianza Reports"
   - Permisos: Mail Send
   - Copia la clave (aparece 1 sola vez)

3. **Configura en Firebase**
```bash
firebase functions:config:set sendgrid.api_key="SG.tuApiKeyAqui"
```

### 2.4 Desplega
```bash
npm run deploy
```

O desde la raíz:
```bash
firebase deploy --only functions
```

---

## ✅ Paso 3: Verificar que Funciona

### Opción A: Test Manual en la App
1. Abre tu app Flutter
2. Ve a un secreto
3. Haz clic en el botón "Reportar" (abajo, después de likes/comentarios)
4. Llena el formulario:
   - Email: tu email
   - Razón: selecciona una
   - Comentario: opcional
5. Haz clic en "Enviar reporte"
6. Revisa si recibiste email en **firebaseconfident@gmail.com**

### Opción B: Ver Logs
```bash
firebase functions:log
```

### Opción C: Firebase Console
1. Ve a **Cloud Functions**
2. Busca `sendReportEmail`
3. Debe estar en estado **OK** (verde)

---

## 📧 Email que Recibe el Admin

El email contiene:
- 📍 ID del reporte
- 🎯 ID del secreto reportado
- 📧 Email de quien reporta (puedes responder)
- 🚨 Razón (Spam, Violencia, etc.)
- 💬 Comentario adicional
- 📝 Contenido del secreto
- ⏰ Fecha y hora
- 🏷️ Categoría del secreto

---

## 🆘 Solucionar Problemas

### ❌ El email no llega
- Verifica la API Key: `firebase functions:config:get`
- Revisa spam en firebaseconfident@gmail.com
- Verifica logs: `firebase functions:log`

### ❌ Función en error
```bash
firebase functions:log
```
Busca "Error" para ver qué falló

### ❌ "SENDGRID_API_KEY no configurada"
```bash
firebase functions:config:set sendgrid.api_key="SG.xxx"
firebase deploy --only functions
```

---

## 📦 Archivos Implementados

```
lib/features/secrets/
├── models/
│   └── report.dart              ← Modelo de reporte
├── services/
│   └── report_service.dart      ← Servicio Firestore
├── widgets/
│   └── report_dialog.dart       ← Dialog con formulario
├── screens/
│   └── secret_detail_screen.dart ← Botón agregado
└── providers/
    └── secrets_providers.dart    ← Providers para reportes

functions/
├── package.json                 ← Dependencias
├── firebase.json                ← Configuración
├── src/index.js                 ← Cloud Function
├── README.md                    ← Documentación
└── .env.example                 ← Variables de entorno
```

---

## 🎉 ¡Listo!

Te recomiendo seguir el Paso 1 (Firestore Rules) y Paso 2 (Deploy) para que el sistema esté completamente funcional.

Si tienes dudas, revisa los logs con `firebase functions:log`.
