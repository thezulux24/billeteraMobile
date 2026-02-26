from typing import Any

from app.clients.supabase_auth import SupabaseAuthClient
from app.core.exceptions import AppException
from app.schemas.auth import AuthSessionResponse, AuthUser, MeResponse


def build_session_response(payload: dict[str, Any]) -> AuthSessionResponse:
    session = payload.get("session")
    if not isinstance(session, dict):
        session = {}

    access_token = payload.get("access_token") or session.get("access_token")
    refresh_token = payload.get("refresh_token") or session.get("refresh_token")
    expires_in = payload.get("expires_in") or session.get("expires_in")
    token_type = payload.get("token_type") or session.get("token_type")
    user = payload.get("user") or session.get("user") or {}

    if not access_token or not refresh_token:
        if user.get("id") and user.get("email"):
            raise AppException(
                status_code=409,
                code="EMAIL_CONFIRMATION_REQUIRED",
                message=(
                    "Cuenta creada, pero requiere confirmacion de correo. "
                    "Confirma tu email e inicia sesion."
                ),
                details=payload,
            )
        raise AppException(
            status_code=400,
            code="AUTH_SESSION_NOT_AVAILABLE",
            message="Supabase did not return an active session.",
            details=payload,
        )

    if not user.get("id") or not user.get("email"):
        raise AppException(
            status_code=502,
            code="INVALID_AUTH_USER",
            message="Supabase did not return a valid user.",
            details=payload,
        )

    return AuthSessionResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=int(expires_in or 0),
        token_type=str(token_type or "bearer"),
        user=AuthUser(id=str(user["id"]), email=str(user["email"])),
    )


class AuthService:
    def __init__(self, auth_client: SupabaseAuthClient) -> None:
        self._auth_client = auth_client

    async def sign_up(self, *, email: str, password: str) -> AuthSessionResponse:
        if self._auth_client.has_service_role:
            try:
                await self._auth_client.admin_create_user(
                    email=email,
                    password=password,
                    email_confirm=True,
                )
            except AppException as error:
                if error.code == "email_exists":
                    raise AppException(
                        status_code=409,
                        code="EMAIL_ALREADY_REGISTERED",
                        message="Ese correo ya esta registrado. Inicia sesion.",
                        details=error.details,
                    ) from error
                raise
            return await self.sign_in(email=email, password=password)

        payload = await self._auth_client.sign_up(email=email, password=password)
        try:
            return build_session_response(payload)
        except AppException as error:
            if error.code in {
                "AUTH_SESSION_NOT_AVAILABLE",
                "EMAIL_CONFIRMATION_REQUIRED",
            }:
                return await self.sign_in(email=email, password=password)
            raise

    async def sign_in(self, *, email: str, password: str) -> AuthSessionResponse:
        payload = await self._auth_client.sign_in(email=email, password=password)
        return build_session_response(payload)

    async def refresh(self, *, refresh_token: str) -> AuthSessionResponse:
        payload = await self._auth_client.refresh(refresh_token=refresh_token)
        return build_session_response(payload)

    async def sign_out(self, *, access_token: str) -> None:
        await self._auth_client.sign_out(access_token=access_token)

    async def reset_password(self, *, email: str) -> None:
        await self._auth_client.recover(email=email)

    async def me(self, *, access_token: str) -> MeResponse:
        user_payload = await self._auth_client.get_user(access_token=access_token)
        user_id = user_payload.get("id")
        email = user_payload.get("email")
        if not user_id or not email:
            raise AppException(
                status_code=502,
                code="INVALID_AUTH_USER",
                message="Supabase user payload is invalid.",
                details=user_payload,
            )
        return MeResponse(
            id=str(user_id),
            email=str(email),
            last_sign_in_at=user_payload.get("last_sign_in_at"),
        )
