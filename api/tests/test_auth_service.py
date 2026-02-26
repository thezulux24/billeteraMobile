import pytest

from app.core.exceptions import AppException
from app.services.auth_service import AuthService, build_session_response


def test_build_session_response_success() -> None:
    payload = {
        "access_token": "access-token",
        "refresh_token": "refresh-token",
        "expires_in": 3600,
        "token_type": "bearer",
        "user": {"id": "user-id", "email": "user@example.com"},
    }

    response = build_session_response(payload)
    assert response.access_token == "access-token"
    assert response.refresh_token == "refresh-token"
    assert response.user.id == "user-id"
    assert response.user.email == "user@example.com"


def test_build_session_response_success_with_nested_session() -> None:
    payload = {
        "user": {"id": "user-id", "email": "user@example.com"},
        "session": {
            "access_token": "access-token",
            "refresh_token": "refresh-token",
            "expires_in": 3600,
            "token_type": "bearer",
        },
    }

    response = build_session_response(payload)
    assert response.access_token == "access-token"
    assert response.refresh_token == "refresh-token"
    assert response.user.id == "user-id"
    assert response.user.email == "user@example.com"


def test_build_session_response_requires_session() -> None:
    payload = {}
    with pytest.raises(AppException) as exc:
        build_session_response(payload)
    assert exc.value.code == "AUTH_SESSION_NOT_AVAILABLE"


def test_build_session_response_requires_email_confirmation() -> None:
    payload = {"user": {"id": "user-id", "email": "user@example.com"}}
    with pytest.raises(AppException) as exc:
        build_session_response(payload)
    assert exc.value.code == "EMAIL_CONFIRMATION_REQUIRED"


def test_build_session_response_requires_valid_user() -> None:
    payload = {
        "access_token": "access-token",
        "refresh_token": "refresh-token",
        "expires_in": 3600,
        "token_type": "bearer",
        "user": {"id": "user-id"},
    }
    with pytest.raises(AppException) as exc:
        build_session_response(payload)
    assert exc.value.code == "INVALID_AUTH_USER"


class _FakeAuthClient:
    def __init__(
        self,
        *,
        has_service_role: bool,
        sign_up_payload: dict | None = None,
        sign_in_payload: dict | None = None,
        admin_error: AppException | None = None,
    ) -> None:
        self.has_service_role = has_service_role
        self.sign_up_payload = sign_up_payload or {}
        self.sign_in_payload = sign_in_payload or {}
        self.admin_error = admin_error
        self.calls: list[str] = []

    async def admin_create_user(self, *, email: str, password: str, email_confirm: bool) -> dict:
        self.calls.append("admin_create_user")
        if self.admin_error is not None:
            raise self.admin_error
        return {"id": "user-id", "email": email}

    async def sign_up(self, *, email: str, password: str) -> dict:
        self.calls.append("sign_up")
        return self.sign_up_payload

    async def sign_in(self, *, email: str, password: str) -> dict:
        self.calls.append("sign_in")
        return self.sign_in_payload

    async def refresh(self, *, refresh_token: str) -> dict:
        self.calls.append("refresh")
        return {}

    async def sign_out(self, *, access_token: str) -> None:
        self.calls.append("sign_out")

    async def recover(self, *, email: str) -> None:
        self.calls.append("recover")

    async def get_user(self, *, access_token: str) -> dict:
        self.calls.append("get_user")
        return {}


@pytest.mark.asyncio
async def test_sign_up_uses_admin_create_when_service_role_exists() -> None:
    client = _FakeAuthClient(
        has_service_role=True,
        sign_in_payload={
            "access_token": "access-token",
            "refresh_token": "refresh-token",
            "expires_in": 3600,
            "token_type": "bearer",
            "user": {"id": "user-id", "email": "user@example.com"},
        },
    )
    service = AuthService(client)  # type: ignore[arg-type]

    response = await service.sign_up(email="user@example.com", password="Test123456!")

    assert response.access_token == "access-token"
    assert client.calls == ["admin_create_user", "sign_in"]


@pytest.mark.asyncio
async def test_sign_up_without_service_role_falls_back_to_sign_in() -> None:
    client = _FakeAuthClient(
        has_service_role=False,
        sign_up_payload={"user": {"id": "user-id", "email": "user@example.com"}},
        sign_in_payload={
            "access_token": "access-token",
            "refresh_token": "refresh-token",
            "expires_in": 3600,
            "token_type": "bearer",
            "user": {"id": "user-id", "email": "user@example.com"},
        },
    )
    service = AuthService(client)  # type: ignore[arg-type]

    response = await service.sign_up(email="user@example.com", password="Test123456!")

    assert response.access_token == "access-token"
    assert client.calls == ["sign_up", "sign_in"]


@pytest.mark.asyncio
async def test_sign_up_maps_existing_email_to_conflict() -> None:
    client = _FakeAuthClient(
        has_service_role=True,
        admin_error=AppException(
            status_code=422,
            code="email_exists",
            message="A user with this email address has already been registered",
        ),
    )
    service = AuthService(client)  # type: ignore[arg-type]

    with pytest.raises(AppException) as exc:
        await service.sign_up(email="user@example.com", password="Test123456!")

    assert exc.value.status_code == 409
    assert exc.value.code == "EMAIL_ALREADY_REGISTERED"
    assert client.calls == ["admin_create_user"]
