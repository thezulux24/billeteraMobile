from typing import Any

import httpx

from app.core.config import Settings
from app.core.exceptions import AppException


class SupabaseRestClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._base_url = str(settings.supabase_url).rstrip("/")
        self._timeout = settings.request_timeout_seconds

    def _headers(self, *, access_token: str) -> dict[str, str]:
        return {
            "apikey": self._settings.supabase_anon_key,
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        }

    async def fetch_profile(self, *, access_token: str, user_id: str) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/profiles"
            f"?select=id,base_currency,ai_enabled,created_at,updated_at"
            f"&id=eq.{user_id}&deleted_at=is.null"
        )
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="PROFILE_NOT_FOUND",
                message="Profile not found.",
            )
        return data[0]

    async def update_profile(
        self,
        *,
        access_token: str,
        user_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/profiles?id=eq.{user_id}&deleted_at=is.null"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="PROFILE_NOT_FOUND",
                message="Profile not found.",
            )
        return data[0]

    async def list_cash_wallets(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[dict[str, Any]]:
        url = (
            f"{self._base_url}/rest/v1/cash_wallets"
            f"?select=id,name,balance,currency,created_at,updated_at"
            f"&user_id=eq.{user_id}&deleted_at=is.null"
            "&order=created_at.desc"
        )
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def create_cash_wallet(
        self,
        *,
        access_token: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/cash_wallets"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=500,
                code="CASH_WALLET_CREATE_FAILED",
                message="Cash wallet could not be created.",
            )
        return data[0]

    async def update_cash_wallet(
        self,
        *,
        access_token: str,
        user_id: str,
        wallet_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/cash_wallets"
            f"?id=eq.{wallet_id}&user_id=eq.{user_id}&deleted_at=is.null"
        )
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="CASH_WALLET_NOT_FOUND",
                message="Cash wallet not found.",
            )
        return data[0]

    @staticmethod
    def _unwrap_response(response: httpx.Response) -> list[dict[str, Any]]:
        try:
            payload = response.json() if response.content else []
        except ValueError:
            payload = []

        if response.status_code >= 400:
            message = payload.get("message") if isinstance(payload, dict) else None
            raise AppException(
                status_code=response.status_code,
                code="SUPABASE_REST_ERROR",
                message=message or "Supabase rest request failed.",
                details=payload,
            )

        if not isinstance(payload, list):
            raise AppException(
                status_code=500,
                code="INVALID_SUPABASE_RESPONSE",
                message="Supabase rest returned invalid payload.",
                details=payload,
            )
        return payload
