# 🐛 Troubleshooting: "No termina nunca de subir el video"

## ⚡ SOLUCIÓN RÁPIDA (99% de casos)

### Paso 1: Verificar Firebase Storage Rules ✅
1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Proyecto **confident-f42af** → **Storage** → **Rules**
3. Reemplaza TODO el contenido con esto:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /videos/{filename} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

4. Haz clic en **Publish**
5. Espera a que aparezca "✅ Rules published" en verde

---

## 🔍 Si aún falla, verifica estos puntos:

### 1. **¿Estoy logueado?**
- En la app, ve a **Profile** o similar
- Si no ves tu email/usuario, **no estás autenticado**
- La subida REQUIERE estar logueado en Firebase Auth

### 2. **¿El video es muy grande?**
- En **web**: máximo **20MB**
- En **mobile**: máximo **100MB**
- Comprueba el tamaño:
  - Windows: Click derecho → Propiedades
  - Mac: Click derecho → Obtener información

### 3. **¿Tengo conexión a internet?**
- Abre Google en el navegador
- Si Google no carga, no tienes internet
- Si tienes internet lento, la subida tarda más

### 4. **Abre la Consola de Desarrollador (F12)**
- Presiona **F12** en el navegador
- Ve a **Console**
- ¿Ves estos logs?
  ```
  📤 Upload attempt 1/3
  File size: XX.XXMB
  Uploading to Firebase Storage: videos/xxxxx.mp4
  ⏱️ Waiting for upload to complete...
  Progress: 25%...
  Progress: 50%...
  Progress: 100%...
  ✅ Video uploaded successfully!
  ```

---

## 🚨 Mensajes de Error Comunes y Soluciones

### Error 1: ❌ "Permission denied"
```
Error: User does not have permission...
```
**SOLUCIÓN**: Las Storage Rules no están bien configuradas
1. Ve a Storage → Rules
2. Asegúrate de tener el código correcto (arriba)
3. Haz clic en **Publish**

---

### Error 2: ❌ "CORS error" o "Network error"
```
Error: A CORS request was made...
Error: Network error...
```
**SOLUCIONES**:
1. **Recarga la página** (Ctrl+Shift+R para limpiar caché)
2. **Usa otro navegador** (Chrome, Firefox, Edge)
3. **Prueba en modo incógnito** (evita extensiones)
4. **Reinicia el navegador completamente**

---

### Error 3: ❌ "Upload timeout"
```
⏰ Upload timeout - cancelling...
⏰ Attempt 1 failed: timeout
```
**SOLUCIONES**:
1. **Video muy grande**: reduce tamaño a máximo 20MB
2. **Conexión lenta**: espera a tener mejor conexión
3. **Servidor lejano**: es normal (tarda 1-2 minutos)
4. La app **reintentar automáticamente 3 veces**

---

### Error 4: ❌ "File too large for web"
```
❌ File too large for web: 45.23MB (max 20MB)
```
**SOLUCIÓN**: Comprime el video
- Tamaño máximo: **20MB**
- Usa [CloudConvert](https://cloudconvert.com/) o similar
- O graba en **calidad más baja**

---

## 📋 Checklist Final

- [ ] Firebase Storage Rules configuradas (Ver Paso 1 arriba)
- [ ] Estoy logueado en la app
- [ ] Video es menor a 20MB
- [ ] Tengo conexión a internet estable
- [ ] He recargado la página (Ctrl+Shift+R)
- [ ] He esperado al menos 2 minutos
- [ ] Abrí Console (F12) para ver logs

---

## 📞 Si aún falla después de todo:

1. **Copia los logs de la consola** (F12 → Console)
2. **Abre un issue en GitHub** con:
   - Los logs
   - Tamaño del video
   - Navegador y versión
   - Sistema operativo

---

## ⚙️ Cambios Recientes del Código

Se han realizado las siguientes mejoras:

✅ **Timeout reducido**: de 5 minutos a 2 minutos  
✅ **Reintentos automáticos**: hasta 3 intentos  
✅ **Better logging**: logs detallados para diagnósticos  
✅ **Mejor UI**: mensajes de error más informativos  

Los cambios son **automáticos**, no necesitas hacer nada más.
