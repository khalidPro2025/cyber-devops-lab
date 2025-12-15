from fastapi import FastAPI, Header, HTTPException
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="Cyber-DevOps API")

# Instrumentation Prometheus
Instrumentator().instrument(app).expose(app)

@app.get("/")
def root():
    return {"status": "API sécurisée opérationnelle"}

@app.get("/secure")
def secure(authorization: str = Header(None)):
    if authorization is None:
        raise HTTPException(status_code=401, detail="Token manquant")

    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Format du token invalide")

    return {"message": "Accès autorisé (IAM externe Keycloak)"}
