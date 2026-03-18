# 🔥 Cloud Functions - Confianza

## Descripción

Cloud Function que envía un email al administrador automáticamente cuando un usuario reporta un secreto.

## 📋 Requisitos Previos

- Firebase CLI instalado: `npm install -g firebase-tools`
- Proyecto Firebase configurado
- SendGrid API Key (gratis para primeros 100 emails/día)

## 🔑 Paso 1: Obtener SendGrid API Key

### 1.1 Crear Cuenta en SendGrid
1. Ve a [SendGrid](https://sendgrid.com/)
2. Haz clic en "Sign Up"
3. Completa el formulario con tus datos
4. Verifica tu email

### 1.2 Generar API Key
1. Login en SendGrid Dashboard
2. Ve a **Settings** → **API Keys** (en la izquierda)
3. Haz clic en **Create API Key**
4. Dale un nombre: `Confianza Reports`
5. Selecciona permisos: `Mail Send` (Full Access)
6. Haz clic en **Create & Use**
7. **Copia la clave** (aparece una sola vez)

## 🚀 Paso 2: Configurar Firebase

### 2.1 Inicializar Cloud Functions
```bash
cd functions
npm install
```

### 2.2 Configurar Secretos en Firebase
```bash
firebase functions:config:set sendgrid.api_key="SG.xxx..."
```

Reemplaza `SG.xxx...` con tu API Key de SendGrid.

## 📤 Paso 3: Realizar Cambios en Firestore Rules

En **Firebase Console → Firestore → Rules**, agrega estas reglas:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Tus reglas existentes...
    
    // Permitir crear reportes
    match /reports/{reportId} {
      allow create: if true; // Cualquiera puede reportar
      allow read, write: if request.auth.token.admin == true; // Solo admin
    }
  }
}
```

## 🚀 Paso 4: Desplegar Cloud Function

```bash
npm run deploy
```

O si estás en la carpeta del proyecto:
```bash
firebase deploy --only functions
```

## ✅ Verificar que Funciona

### Opción 1: Desde Firebase Console
1. Ve a **Cloud Functions**
2. Busca `sendReportEmail`
3. Debe estar en estado **OK**

### Opción 2: Crear un reporte de prueba
1. Abre tu app
2. Reporta un secreto
3. Llena el formulario con tus datos
4. Verifica tu email en **firebaseconfident@gmail.com**

### Opción 3: Ver logs
```bash
npm run logs
```

## 📧 Qué recibe el Admin

El email incluye:

- ✅ ID del reporte
- ✅ ID del secreto reportado
- ✅ Email de quien reporta (para responder)
- ✅ Razón del reporte
- ✅ Comentario del reportador
- ✅ Contenido del secreto
- ✅ Fecha y hora
- ✅ Estado del reporte
- ✅ Información del secreto original (categoría, fecha, etc.)

## 🔄 Actualizar la Cloud Function

Después de hacer cambios en `src/index.js`:

```bash
npm run deploy
```

## 🧪 Desarrollo Local (Emulator)

Para probar localmente sin desplegar:

```bash
firebase emulators:start --only functions,firestore
```

## 📝 Nota Importante

- SendGrid permite 100 emails gratis/día
- Para más emails, necesitas un plan pagado
- Los logs y reportes se guardan en Firestore
- El email es enviado automáticamente después de insertar el reporte

## ⚠️ Solución de Problemas

### Email no llega
- Verifica que la API Key de SendGrid está configurada: `firebase functions:config:get`
- Revisa el email de SendGrid en el que se registraste (podría estar en spam)

### Función en error
- Verifica logs: `npm run logs`
- Asegúrate que las rutas de Firestore son correctas

### Timeout
- Aumenta el timeout en `firebase.json`: `"timeoutSeconds": 120`
