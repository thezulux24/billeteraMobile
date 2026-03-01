import pytest

from app.core.exceptions import AppException
from app.schemas.category import CategoryCreateRequest
from app.services.category_service import CategoryService


class DummyRestClient:
    def __init__(self) -> None:
        self.last_payload: dict | None = None

    async def list_categories(self, *, access_token: str, user_id: str) -> list[dict]:
        return [
            {
                "id": "11111111-1111-4111-8111-111111111111",
                "name": "Salary",
                "kind": "income",
                "color": "#4ade80",
                "icon": "payments",
                "is_system": True,
                "created_at": "2026-01-01T00:00:00Z",
                "updated_at": "2026-01-01T00:00:00Z",
            }
        ]

    async def create_category(self, *, access_token: str, payload: dict) -> dict:
        self.last_payload = payload
        return {
            "id": "22222222-2222-4222-8222-222222222222",
            "name": payload["name"],
            "kind": payload["kind"],
            "color": payload.get("color"),
            "icon": payload.get("icon"),
            "is_system": payload.get("is_system", False),
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-01T00:00:00Z",
        }

    async def update_category(
        self,
        *,
        access_token: str,
        user_id: str,
        category_id: str,
        payload: dict,
    ) -> dict:
        self.last_payload = payload
        return {
            "id": category_id,
            "name": "Deleted",
            "kind": "expense",
            "color": None,
            "icon": None,
            "is_system": False,
            "created_at": "2026-01-01T00:00:00Z",
            "updated_at": "2026-01-02T00:00:00Z",
        }


class MissingTableRestClient:
    async def list_categories(self, *, access_token: str, user_id: str) -> list[dict]:
        raise AppException(
            status_code=400,
            code="SUPABASE_REST_ERROR",
            message="Supabase rest request failed.",
            details={
                "code": "42P01",
                "message": 'relation "public.categories" does not exist',
            },
        )


@pytest.mark.asyncio
async def test_list_categories() -> None:
    service = CategoryService(DummyRestClient())
    categories = await service.list_categories(access_token="token", user_id="user-id")
    assert len(categories) == 1
    assert categories[0].name == "Salary"


@pytest.mark.asyncio
async def test_create_category_forces_is_system_false() -> None:
    client = DummyRestClient()
    service = CategoryService(client)

    category = await service.create_category(
        access_token="token",
        user_id="user-id",
        request=CategoryCreateRequest(
            name="My custom",
            kind="expense",
            is_system=True,
        ),
    )

    assert category.is_system is False
    assert client.last_payload is not None
    assert client.last_payload["is_system"] is False


@pytest.mark.asyncio
async def test_delete_category_uses_soft_delete() -> None:
    client = DummyRestClient()
    service = CategoryService(client)

    await service.delete_category(
        access_token="token",
        user_id="user-id",
        category_id="cat-id",
    )

    assert client.last_payload is not None
    assert "deleted_at" in client.last_payload


@pytest.mark.asyncio
async def test_list_categories_raises_migrations_not_applied() -> None:
    service = CategoryService(MissingTableRestClient())

    with pytest.raises(AppException) as exc:
        await service.list_categories(access_token="token", user_id="user-id")

    assert exc.value.code == "MIGRATIONS_NOT_APPLIED"
