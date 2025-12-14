from fastapi import FastAPI, Header, HTTPException

app = FastAPI(title="Cyber-DevOps API")

@app.get("/")
def root():
    return {"status": "API sécurisée opérationnelle"}

@app.get("/secure")
def secure_endpoint(authorization: str = Header(None)):
    if authorization is None:
        raise HTTPException(status_code=401, detail="Token manquant")
    return {"message": "Accès autorisé avec token"}
