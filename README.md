# billeteraMobile

App móvil de finanzas personales construida con Flutter + Supabase + FastAPI.

Alcance actual: desarrollo con paridad funcional en iOS y Android.

## Documentación
- [SRS_app_finanzas.md](./SRS_app_finanzas.md)
- [modulos_y_tareas_app_finanzas.md](./modulos_y_tareas_app_finanzas.md)

## Estructura
- `mobile/`: app Flutter (Riverpod + GoRouter, auth y perfil inicial).
- `api/`: backend FastAPI (`/api/v1/auth/*` y `/api/v1/profile`).
- `api/supabase/migrations/`: migraciones SQL versionadas para Supabase.

## Arranque rápido
1. API
```powershell
cd api
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
2. Mobile (Android emulador)
```powershell
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
3. Mobile (iOS simulador)
```powershell
cd mobile
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```
