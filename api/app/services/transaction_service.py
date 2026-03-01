from datetime import UTC, datetime
from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.transaction import (
    TransactionCreateRequest,
    TransactionResponse,
    TransactionUpdateRequest,
)

class TransactionService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

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
        try:
            rows = await self._rest_client.list_transactions(
                access_token=access_token,
                user_id=user_id,
                limit=limit,
                offset=offset,
                kind=kind,
                category_id=category_id,
                cash_wallet_id=cash_wallet_id,
                bank_account_id=bank_account_id,
                credit_card_id=credit_card_id,
                occurred_from=occurred_from,
                occurred_to=occurred_to,
            )
            return [TransactionResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_transaction(self, *, access_token: str, user_id: str, request: TransactionCreateRequest) -> TransactionResponse:
        payload = request.model_dump(exclude_none=True)
        payload["user_id"] = user_id
        occurred_at = payload.get("occurred_at")
        if occurred_at is None:
            payload["occurred_at"] = datetime.now(UTC).isoformat()
        else:
            payload["occurred_at"] = occurred_at.isoformat()

        try:
            row = await self._rest_client.create_transaction(access_token=access_token, payload=payload)
            return TransactionResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def update_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
        request: TransactionUpdateRequest,
    ) -> TransactionResponse:
        payload = request.model_dump(exclude_unset=True)
        if not payload:
            raise AppException(
                status_code=400,
                code="NO_TRANSACTION_FIELDS",
                message="At least one transaction field must be provided.",
            )

        if payload.get("occurred_at"):
            payload["occurred_at"] = payload["occurred_at"].isoformat()

        try:
            row = await self._rest_client.update_transaction(
                access_token=access_token,
                user_id=user_id,
                transaction_id=transaction_id,
                payload=payload,
            )
            return TransactionResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def delete_transaction(
        self,
        *,
        access_token: str,
        user_id: str,
        transaction_id: str,
    ) -> None:
        payload = {"deleted_at": datetime.now(UTC).isoformat()}
        try:
            await self._rest_client.update_transaction(
                access_token=access_token,
                user_id=user_id,
                transaction_id=transaction_id,
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
        if code == "42P01" and "transactions" in message:
            raise AppException(
                status_code=533,
                code="MIGRATIONS_NOT_APPLIED",
                message="Database migrations for transactions are not applied yet.",
            ) from exc
