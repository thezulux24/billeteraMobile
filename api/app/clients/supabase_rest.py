from datetime import datetime
from typing import Any
from urllib.parse import quote

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

    async def list_bank_accounts(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[dict[str, Any]]:
        url = (
            f"{self._base_url}/rest/v1/bank_accounts"
            f"?select=id,name,bank_name,balance,currency,created_at,updated_at"
            f"&user_id=eq.{user_id}&deleted_at=is.null"
            "&order=created_at.desc"
        )
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def create_bank_account(
        self,
        *,
        access_token: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/bank_accounts"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=500,
                code="BANK_ACCOUNT_CREATE_FAILED",
                message="Bank account could not be created.",
            )
        return data[0]

    async def update_bank_account(
        self,
        *,
        access_token: str,
        user_id: str,
        account_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/bank_accounts"
            f"?id=eq.{account_id}&user_id=eq.{user_id}&deleted_at=is.null"
        )
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="BANK_ACCOUNT_NOT_FOUND",
                message="Bank account not found.",
            )
        return data[0]

    async def list_credit_cards(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[dict[str, Any]]:
        url = (
            f"{self._base_url}/rest/v1/credit_cards"
            f"?select=id,name,issuer,last_four,card_provider,tier,credit_limit,current_debt,statement_day,due_day,currency,created_at,updated_at"
            f"&user_id=eq.{user_id}&deleted_at=is.null"
            "&order=created_at.desc"
        )
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def create_credit_card(
        self,
        *,
        access_token: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/credit_cards"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=500,
                code="CREDIT_CARD_CREATE_FAILED",
                message="Credit card could not be created.",
            )
        return data[0]

    async def update_credit_card(
        self,
        *,
        access_token: str,
        user_id: str,
        card_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/credit_cards"
            f"?id=eq.{card_id}&user_id=eq.{user_id}&deleted_at=is.null"
        )
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="CREDIT_CARD_NOT_FOUND",
                message="Credit card not found.",
            )
        return data[0]

    async def list_categories(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[dict[str, Any]]:
        # Categories are user-scoped. System defaults are seeded per user.
        url = (
            f"{self._base_url}/rest/v1/categories"
            f"?select=id,name,kind,color,icon,is_system,created_at,updated_at"
            f"&user_id=eq.{quote(user_id, safe='')}&deleted_at=is.null"
            "&order=name.asc"
        )
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def create_category(
        self,
        *,
        access_token: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/categories"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=500,
                code="CATEGORY_CREATE_FAILED",
                message="Category could not be created.",
            )
        return data[0]

    async def update_category(
        self,
        *,
        access_token: str,
        user_id: str,
        category_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/categories"
            f"?id=eq.{category_id}&user_id=eq.{user_id}&deleted_at=is.null"
        )
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="CATEGORY_NOT_FOUND",
                message="Category not found.",
            )
        return data[0]

    async def list_transactions(
        self,
        *,
        access_token: str,
        user_id: str,
        limit: int = 50,
        offset: int = 0,
        kind: str | None = None,
        category_id: str | None = None,
        cash_wallet_id: str | None = None,
        bank_account_id: str | None = None,
        credit_card_id: str | None = None,
        occurred_from: datetime | None = None,
        occurred_to: datetime | None = None,
    ) -> list[dict[str, Any]]:
        select = (
            "id,kind,amount,currency,description,occurred_at,category_id,"
            "cash_wallet_id,bank_account_id,credit_card_id,target_cash_wallet_id,"
            "target_bank_account_id,created_at,updated_at"
        )
        query_parts = [
            f"select={select}",
            f"user_id=eq.{quote(user_id, safe='')}",
            "deleted_at=is.null",
            "order=occurred_at.desc",
            f"limit={limit}",
            f"offset={offset}",
        ]

        if kind is not None:
            query_parts.append(f"kind=eq.{quote(kind, safe='')}")
        if category_id is not None:
            query_parts.append(f"category_id=eq.{quote(category_id, safe='')}")
        if cash_wallet_id is not None:
            query_parts.append(f"cash_wallet_id=eq.{quote(cash_wallet_id, safe='')}")
        if bank_account_id is not None:
            query_parts.append(f"bank_account_id=eq.{quote(bank_account_id, safe='')}")
        if credit_card_id is not None:
            query_parts.append(f"credit_card_id=eq.{quote(credit_card_id, safe='')}")
        if occurred_from is not None:
            query_parts.append(
                f"occurred_at=gte.{quote(occurred_from.isoformat(), safe='')}",
            )
        if occurred_to is not None:
            query_parts.append(
                f"occurred_at=lte.{quote(occurred_to.isoformat(), safe='')}",
            )

        url = f"{self._base_url}/rest/v1/transactions?{'&'.join(query_parts)}"
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.get(url, headers=self._headers(access_token=access_token))
        return self._unwrap_response(response)

    async def create_transaction(
        self,
        *,
        access_token: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = f"{self._base_url}/rest/v1/transactions"
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.post(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=500,
                code="TRANSACTION_CREATE_FAILED",
                message="Transaction could not be created.",
            )
        return data[0]

    async def update_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        url = (
            f"{self._base_url}/rest/v1/transactions"
            f"?id=eq.{transaction_id}&user_id=eq.{user_id}&deleted_at=is.null"
        )
        headers = self._headers(access_token=access_token)
        headers["Prefer"] = "return=representation"

        async with httpx.AsyncClient(timeout=self._timeout) as client:
            response = await client.patch(url, json=payload, headers=headers)
        data = self._unwrap_response(response)
        if not data:
            raise AppException(
                status_code=404,
                code="TRANSACTION_NOT_FOUND",
                message="Transaction not found.",
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
