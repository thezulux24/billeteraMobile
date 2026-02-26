import pytest

from app.core.exceptions import AppException
from app.schemas.bank_account import BankAccountCreateRequest, BankAccountUpdateRequest
from app.services.bank_account_service import BankAccountService


class DummyRestClient:
    async def list_bank_accounts(self, *, access_token: str, user_id: str) -> list[dict]:
        return [
            {
                "id": "account-1",
                "name": "Cuenta principal",
                "bank_name": "BBVA",
                "balance": 2500.5,
                "currency": "USD",
                "created_at": "2026-01-01T00:00:00Z",
                "updated_at": "2026-01-01T00:00:00Z",
            }
        ]

    async def create_bank_account(self, *, access_token: str, payload: dict) -> dict:
        return {
            "id": "account-2",
            "name": payload["name"],
            "bank_name": payload.get("bank_name"),
            "balance": payload.get("balance", 0),
            "currency": payload.get("currency", "USD"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        }

    async def update_bank_account(
        self,
        *,
        access_token: str,
        user_id: str,
        account_id: str,
        payload: dict,
    ) -> dict:
        return {
            "id": account_id,
            "name": payload.get("name", "Cuenta principal"),
            "bank_name": payload.get("bank_name", "BBVA"),
            "balance": payload.get("balance", 2500),
            "currency": payload.get("currency", "USD"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
        }


class MissingTableRestClient:
    async def list_bank_accounts(self, *, access_token: str, user_id: str) -> list[dict]:
        raise AppException(
            status_code=400,
            code="SUPABASE_REST_ERROR",
            message="Supabase rest request failed.",
            details={
                "code": "42P01",
                "message": 'relation "public.bank_accounts" does not exist',
            },
        )


@pytest.mark.asyncio
async def test_list_accounts() -> None:
    service = BankAccountService(DummyRestClient())
    accounts = await service.list_accounts(access_token="token", user_id="user-id")
    assert len(accounts) == 1
    assert accounts[0].name == "Cuenta principal"


@pytest.mark.asyncio
async def test_create_account_normalizes_currency() -> None:
    service = BankAccountService(DummyRestClient())
    account = await service.create_account(
        access_token="token",
        user_id="user-id",
        request=BankAccountCreateRequest(
            name="Cuenta USD",
            bank_name="Santander",
            currency="mxn",
            balance=500,
        ),
    )
    assert account.currency == "MXN"
    assert account.bank_name == "Santander"


@pytest.mark.asyncio
async def test_update_account_requires_fields() -> None:
    service = BankAccountService(DummyRestClient())
    with pytest.raises(AppException) as exc:
        await service.update_account(
            access_token="token",
            user_id="user-id",
            account_id="account-id",
            request=BankAccountUpdateRequest(),
        )
    assert exc.value.code == "NO_BANK_ACCOUNT_FIELDS"


@pytest.mark.asyncio
async def test_delete_account_uses_soft_delete() -> None:
    class CaptureRestClient(DummyRestClient):
        def __init__(self) -> None:
            self.payload: dict | None = None

        async def update_bank_account(
            self,
            *,
            access_token: str,
            user_id: str,
            account_id: str,
            payload: dict,
        ) -> dict:
            self.payload = payload
            return await super().update_bank_account(
                access_token=access_token,
                user_id=user_id,
                account_id=account_id,
                payload=payload,
            )

    client = CaptureRestClient()
    service = BankAccountService(client)
    await service.delete_account(
        access_token="token",
        user_id="user-id",
        account_id="account-id",
    )
    assert client.payload is not None
    assert "deleted_at" in client.payload


@pytest.mark.asyncio
async def test_list_accounts_raises_migrations_not_applied() -> None:
    service = BankAccountService(MissingTableRestClient())
    with pytest.raises(AppException) as exc:
        await service.list_accounts(access_token="token", user_id="user-id")
    assert exc.value.code == "MIGRATIONS_NOT_APPLIED"
