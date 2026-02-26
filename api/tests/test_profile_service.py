import pytest

from app.core.exceptions import AppException
from app.schemas.profile import ProfileUpdateRequest
from app.services.profile_service import ProfileService


class DummyRestClient:
    async def fetch_profile(self, *, access_token: str, user_id: str) -> dict:
        return {
            "id": user_id,
            "base_currency": "USD",
            "ai_enabled": True,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        }

    async def update_profile(self, *, access_token: str, user_id: str, payload: dict) -> dict:
        return {
            "id": user_id,
            "base_currency": payload.get("base_currency", "USD"),
            "ai_enabled": payload.get("ai_enabled", True),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
        }


class MissingTableRestClient:
    async def fetch_profile(self, *, access_token: str, user_id: str) -> dict:
        raise AppException(
            status_code=400,
            code="SUPABASE_REST_ERROR",
            message="Supabase rest request failed.",
            details={
                "code": "42P01",
                "message": 'relation "public.profiles" does not exist',
            },
        )


@pytest.mark.asyncio
async def test_get_profile() -> None:
    service = ProfileService(DummyRestClient())
    profile = await service.get_profile(access_token="token", user_id="user-id")
    assert profile.id == "user-id"
    assert profile.base_currency == "USD"


@pytest.mark.asyncio
async def test_update_profile_requires_fields() -> None:
    service = ProfileService(DummyRestClient())
    with pytest.raises(AppException) as exc:
        await service.update_profile(
            access_token="token",
            user_id="user-id",
            update=ProfileUpdateRequest(),
        )
    assert exc.value.code == "NO_PROFILE_FIELDS"


@pytest.mark.asyncio
async def test_update_profile_normalizes_currency() -> None:
    service = ProfileService(DummyRestClient())
    profile = await service.update_profile(
        access_token="token",
        user_id="user-id",
        update=ProfileUpdateRequest(base_currency="mxn"),
    )
    assert profile.base_currency == "MXN"


@pytest.mark.asyncio
async def test_get_profile_raises_migrations_not_applied() -> None:
    service = ProfileService(MissingTableRestClient())
    with pytest.raises(AppException) as exc:
        await service.get_profile(access_token="token", user_id="user-id")
    assert exc.value.code == "MIGRATIONS_NOT_APPLIED"
