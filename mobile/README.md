# mobile

Flutter app para billeteraMobile.

## Stack
- Flutter 3.38+
- Riverpod 2
- GoRouter
- Dio
- flutter_secure_storage

## Configuracion
La app no usa claves Supabase directas en esta fase.

Define la URL del backend con `--dart-define`:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Flujo implementado
- Splash
- Login
- Registro
- Recuperar contrasena
- Sesion persistida (secure storage)
- Refresh token por interceptor HTTP
- Perfil basico (moneda base + toggle IA)
