# Barro Vivo

Aplicación móvil en Flutter para taller artesanal de talavera (Barro Vivo). Arquitectura **MVVM** con `Provider`, `GoRouter` y backend en **Supabase**.

---

## 📱 Conexión del Celular por Wi-Fi (ADB Wireless)

Tu herramienta `adb` se encuentra en:
```powershell
$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe
```

### Pasos para conectar tu dispositivo:

1. **Asegúrate de que la PC y el celular estén en la misma red Wi-Fi.**
2. En el teléfono: **Ajustes** → **Opciones de desarrollador** → activa **Depuración inalámbrica**.
3. Toca sobre **Depuración inalámbrica** → **Vincular el dispositivo con código de vinculación**.
4. En PowerShell en tu PC ejecuta:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" pair <IP_DEL_CELULAR>:<PUERTO_DE_VINCULACION>
   ```
   *Ingresa el código de 6 dígitos cuando te lo solicite.*
5. Si no se conecta en automático, revisa la IP y puerto general en la pantalla de depuración del celular y ejecuta:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" connect <IP_DEL_CELULAR>:<PUERTO_GENERAL>
   ```
6. Verifica que tu dispositivo aparezca en la lista:
   ```powershell
   flutter devices
   ```

---

## 🚀 Ejecutar la Aplicación

Para ejecutar la aplicación inyectando las variables de entorno de Supabase desde [.env](.env):

```powershell
flutter run --dart-define-from-file=.env
```

---

## 🔑 Credenciales de Prueba

La aplicación utiliza **Supabase Auth** con redirección por rol (`taller` o `cliente`).

### 1. Configuración previa recomendada en Supabase (Solo desarrollo):
En el panel de tu proyecto Supabase:
* Ve a **Authentication** → **Providers** → **Email**.
* Desactiva la casilla **"Confirm email"** y guarda. Esto te permitirá crear usuarios y acceder de inmediato sin esperar confirmación por correo.

### 2. Cuenta de prueba para el Taller (Artesano):
Puedes registrar esta cuenta directamente desde la pantalla de **Registro** de la app o crearla en el panel de Supabase:

* **Rol:** `Artesano / Taller`
* **Correo:** `taller@barrovivo.com`
* **Contraseña:** `BarroVivo123!`

*(El rol de Taller es el que tiene acceso a las pantallas de gestión de inventario y materias primas).*
