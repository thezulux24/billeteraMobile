from datetime import datetime

import pytest

from app.core.exceptions import AppException
from app.schemas.transaction import TransactionCreateRequest, TransactionUpdateRequest
from app.services.transaction_service import TransactionService


class DummyRestClient:
    def __init__(self) -> None:
        self.last_payload: dict | None = None

    async def list_transactions(
        self,
        *,
        access_token: str,
        user_id: str,
        limit: int,
        offset: int,
        kind: str | None = None,
        category_id: str | None = None,
        cash_wallet_id: str | None = None,
        bank_account_id: str | None = None,
        credit_card_id: str | None = None,
        occurred_from: datetime | None = None,
        occurred_to: datetime | None = None,
    ) -> list[dict]:
        return [
            {
                "id": "tx-1",
                "kind": "income",
                "amount": 100.0,
                "currency": "USD",
                "description": "Salary",
                "occurred_at": "2026-01-01T00:00:00Z",
                "category_id": "cat-1",
                "cash_wallet_id": "wallet-1",
                "bank_account_id": None,
                "credit_card_id": None,
                "target_cash_wallet_id": None,
                "target_bank_account_id": None,
                "created_at": "2026-01-01T00:00:00Z",
                "updated_at": "2026-01-01T00:00:00Z",
            }
        ]

    async def create_transaction(self, *, access_token: str, payload: dict) -> dict:
        self.last_payload = payload
        return {
            "id": "tx-2",
            "kind": payload["kind"],
            "amount": payload["amount"],
            "currency": payload["currency"],
            "description": payload.get("description"),
            "occurred_at": payload.get("occurred_at", "2026-01-01T00:00:00Z"),
            "category_id": payload.get("category_id"),
            "cash_wallet_id": payload.get("cash_wallet_id"),
            "bank_account_id": payload.get("bank_account_id"),
            "credit_card_id": payload.get("credit_card_id"),
            "target_cash_wallet_id": payload.get("target_cash_wallet_id"),
            "target_bank_account_id": payload.get("target_bank_account_id"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        }

    async def update_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
        payload: dict,
    ) -> dict:
        self.last_payload = payload
        return {
            "id": transaction_id,
            "kind": payload.get("kind", "income"),
            "amount": payload.get("amount", 100.0),
            "currency": payload.get("currency", "USD"),
            "description": payload.get("description"),
            "occurred_at": payload.get("occurred_at", "2026-01-01T00:00:00Z"),
            "category_id": payload.get("category_id"),
            "cash_wallet_id": payload.get("cash_wallet_id"),
            "bank_account_id": payload.get("bank_account_id"),
            "credit_card_id": payload.get("credit_card_id"),
            "target_cash_wallet_id": payload.get("target_cash_wallet_id"),
            "target_bank_account_id": payload.get("target_bank_account_id"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
        }


class MissingTableRestClient:
    async def list_transactions(self, **_: object) -> list[dict]:
        raise AppException(
            status_code=400,
            code="SUPABASE_REST_ERROR",
            message="Supabase rest request failed.",
            details={
                "code": "42P01",
                "message": 'relation "public.transactions" does not exist',
            },
        )


@pytest.mark.asyncio
async def test_list_transactions() -> None:
    service = TransactionService(DummyRestClient())
    rows = await service.list_transactions(
        access_token="token",
        user_id="user-id",
        limit=50,
        offset=0,
    )
    assert len(rows) == 1
    assert rows[0].kind == "income"


@pytest.mark.asyncio
async def test_create_transaction_normalizes_currency() -> None:
    client = DummyRestClient()
    service = TransactionService(client)
    tx = await service.create_transaction(
        access_token="token",
        user_id="user-id",
        request=TransactionCreateRequest(
            kind="income",
            amount=125.5,
            currency="mxn",
            cash_wallet_id="11111111-1111-4111-8111-111111111111",
            category_id="22222222-2222-4222-8222-222222222222",
        ),
    )
    assert tx.currency == "MXN"
    assert client.last_payload is not None
    assert client.last_payload["currency"] == "MXN"


@pytest.mark.asyncio
async def test_update_transaction_requires_fields() -> None:
    service = TransactionService(DummyRestClient())
    with pytest.raises(AppException) as exc:
        await service.update_transaction(
            access_token="token",
            user_id="user-id",
            transaction_id="tx-1",
            request=TransactionUpdateRequest(),
        )
    assert exc.value.code == "NO_TRANSACTION_FIELDS"


@pytest.mark.asyncio
async def test_delete_transaction_uses_soft_delete() -> None:
    client = DummyRestClient()
    service = TransactionService(client)
    await service.delete_transaction(
        access_token="token",
        user_id="user-id",
        transaction_id="tx-1",
    )
    assert client.last_payload is not None
    assert "deleted_at" in client.last_payload


@pytest.mark.asyncio
async def test_list_transactions_raises_migrations_not_applied() -> None:
    service = TransactionService(MissingTableRestClient())
    with pytest.raises(AppException) as exc:
        await service.list_transactions(
            access_token="token",
            user_id="user-id",
            limit=50,
            offset=0,
        )
    assert exc.value.code == "MIGRATIONS_NOT_APPLIED"
