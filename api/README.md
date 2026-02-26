# API (FastAPI)

Backend de `billeteraMobile` con FastAPI.

## Requisitos
- Python 3.11+ instalado globalmente (sin `.venv`).

## Instalar dependencias
```powershell
cd api
pip install -r requirements.txt
```

## Variables de entorno
1. Copia `.env.example` a `.env`.
2. Completa:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `SUPABASE_DB_URL` (para ejecutar migraciones SQL desde script)
     - Copia el URI exacto desde Supabase Dashboard -> Project Settings -> Database -> Connection string (URI)
     - Pooler (IPv4 recomendado): `postgresql://postgres.<ref>:<password>@aws-<n>-<region>.pooler.supabase.com:6543/postgres`
     - Directo (requiere IPv6 en muchos entornos): `postgresql://postgres:<password>@db.<ref>.supabase.co:5432/postgres`
     - No dejes placeholders como `[YOUR-PASSWORD]` o `YOUR_DB_PASSWORD`.

## Ejecutar en desarrollo
```powershell
cd api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints base
- `GET /health` -> estado del servicio.
- `GET /` -> información básica del API.

## Endpoints v1 (Auth + Profile)
- `POST /api/v1/auth/sign-up`
- `POST /api/v1/auth/sign-in`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/sign-out`
- `POST /api/v1/auth/reset-password`
- `GET /api/v1/auth/me`
- `GET /api/v1/profile`
- `PATCH /api/v1/profile`
- `GET /api/v1/cash-wallets`
- `POST /api/v1/cash-wallets`
- `PATCH /api/v1/cash-wallets/{wallet_id}`
- `DELETE /api/v1/cash-wallets/{wallet_id}`
- `GET /api/v1/bank-accounts`
- `POST /api/v1/bank-accounts`
- `PATCH /api/v1/bank-accounts/{account_id}`
- `DELETE /api/v1/bank-accounts/{account_id}`

## Tests
```powershell
cd api
pytest
```

## Migraciones Supabase
Si aun no has ejecutado migraciones en Supabase:

```powershell
cd api
python scripts/apply_migrations.py
```

Ver estado de migraciones:

```powershell
cd api
python scripts/migration_status.py
```
