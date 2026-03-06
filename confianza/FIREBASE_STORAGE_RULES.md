# 🔥 Firebase Storage Rules - Confianza

## ⚠️ PROBLEMA IDENTIFICADO

La subida de videos probablemente falla porque **Firebase Storage no tiene reglas de seguridad configuradas**. Sin estas reglas, el navegador no puede subir archivos.

## ✅ SOLUCIÓN: Configurar Storage Rules

### Paso 1: Abrir Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **confident-f42af**
3. En la izquierda, ve a **Build** → **Storage**
4. Haz clic en la pestaña **Rules**

### Paso 2: Reemplazar las reglas

**Para DESARROLLO (permite cualquier subida - ⚠️ NO SEGURO)**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir todo por ahora (solo desarrollo)
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Paso 3: Guardar las reglas
1. Haz clic en **Publish**
2. Espera a que se publique (debería tardar menos de 1 minuto)

---

## 🔐 Reglas para PRODUCCIÓN (Recomendado después)

Una vez que funcione, usa estas reglas más seguras:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir solo usuarios autenticados subir videos en la carpeta /videos
    match /videos/{filename} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.size < 100 * 1024 * 1024 && // Máximo 100MB
                       request.resource.contentType.matches('video/.*');
      allow update, delete: if false; // No permitir modificación después de subida
    }
    
    // Denegar acceso a cualquier otro lugar
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 🐛 Verificar que funciona

1. En la app, intenta subir un video
2. Abre DevTools (F12) en el navegador
3. Ve a la pestaña **Console**
4. Verifica que veas logs como:
   ```
   Starting web video upload for: mi_video.mp4
   Upload progress: 25% ...
   Upload progress: 50% ...
   Upload progress: 100% ...
   Web video uploaded successfully: https://...
   ```

### Si aún falla:
- El error debería aparecer en la consola
- Los errores comunes:
  - ❌ "Permission denied" → Las Storage Rules no permiten subida
  - ❌ "CORS error" → Problema de navegador/CORS
  - ❌ "Network error" → Problema de conexión a internet

---

## 📝 Próximos pasos

Una vez que funcione la subida:
1. ✅ Configura las **Control de acceso por usuario** en las rules
2. ✅ Establece límites de tamaño de archivo
3. ✅ Considera seguridad de CORS si es necesario
