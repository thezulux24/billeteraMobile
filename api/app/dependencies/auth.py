from dataclasses import dataclass

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.clients.supabase_auth import SupabaseAuthClient
from app.clients.supabase_rest import SupabaseRestClient
from app.core.config import Settings, get_settings
from app.core.exceptions import AppException
from app.core.security import SupabaseJwtVerifier
from app.services.auth_service import AuthService
from app.services.cash_wallet_service import CashWalletService
from app.services.profile_service import ProfileService

bearer_scheme = HTTPBearer(auto_error=False)

_jwt_verifier: SupabaseJwtVerifier | None = None


def get_auth_client(settings: Settings = Depends(get_settings)) -> SupabaseAuthClient:
    return SupabaseAuthClient(settings)


def get_rest_client(settings: Settings = Depends(get_settings)) -> SupabaseRestClient:
    return SupabaseRestClient(settings)


def get_auth_service(
    auth_client: SupabaseAuthClient = Depends(get_auth_client),
) -> AuthService:
    return AuthService(auth_client)


def get_profile_service(
    rest_client: SupabaseRestClient = Depends(get_rest_client),
) -> ProfileService:
    return ProfileService(rest_client)


def get_cash_wallet_service(
    rest_client: SupabaseRestClient = Depends(get_rest_client),
) -> CashWalletService:
    return CashWalletService(rest_client)


def get_jwt_verifier(
    settings: Settings = Depends(get_settings),
    auth_client: SupabaseAuthClient = Depends(get_auth_client),
) -> SupabaseJwtVerifier:
    global _jwt_verifier
    if _jwt_verifier is None:
        _jwt_verifier = SupabaseJwtVerifier(settings=settings, auth_client=auth_client)
    return _jwt_verifier


@dataclass
class AuthContext:
    user_id: str
    access_token: str
    email: str
    last_sign_in_at: str | None = None


async def get_auth_context(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    auth_service: AuthService = Depends(get_auth_service),
    verifier: SupabaseJwtVerifier = Depends(get_jwt_verifier),
) -> AuthContext:
    if credentials is None or not credentials.credentials:
        raise AppException(
            status_code=401,
            code="MISSING_TOKEN",
            message="Authorization token is required.",
        )

    token = credentials.credentials
    claims = await verifier.verify_access_token(token)
    user = await auth_service.me(access_token=token)

    claim_sub = str(claims.get("sub", ""))
    if claim_sub and claim_sub != user.id:
        raise AppException(
            status_code=401,
            code="TOKEN_SUB_MISMATCH",
            message="Token subject mismatch.",
        )

    last_sign_in_at = user.last_sign_in_at.isoformat() if user.last_sign_in_at else None
    return AuthContext(
        user_id=user.id,
        access_token=token,
        email=user.email,
        last_sign_in_at=last_sign_in_at,
    )
