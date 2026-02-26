# Bloqueo actual: Android build

## Checklist de validacion

| ID | Descripcion | Estado | Comando/Evidencia | Fecha |
| --- | --- | --- | --- | --- |
| T-001 | Alinear Gradle wrapper a 8.14 | DONE | `distributionUrl` actualizado a `gradle-8.14-all.zip` | 2026-02-25 |
| T-002 | Validar gradle version efectiva | DONE | `./gradlew.bat -v` => `Gradle 8.14` | 2026-02-25 |
| T-003 | Ejecutar `flutter analyze` | DONE | `No issues found!` | 2026-02-25 |
| T-004 | Ejecutar `flutter test` | DONE | `All tests passed!` | 2026-02-25 |
| T-005 | Ejecutar `flutter build apk --debug` | DONE | `Built .../app-debug.apk` | 2026-02-25 |
| T-006 | Ejecutar `flutter run` en emulador | DONE | `Launching lib/main.dart ... Syncing files to device` | 2026-02-25 |

## Historial de ejecuciones

| ID | Estado | Evidencia resumida | Fecha |
| --- | --- | --- | --- |
| T-001 | DONE | Wrapper migrado de Gradle 7.3.1 a 8.14. | 2026-02-25 |
| T-002 | DONE | Gradle efectivo validado con `./gradlew.bat -v`. | 2026-02-25 |
| T-003 | DONE | `flutter analyze` sin issues. | 2026-02-25 |
| T-004 | DONE | `flutter test` con 1 test OK. | 2026-02-25 |
| T-005 | DONE | APK debug generado exitosamente. | 2026-02-25 |
| T-006 | DONE | App ejecutada en `emulator-5554` con `--no-resident`. | 2026-02-25 |

## Gate completado

- Estado: COMPLETADO
- Fecha: 2026-02-25
- Resultado final: Android debug desbloqueado (`analyze + test + build apk + run` OK).

# Bloque actual: Supabase migrations + UI premium

## Checklist de validacion

| ID | Descripcion | Estado | Comando/Evidencia | Fecha |
| --- | --- | --- | --- | --- |
| M-001 | Configurar `SUPABASE_DB_URL` en `api/.env` | BLOCKED | URI actual invalida/no enrutable: requiere pooler IPv4 + password real sin `[]` | 2026-02-26 |
| M-002 | Validar dependencias API para migraciones | DONE | `pip install -r requirements.txt` instala `psycopg-binary-3.3.3` | 2026-02-26 |
| M-003 | Verificar estado de migraciones | BLOCKED | `python scripts/migration_status.py` => hint de URL invalida + `getaddrinfo failed` en host `db.*` | 2026-02-26 |
| M-004 | Aplicar migracion inicial `0001_auth_profiles.sql` | BLOCKED | `python scripts/apply_migrations.py` => mismo bloqueo de conectividad/URI | 2026-02-26 |
| M-005 | Redisenar Auth/Profile con estilo premium | DONE | Glass UI + banner + jerarquia tipografica + layout responsive | 2026-02-26 |
| M-006 | Ejecutar calidad Flutter tras rediseno | DONE | `flutter analyze` sin issues, `flutter test` all passed | 2026-02-26 |
| M-007 | Ejecutar suite API | DONE | `pytest` => `7 passed` | 2026-02-26 |
| M-008 | Confirmar compilacion y arranque Android | DONE | `flutter build apk --debug` + `flutter run -d emulator-5554 --no-resident` OK | 2026-02-26 |
| M-009 | Quitar menciones de plataforma en UI auth | DONE | Tag `iOS + Android` removido de `BrandBanner` | 2026-02-26 |
| M-010 | Hacer funcional `sign-up/login` contra backend | DONE | Sign-up ahora usa admin create user + sign-in con `service_role` | 2026-02-26 |
| M-011 | Verificar flujo real auth end-to-end | DONE | Script backend: `signup_ok: True`, `signin_ok: True` | 2026-02-26 |
| M-012 | Iniciar siguiente task de Fase 2 (modelo financiero) | DONE | Creada migracion `0002_finance_core.sql` con RLS + soft delete | 2026-02-26 |
| M-013 | Diagnosticar conectividad app->backend reportada por usuario | DONE | API local `health: ok`, `sign-up` local retorna 200 con tokens | 2026-02-26 |
| M-014 | Mejorar feedback de error de red en mobile auth | DONE | Mensaje explicito con host/puerto cuando no hay conexion a backend | 2026-02-26 |
| M-015 | Forzar navegacion post login/registro en UI | DONE | `context.go('/profile')` tras auth exitosa en login/register | 2026-02-26 |
| M-016 | Asegurar HTTP local en Android debug | DONE | `android:usesCleartextTraffic=\"true\"` en manifest principal | 2026-02-26 |
| M-017 | Implementar modulo API `cash_wallets` (CRUD + soft delete) | DONE | Nuevo endpoint/service/schema/tests para `/api/v1/cash-wallets` | 2026-02-26 |

## Historial de ejecuciones

| ID | Estado | Evidencia resumida | Fecha |
| --- | --- | --- | --- |
| M-001 | BLOCKED | `SUPABASE_DB_URL` requiere correccion: no usar password entre `[]` y usar endpoint pooler IPv4 valido del dashboard. | 2026-02-26 |
| M-002 | DONE | Runtime de migraciones listo con `psycopg` + `psycopg-binary`. | 2026-02-26 |
| M-003 | BLOCKED | Script de estado falla por URL no parseable y `db.<ref>.supabase.co` no resoluble en este entorno. | 2026-02-26 |
| M-004 | BLOCKED | Aplicacion de migracion bloqueada por la misma configuracion de conexion DB. | 2026-02-26 |
| M-005 | DONE | Pantallas `splash/login/register/forgot/profile` con diseño glass profesional y consistente iOS/Android. | 2026-02-26 |
| M-006 | DONE | Calidad minima movil validada despues del rediseno. | 2026-02-26 |
| M-007 | DONE | Tests backend de auth/profile exitosos. | 2026-02-26 |
| M-008 | DONE | APK debug generado y app lanzada en emulador Android. | 2026-02-26 |
| M-009 | DONE | Interfaz actualizada sin el badge de plataforma (`iOS + Android`). | 2026-02-26 |
| M-010 | DONE | Auth robusto: parseo de `session` anidada, alta admin con service role y fallback a sign-in. | 2026-02-26 |
| M-011 | DONE | Validacion real contra Supabase confirmo alta/inicio de sesion funcional. | 2026-02-26 |
| M-012 | DONE | Arrancada Fase 2 con migracion SQL versionada para billeteras/cuentas/tarjetas/categorias/transacciones. | 2026-02-26 |
| M-013 | DONE | Confirmado backend activo en `:8000` y endpoint de registro funcional desde host local. | 2026-02-26 |
| M-014 | DONE | App ahora muestra error de conectividad claro en vez de mensaje generico. | 2026-02-26 |
| M-015 | DONE | Navegacion de auth ya no depende solo del guard global; login/register redirigen directamente al perfil. | 2026-02-26 |
| M-016 | DONE | Configurado cleartext traffic para desarrollo Android con API HTTP local. | 2026-02-26 |
| M-017 | DONE | Primera pieza de Fase 2 lista en backend: cash wallets con RLS via token, CRUD y eliminacion logica. | 2026-02-26 |
