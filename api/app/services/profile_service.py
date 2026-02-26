from app.clients.supabase_rest import SupabaseRestClient
from app.core.exceptions import AppException
from app.schemas.profile import ProfileResponse, ProfileUpdateRequest


class ProfileService:
    def __init__(self, rest_client: SupabaseRestClient) -> None:
        self._rest_client = rest_client

    async def get_profile(self, *, access_token: str, user_id: str) -> ProfileResponse:
        try:
            payload = await self._rest_client.fetch_profile(
                access_token=access_token,
                user_id=user_id,
            )
            return ProfileResponse.model_validate(payload)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    async def update_profile(
        self,
        *,
        access_token: str,
        user_id: str,
        update: ProfileUpdateRequest,
    ) -> ProfileResponse:
        data = update.model_dump(exclude_none=True)
        if not data:
            raise AppException(
                status_code=400,
                code="NO_PROFILE_FIELDS",
                message="At least one profile field must be provided.",
            )

        if "base_currency" in data and data["base_currency"] is not None:
            data["base_currency"] = str(data["base_currency"]).upper()

        try:
            payload = await self._rest_client.update_profile(
                access_token=access_token,
                user_id=user_id,
                payload=data,
            )
            return ProfileResponse.model_validate(payload)
        except AppException as exc:
            self._raise_if_migration_missing(exc)
            raise

    @staticmethod
    def _raise_if_migration_missing(exc: AppException) -> None:
        details = exc.details if isinstance(exc.details, dict) else {}
        code = str(details.get("code", "")).upper()
        message = str(details.get("message", "")).lower()
        if code == "42P01" or "relation" in message and "profiles" in message:
            raise AppException(
                status_code=503,
                code="MIGRATIONS_NOT_APPLIED",
                message=(
                    "Database migrations are not applied yet. "
                    "Run `python scripts/apply_migrations.py` from the api folder."
                ),
            ) from exc
