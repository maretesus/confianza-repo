# 📋 Sistema de Reportes - Setup Simplificado

## ¿Qué hace?

Usuarios pueden reportar secretos con un simple comentario. Los reportes se guardan en Firestore y se envían por email automáticamente a **firebaseconfident@gmail.com** con:

- ✅ ID del secreto
- ✅ Comentario del usuario
- ✅ Fecha y hora

**Sin necesidad de que el usuario dé su email.**

---

## 🚀 Setup en 3 pasos

### Paso 1: Firestore Rules

Ve a **Firebase Console** → **Firestore** → **Rules**:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Permitir crear reportes (cualquiera)
    match /reports/{reportId} {
      allow create: if true;
      allow read: if request.auth.token.admin == true;
    }
    
    // Tus otras reglas va aquí...
  }
}
```

Haz clic en **Publish**.

---

### Paso 2: SendGrid (para recibir emails)

1. Crea cuenta gratis: [sendgrid.com](https://sendgrid.com)
2. Verifica tu email
3. **Settings** → **API Keys** → **Create API Key**
4. Nombre: `Confianza`
5. Permisos: `Mail Send`
6. Copia la clave

Luego en terminal:

```bash
firebase functions:config:set sendgrid.api_key="SG.tuApiKey"
```

---

### Paso 3: Deploy

```bash
cd functions
npm install
npm run deploy
```

---

## ✅ Probar

1. Abre app → Ve a un secreto
2. Botón **"Reportar"** (rojo)
3. Escribe comentario
4. Haz clic en **"Enviar"**
5. Revisa email en **firebaseconfident@gmail.com**

---

## 📊 Estructura Firestore

```
reports/
├── {reportId}/
│   ├── secretId: "id..."
│   ├── comment: "Texto del reporte"
│   └── createdAt: Timestamp
```

---

## 🆘 Problemas

**Sin emails:**
- ¿API Key configurada? → `firebase functions:config:get`
- Revisa logs: `firebase functions:log`

---

¡Listo! 🎉
