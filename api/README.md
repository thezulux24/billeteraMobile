# API (FastAPI)

Backend de `billeteraMobile` con FastAPI.

## Requisitos
- Python 3.11+ instalado globalmente (sin `.venv`).

## Instalar dependencias
```powershell
cd api
pip install -r requirements.txt
```

## Ejecutar en desarrollo
```powershell
cd api
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints base
- `GET /health` -> estado del servicio.
- `GET /` -> información básica del API.
