from datetime import UTC, datetime

import pytest
from fastapi.testclient import TestClient

from app.core.exceptions import AppException
from app.dependencies.auth import AuthContext, get_auth_context, get_transaction_service
from app.main import create_app
from app.schemas.transaction import (
    TransactionCreateRequest,
    TransactionResponse,
    TransactionUpdateRequest,
)


def _build_transaction_response(
    *,
    tx_id: str,
    kind: str = "income",
    amount: float = 100.0,
    currency: str = "USD",
) -> TransactionResponse:
    now = datetime(2026, 1, 1, tzinfo=UTC)
    return TransactionResponse(
        id=tx_id,
        kind=kind,
        amount=amount,
        currency=currency,
        description="test",
        occurred_at=now,
        category_id="cat-1",
        cash_wallet_id="wallet-1",
        bank_account_id=None,
        credit_card_id=None,
        target_cash_wallet_id=None,
        target_bank_account_id=None,
        created_at=now,
        updated_at=now,
    )


class StubTransactionService:
    def __init__(self) -> None:
        self.list_calls: list[dict[str, object]] = []
        self.update_calls: list[dict[str, object]] = []
        self.delete_calls: list[dict[str, object]] = []

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
    ) -> list[TransactionResponse]:
        self.list_calls.append(
            {
                "access_token": access_token,
                "user_id": user_id,
                "limit": limit,
                "offset": offset,
                "kind": kind,
                "category_id": category_id,
                "cash_wallet_id": cash_wallet_id,
                "bank_account_id": bank_account_id,
                "credit_card_id": credit_card_id,
                "occurred_from": occurred_from,
                "occurred_to": occurred_to,
            },
        )
        return [_build_transaction_response(tx_id="tx-list", kind=kind or "income")]

    async def create_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        request: TransactionCreateRequest,
    ) -> TransactionResponse:
        return _build_transaction_response(
            tx_id="tx-create",
            kind=request.kind,
            amount=request.amount,
            currency=request.currency,
        )

    async def update_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
        request: TransactionUpdateRequest,
    ) -> TransactionResponse:
        self.update_calls.append(
            {
                "access_token": access_token,
                "user_id": user_id,
                "transaction_id": transaction_id,
                "request": request,
            },
        )

        if transaction_id == "tx-error":
            raise AppException(
                status_code=400,
                code="NO_TRANSACTION_FIELDS",
                message="At least one transaction field must be provided.",
            )

        return _build_transaction_response(
            tx_id=transaction_id,
            kind=request.kind or "income",
            amount=request.amount or 100.0,
            currency=request.currency or "USD",
        )

    async def delete_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
    ) -> None:
        self.delete_calls.append(
            {
                "access_token": access_token,
                "user_id": user_id,
                "transaction_id": transaction_id,
            },
        )


@pytest.fixture
def api_client() -> tuple[TestClient, StubTransactionService]:
    app = create_app()
    service = StubTransactionService()

    async def override_auth_context() -> AuthContext:
        return AuthContext(
            user_id="user-123",
            access_token="token-abc",
            email="user@example.com",
        )

    def override_transaction_service() -> StubTransactionService:
        return service

    app.dependency_overrides[get_auth_context] = override_auth_context
    app.dependency_overrides[get_transaction_service] = override_transaction_service

    with TestClient(app) as client:
        yield client, service

    app.dependency_overrides.clear()


def test_list_transactions_accepts_filters(api_client: tuple[TestClient, StubTransactionService]) -> None:
    client, service = api_client

    response = client.get(
        "/api/v1/transactions",
        params={
            "limit": 25,
            "offset": 10,
            "kind": "expense",
            "category_id": "cat-2",
            "cash_wallet_id": "wallet-9",
            "bank_account_id": "bank-9",
            "credit_card_id": "card-9",
            "occurred_from": "2026-01-01T00:00:00Z",
            "occurred_to": "2026-01-31T23:59:59Z",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body) == 1
    assert body[0]["id"] == "tx-list"

    assert len(service.list_calls) == 1
    call = service.list_calls[0]
    assert call["access_token"] == "token-abc"
    assert call["user_id"] == "user-123"
    assert call["limit"] == 25
    assert call["offset"] == 10
    assert call["kind"] == "expense"
    assert call["category_id"] == "cat-2"
    assert call["cash_wallet_id"] == "wallet-9"
    assert call["bank_account_id"] == "bank-9"
    assert call["credit_card_id"] == "card-9"
    assert call["occurred_from"] == datetime(2026, 1, 1, tzinfo=UTC)
    assert call["occurred_to"] == datetime(2026, 1, 31, 23, 59, 59, tzinfo=UTC)


def test_patch_transaction_forwards_request(api_client: tuple[TestClient, StubTransactionService]) -> None:
    client, service = api_client

    response = client.patch(
        "/api/v1/transactions/tx-42",
        json={
            "kind": "expense",
            "amount": 55.5,
            "currency": "mxn",
            "cash_wallet_id": "11111111-1111-4111-8111-111111111111",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["id"] == "tx-42"
    assert body["kind"] == "expense"
    assert body["amount"] == 55.5
    assert body["currency"] == "MXN"

    assert len(service.update_calls) == 1
    update_call = service.update_calls[0]
    assert update_call["transaction_id"] == "tx-42"
    request = update_call["request"]
    assert isinstance(request, TransactionUpdateRequest)
    assert request.kind == "expense"
    assert request.amount == 55.5
    assert request.currency == "MXN"
    assert request.cash_wallet_id == "11111111-1111-4111-8111-111111111111"


def test_patch_transaction_propagates_service_error(
    api_client: tuple[TestClient, StubTransactionService],
) -> None:
    client, _ = api_client

    response = client.patch("/api/v1/transactions/tx-error", json={})

    assert response.status_code == 400
    body = response.json()
    assert body["code"] == "NO_TRANSACTION_FIELDS"


def test_delete_transaction_returns_success(
    api_client: tuple[TestClient, StubTransactionService],
) -> None:
    client, service = api_client

    response = client.delete("/api/v1/transactions/tx-77")

    assert response.status_code == 200
    assert response.json() == {"success": True}
    assert len(service.delete_calls) == 1
    assert service.delete_calls[0]["transaction_id"] == "tx-77"


def test_create_transaction_invalid_shape_returns_validation_error(
    api_client: tuple[TestClient, StubTransactionService],
) -> None:
    client, _ = api_client

    response = client.post(
        "/api/v1/transactions",
        json={
            "kind": "income",
            "amount": 100,
            "currency": "USD",
        },
    )

    assert response.status_code == 422
    body = response.json()
    assert body["code"] == "VALIDATION_ERROR"


def test_create_transaction_invalid_category_uuid_returns_validation_error(
    api_client: tuple[TestClient, StubTransactionService],
) -> None:
    client, _ = api_client

    response = client.post(
        "/api/v1/transactions",
        json={
            "kind": "expense",
            "amount": 100,
            "currency": "USD",
            "cash_wallet_id": "11111111-1111-4111-8111-111111111111",
            "category_id": "exp_food",
        },
    )

    assert response.status_code == 422
    body = response.json()
    assert body["code"] == "VALIDATION_ERROR"
