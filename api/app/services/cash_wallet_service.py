from datetime import UTC, datetime

from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.cash_wallet import (
    CashWalletCreateRequest,
    CashWalletResponse,
    CashWalletUpdateRequest,
)


class CashWalletService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

    async def list_wallets(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[CashWalletResponse]:
        try:
            rows = await self._rest_client.list_cash_wallets(
                access_token=access_token,
                user_id=user_id,
            )
            return [CashWalletResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_wallet(
        self,
        *,
        access_token: str,
        user_id: str,
        request: CashWalletCreateRequest,
    ) -> CashWalletResponse:
        payload = request.model_dump()
        payload["currency"] = payload["currency"].upper()
        payload["user_id"] = user_id

        try:
            row = await self._rest_client.create_cash_wallet(
                access_token=access_token,
                payload=payload,
            )
            return CashWalletResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def update_wallet(
        self,
        *,
        access_token: str,
        user_id: str,
        wallet_id: str,
        request: CashWalletUpdateRequest,
    ) -> CashWalletResponse:
        payload = request.model_dump(exclude_none=True)
        if not payload:
            raise AppException(
                status_code=400,
                code="NO_CASH_WALLET_FIELDS",
                message="At least one cash wallet field must be provided.",
            )
        if "currency" in payload and payload["currency"] is not None:
            payload["currency"] = str(payload["currency"]).upper()

        try:
            row = await self._rest_client.update_cash_wallet(
                access_token=access_token,
                user_id=user_id,
                wallet_id=wallet_id,
                payload=payload,
            )
            return CashWalletResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def delete_wallet(
        self,
        *,
        access_token: str,
        user_id: str,
        wallet_id: str,
    ) -> None:
        payload = {"deleted_at": datetime.now(UTC).isoformat()}
        try:
            await self._rest_client.update_cash_wallet(
                access_token=access_token,
                user_id=user_id,
                wallet_id=wallet_id,
                payload=payload,
            )
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    @staticmethod
    def _raise_if_migration_missing(exc: AppException) -> None:
        details = exc.details if isinstance(exc.details, dict) else {}
        code = str(details.get("code", "")).upper()
        message = str(details.get("message", "")).lower()
        if code == "42P01" or "relation" in message and "cash_wallets" in message:
            raise AppException(
                status_code=503,
                code="MIGRATIONS_NOT_APPLIED",
                message=(
                    "Database migrations are not applied yet. "
                    "Run `python scripts/apply_migrations.py` from the api folder."
                ),
            ) from exc
