from datetime import UTC, datetime
from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.credit_card import (
    CreditCardCreateRequest,
    CreditCardResponse,
    CreditCardUpdateRequest,
)

class CreditCardService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

    async def list_cards(self, *, access_token: str, user_id: str) -> list[CreditCardResponse]:
        try:
            rows = await self._rest_client.list_credit_cards(access_token=access_token, user_id=user_id)
            return [CreditCardResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_card(self, *, access_token: str, user_id: str, request: CreditCardCreateRequest) -> CreditCardResponse:
        payload = request.model_dump()
        payload["user_id"] = user_id
        try:
            row = await self._rest_client.create_credit_card(access_token=access_token, payload=payload)
            return CreditCardResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def update_card(self, *, access_token: str, user_id: str, card_id: str, request: CreditCardUpdateRequest) -> CreditCardResponse:
        payload = request.model_dump(exclude_none=True)
        try:
            row = await self._rest_client.update_credit_card(access_token=access_token, user_id=user_id, card_id=card_id, payload=payload)
            return CreditCardResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def delete_card(self, *, access_token: str, user_id: str, card_id: str) -> None:
        payload = {"deleted_at": datetime.now(UTC).isoformat()}
        try:
            await self._rest_client.update_credit_card(access_token=access_token, user_id=user_id, card_id=card_id, payload=payload)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    @staticmethod
    def _raise_if_migration_missing(exc: AppException) -> None:
        details = exc.details if isinstance(exc.details, dict) else {}
        code = str(details.get("code", "")).upper()
        message = str(details.get("message", "")).lower()
        if code == "42P01" or ("relation" in message and "credit_cards" in message):
            raise AppException(
                status_code=533,
                code="MIGRATIONS_NOT_APPLIED",
                message="Database migrations for credit cards are not applied yet.",
            ) from exc
