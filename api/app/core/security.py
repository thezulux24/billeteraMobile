import asyncio
import time
from typing import Any

from jose import JWTError, jwk, jwt
from jose.utils import base64url_decode

from app.clients.supabase_auth import SupabaseAuthClient
from app.core.config import Settings
from app.core.exceptions import AppException


class SupabaseJwtVerifier:
    def __init__(self, settings: Settings, auth_client: SupabaseAuthClient) -> None:
        self._settings = settings
        self._auth_client = auth_client
        self._jwks_by_kid: dict[str, dict[str, Any]] = {}
        self._jwks_expires_at = 0.0
        self._lock = asyncio.Lock()

    async def _load_jwks(self, *, force: bool = False) -> None:
        now = time.time()
        if not force and self._jwks_by_kid and now < self._jwks_expires_at:
            return

        async with self._lock:
            now = time.time()
            if not force and self._jwks_by_kid and now < self._jwks_expires_at:
                return

            payload = await self._auth_client.get_jwks()
            keys = payload.get("keys", [])
            self._jwks_by_kid = {
                key["kid"]: key for key in keys if isinstance(key, dict) and key.get("kid")
            }
            self._jwks_expires_at = now + self._settings.jwks_cache_ttl_seconds

    async def verify_access_token(self, token: str) -> dict[str, Any]:
        await self._load_jwks()
        return await self._verify(token)

    async def _verify(self, token: str) -> dict[str, Any]:
        try:
            header = jwt.get_unverified_header(token)
            claims = jwt.get_unverified_claims(token)
        except JWTError as exc:
            raise AppException(
                status_code=401,
                code="INVALID_TOKEN",
                message="Malformed token.",
                details=str(exc),
            ) from exc

        kid = header.get("kid")
        alg = header.get("alg")
        if not kid or not alg:
            raise AppException(
                status_code=401,
                code="INVALID_TOKEN_HEADER",
                message="Token header is missing kid/alg.",
            )

        jwk_data = self._jwks_by_kid.get(kid)
        if not jwk_data:
            await self._load_jwks(force=True)
            jwk_data = self._jwks_by_kid.get(kid)
            if not jwk_data:
                raise AppException(
                    status_code=401,
                    code="UNKNOWN_KEY_ID",
                    message="Token key id is unknown.",
                )

        self._verify_signature(token, jwk_data)
        self._verify_claims(claims)
        return claims

    @staticmethod
    def _verify_signature(token: str, key_data: dict[str, Any]) -> None:
        key = jwk.construct(key_data)
        message, encoded_signature = token.rsplit(".", 1)
        decoded_signature = base64url_decode(encoded_signature.encode("utf-8"))
        if not key.verify(message.encode("utf-8"), decoded_signature):
            raise AppException(
                status_code=401,
                code="INVALID_SIGNATURE",
                message="Token signature validation failed.",
            )

    def _verify_claims(self, claims: dict[str, Any]) -> None:
        now = int(time.time())
        exp = claims.get("exp")
        nbf = claims.get("nbf")
        iss = claims.get("iss")
        aud = claims.get("aud")

        if exp is None or int(exp) <= now:
            raise AppException(
                status_code=401,
                code="TOKEN_EXPIRED",
                message="Token has expired.",
            )

        if nbf is not None and int(nbf) > now:
            raise AppException(
                status_code=401,
                code="TOKEN_NOT_YET_VALID",
                message="Token is not valid yet.",
            )

        expected_issuer = self._settings.supabase_jwt_issuer
        if not expected_issuer:
            expected_issuer = f"{str(self._settings.supabase_url).rstrip('/')}/auth/v1"
        if iss != expected_issuer:
            raise AppException(
                status_code=401,
                code="INVALID_ISSUER",
                message="Token issuer is invalid.",
            )

        expected_audience = self._settings.supabase_jwt_audience
        if expected_audience:
            audiences: list[str]
            if isinstance(aud, str):
                audiences = [aud]
            elif isinstance(aud, list):
                audiences = [str(item) for item in aud]
            else:
                audiences = []
            if expected_audience not in audiences:
                raise AppException(
                    status_code=401,
                    code="INVALID_AUDIENCE",
                    message="Token audience is invalid.",
                )

