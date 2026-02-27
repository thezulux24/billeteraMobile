from datetime import UTC, datetime
from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.category import (
    CategoryCreateRequest,
    CategoryResponse,
    CategoryUpdateRequest,
)

class CategoryService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

    async def list_categories(self, *, access_token: str, user_id: str) -> list[CategoryResponse]:
        try:
            rows = await self._rest_client.list_categories(access_token=access_token, user_id=user_id)
            return [CategoryResponse.model_validate(row) for row in rows]
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def create_category(self, *, access_token: str, user_id: str, request: CategoryCreateRequest) -> CategoryResponse:
        payload = request.model_dump()
        payload["user_id"] = user_id
        try:
            row = await self._rest_client.create_category(access_token=access_token, payload=payload)
            return CategoryResponse.model_validate(row)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def delete_category(self, *, access_token: str, user_id: str, category_id: str) -> None:
        payload = {"deleted_at": datetime.now(UTC).isoformat()}
        try:
            await self._rest_client.update_category(access_token=access_token, user_id=user_id, category_id=category_id, payload=payload)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    @staticmethod
    def _raise_if_migration_missing(exc: AppException) -> None:
        details = exc.details if isinstance(exc.details, dict) else {}
        code = str(details.get("code", "")).upper()
        message = str(details.get("message", "")).lower()
        if code == "42P01" or ("relation" in message and "categories" in message):
            raise AppException(
                status_code=533,
                code="MIGRATIONS_NOT_APPLIED",
                message="Database migrations for categories are not applied yet.",
            ) from exc
