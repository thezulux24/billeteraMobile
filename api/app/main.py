from fastapi import FastAPI

app = FastAPI(
    title="Billetera API",
    version="0.1.0",
    description="Backend API for billeteraMobile.",
)


@app.get("/", tags=["meta"])
def root() -> dict[str, str]:
    return {"service": "billetera-api", "version": "0.1.0"}


@app.get("/health", tags=["health"])
def health() -> dict[str, str]:
    return {"status": "ok"}
