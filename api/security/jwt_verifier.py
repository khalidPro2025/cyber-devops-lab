from jose import jwt
import requests

KEYCLOAK_URL = "https://auth.ktech.sn:8443"
REALM = "pme"
CLIENT_ID = "api-client"

jwks = requests.get(
    f"{KEYCLOAK_URL}/realms/{REALM}/protocol/openid-connect/certs"
).json()

def verify_token(token):
    header = jwt.get_unverified_header(token)
    key = next(k for k in jwks["keys"] if k["kid"] == header["kid"])

    return jwt.decode(
        token,
        key,
        algorithms=["RS256"],
        audience=CLIENT_ID,
        issuer=f"{KEYCLOAK_URL}/realms/{REALM}"
    )
