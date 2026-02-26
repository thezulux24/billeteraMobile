from typing import Any

import httpx

from app.core.config import Settings
from app.core.exceptions import AppException


class SupabaseAuthClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._base_url = str(settings.supabase_url).rstrip("/")
        self._timeout = settings.request_timeout_seconds

    def _headers(self, *, access_token: str | None = None) -> dict[str, str]:
        headers = {
            "apikey": self._settings.supabase_anon_key,
            "Content-Type": "application/json",
        }
        if access_token:
            headers["Authorization"] = f"Bearer {access_token}"
        return headers

    def _admin_headers(self) -> dict[str, str]:
        service_key = (self._settings.supabase_service_role_key or "").strip()
        if not service_key:
            raise AppException(
                status_code=500,
                code="SERVICE_ROLE_KEY_MISSING",
                message="SUPABASE_SERVICE_ROLE_KEY is required for admin auth operations.",
            )
        return {
            "apikey": service_key,
            "Authorization": f"Bearer {service_key}",
            "Content-Type": "application/json",
        }

    @property
    def has_service_role(self) -> bool:
        return bool((self._settings.supabase_service_role_key or "").strip())

    async def sign_up(self, *, email: str, password: str) -> dict[str, Any]:
        return await self._post(
            "/auth/v1/signup",
            {"email": email, "password": password},
        )

    async def sign_in(self, *, email: str, password: str) -> dict[str, Any]:
        return await self._post(
            "/auth/v1/token?grant_type=password",
            {"email": email, "password": password},
        )

    async def refresh(self, *, refresh_token: str) -> dict[str, Any]:
        return await self._post(
            "/auth/v1/token?grant_type=refresh_token",
            {"refresh_token": refresh_token},
        )

    async def sign_out(self, *, access_token: str) -> None:
        await self._post("/auth/v1/logout", {}, access_token=access_token)

    async def admin_create_user(
        self,
        *,
        email: str,
        password: str,
        email_confirm: bool = True,
    ) -> dict[str, Any]:
        return await self._post_admin(
            "/auth/v1/admin/users",
            {"email": email, "password": password, "email_confirm": email_confirm},
        )

    async def recover(self, *, email: str) -> None:
        await self._post("/auth/v1/recover", {"email": email})

    async def get_user(self, *, access_token: str) -> dict[str, Any]:
        return await self._get("/auth/v1/user", access_token=access_token)

    async def get_jwks(self) -> dict[str, Any]:
        return await self._get("/auth/v1/.well-known/jwks.json")

    async def _get(
        self,
        path: str,
        *,
        access_token: str | None = None,
    ) -> dict[str, Any]:
        url = f"{self._base_url}{path}"
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def _post(
        self,
        path: str,
        payload: dict[str, Any],
        *,
        access_token: str | None = None,
    ) -> dict[str, Any]:
        url = f"{self._base_url}{path}"
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(
                url,
                json=payload,
                headers=self._headers(access_token=access_token),
            )
        return self._unwrap_response(response)

    async def _post_admin(self, path: str, payload: dict[str, Any]) -> dict[str, Any]:
        url = f"{self._base_url}{path}"
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(
                url,
                json=payload,
                headers=self._admin_headers(),
            )
        return self._unwrap_response(response)

    @staticmethod
    def _unwrap_response(response: httpx.Response) -> dict[str, Any]:
        try:
            payload = response.json() if response.content else {}
        except ValueError:
            payload = {}

        if response.status_code >= 400:
            message = payload.get("msg") or payload.get("error_description") or payload.get(
                "message"
            ) or "Supabase request failed."
            code = (
                payload.get("error_code")
                or payload.get("code")
                or payload.get("error")
                or "SUPABASE_REQUEST_FAILED"
            )
            raise AppException(
                status_code=response.status_code,
                code=str(code),
                message=str(message),
                details=payload,
            )

        return payload
