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

    async def list_transactions(self, *, access_token: str, user_id: str, limit: int = 50, offset: int = 0) -> list[TransactionResponse]:
        try:
            rows = await self._rest_client.list_transactions(access_token=access_token, user_id=user_id, limit=limit, offset=offset)
            return [TransactionResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_transaction(self, *, access_token: str, user_id: str, request: TransactionCreateRequest) -> TransactionResponse:
        payload = request.model_dump()
        payload["user_id"] = user_id
        if payload.get("occurred_at"):
            payload["occurred_at"] = payload["occurred_at"].isoformat()

        try:
            row = await self._rest_client.create_transaction(access_token=access_token, payload=payload)
            return TransactionResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    @staticmethod
    def _raise_if_migration_missing(exc: AppException) -> None:
        details = exc.details if isinstance(exc.details, dict) else {}
        code = str(details.get("code", "")).upper()
        message = str(details.get("message", "")).lower()
        if code == "42P01" or ("relation" in message and "transactions" in message):
            raise AppException(
                status_code=533,
                code="MIGRATIONS_NOT_APPLIED",
                message="Database migrations for transactions are not applied yet.",
            ) from exc
