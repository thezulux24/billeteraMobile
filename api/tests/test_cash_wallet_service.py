import pytest

from app.core.exceptions import AppException
from app.schemas.cash_wallet import CashWalletCreateRequest, CashWalletUpdateRequest
from app.services.cash_wallet_service import CashWalletService


class DummyRestClient:
    async def list_cash_wallets(self, *, access_token: str, user_id: str) -> list[dict]:
        return [
            {
                "id": "wallet-1",
                "name": "Efectivo",
                "balance": 100.5,
                "currency": "USD",
                "created_at": "2026-01-01T00:00:00Z",
                "updated_at": "2026-01-01T00:00:00Z",
            }
        ]

    async def create_cash_wallet(self, *, access_token: str, payload: dict) -> dict:
        return {
            "id": "wallet-2",
            "name": payload["name"],
            "balance": payload.get("balance", 0),
            "currency": payload.get("currency", "USD"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        }

    async def update_cash_wallet(
        self,
        *,
        access_token: str,
        user_id: str,
        wallet_id: str,
        payload: dict,
    ) -> dict:
        return {
            "id": wallet_id,
            "name": payload.get("name", "Efectivo"),
            "balance": payload.get("balance", 100),
            "currency": payload.get("currency", "USD"),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
        }


class MissingTableRestClient:
    async def list_cash_wallets(self, *, access_token: str, user_id: str) -> list[dict]:
        raise AppException(
            status_code=400,
            code="SUPABASE_REST_ERROR",
            message="Supabase rest request failed.",
            details={
                "code": "42P01",
                "message": 'relation "public.cash_wallets" does not exist',
            },
        )


@pytest.mark.asyncio
async def test_list_wallets() -> None:
    service = CashWalletService(DummyRestClient())
    wallets = await service.list_wallets(access_token="token", user_id="user-id")
    assert len(wallets) == 1
    assert wallets[0].name == "Efectivo"


@pytest.mark.asyncio
async def test_create_wallet_normalizes_currency() -> None:
    service = CashWalletService(DummyRestClient())
    wallet = await service.create_wallet(
        access_token="token",
        user_id="user-id",
        request=CashWalletCreateRequest(name="Caja", currency="mxn", balance=15),
    )
    assert wallet.currency == "MXN"


@pytest.mark.asyncio
async def test_update_wallet_requires_fields() -> None:
    service = CashWalletService(DummyRestClient())
    with pytest.raises(AppException) as exc:
        await service.update_wallet(
            access_token="token",
            user_id="user-id",
            wallet_id="wallet-id",
            request=CashWalletUpdateRequest(),
        )
    assert exc.value.code == "NO_CASH_WALLET_FIELDS"


@pytest.mark.asyncio
async def test_delete_wallet_uses_soft_delete() -> None:
    class CaptureRestClient(DummyRestClient):
        def __init__(self) -> None:
            self.payload: dict | None = None

        async def update_cash_wallet(
            self,
            *,
            access_token: str,
            user_id: str,
            wallet_id: str,
            payload: dict,
        ) -> dict:
            self.payload = payload
            return await super().update_cash_wallet(
                access_token=access_token,
                user_id=user_id,
                wallet_id=wallet_id,
                payload=payload,
            )

    client = CaptureRestClient()
    service = CashWalletService(client)
    await service.delete_wallet(
        access_token="token",
        user_id="user-id",
        wallet_id="wallet-id",
    )
    assert client.payload is not None
    assert "deleted_at" in client.payload


@pytest.mark.asyncio
async def test_list_wallets_raises_migrations_not_applied() -> None:
    service = CashWalletService(MissingTableRestClient())
    with pytest.raises(AppException) as exc:
        await service.list_wallets(access_token="token", user_id="user-id")
    assert exc.value.code == "MIGRATIONS_NOT_APPLIED"
