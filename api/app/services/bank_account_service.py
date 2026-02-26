from datetime import UTC, datetime

from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.bank_account import (
    BankAccountCreateRequest,
    BankAccountResponse,
    BankAccountUpdateRequest,
)


class BankAccountService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

    async def list_accounts(
        self,
        *,
        access_token: str,
        user_id: str,
    ) -> list[BankAccountResponse]:
        try:
            rows = await self._rest_client.list_bank_accounts(
                access_token=access_token,
                user_id=user_id,
            )
            return [BankAccountResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_account(
        self,
        *,
        access_token: str,
        user_id: str,
        request: BankAccountCreateRequest,
    ) -> BankAccountResponse:
        payload = request.model_dump()
        payload["currency"] = payload["currency"].upper()
        payload["user_id"] = user_id

        try:
            row = await self._rest_client.create_bank_account(
                access_token=access_token,
                payload=payload,
            )
            return BankAccountResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def update_account(
        self,
        *,
        access_token: str,
        user_id: str,
        account_id: str,
        request: BankAccountUpdateRequest,
    ) -> BankAccountResponse:
        payload = request.model_dump(exclude_none=True)
        if not payload:
            raise AppException(
                status_code=400,
                code="NO_BANK_ACCOUNT_FIELDS",
                message="At least one bank account field must be provided.",
            )
        if "currency" in payload and payload["currency"] is not None:
            payload["currency"] = str(payload["currency"]).upper()

        try:
            row = await self._rest_client.update_bank_account(
                access_token=access_token,
                user_id=user_id,
                account_id=account_id,
                payload=payload,
            )
            return BankAccountResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def delete_account(
        self,
        *,
        access_token: str,
        user_id: str,
        account_id: str,
    ) -> None:
        payload = {"deleted_at": datetime.now(UTC).isoformat()}
        try:
            await self._rest_client.update_bank_account(
                access_token=access_token,
                user_id=user_id,
                account_id=account_id,
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
        if code == "42P01" or "relation" in message and "bank_accounts" in message:
            raise AppException(
                status_code=503,
                code="MIGRATIONS_NOT_APPLIED",
                message=(
                    "Database migrations are not applied yet. "
                    "Run `python scripts/apply_migrations.py` from the api folder."
                ),
            ) from exc
