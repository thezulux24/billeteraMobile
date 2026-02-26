from fastapi import APIRouter, Depends

from app.dependencies.auth import AuthContext, get_auth_context, get_auth_service
from app.schemas.auth import (
    AuthSessionResponse,
    CredentialsRequest,
    MeResponse,
    RefreshRequest,
    ResetPasswordRequest,
    SignOutRequest,
)
from app.schemas.common import SuccessResponse
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/sign-up", response_model=AuthSessionResponse)
async def sign_up(
    request: CredentialsRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> AuthSessionResponse:
    return await auth_service.sign_up(email=request.email, password=request.password)


@router.post("/sign-in", response_model=AuthSessionResponse)
async def sign_in(
    request: CredentialsRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> AuthSessionResponse:
    return await auth_service.sign_in(email=request.email, password=request.password)


@router.post("/refresh", response_model=AuthSessionResponse)
async def refresh(
    request: RefreshRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> AuthSessionResponse:
    return await auth_service.refresh(refresh_token=request.refresh_token)


@router.post("/sign-out", response_model=SuccessResponse)
async def sign_out(
    request: SignOutRequest,
    context: AuthContext = Depends(get_auth_context),
    auth_service: AuthService = Depends(get_auth_service),
) -> SuccessResponse:
    _ = request.refresh_token
    await auth_service.sign_out(access_token=context.access_token)
    return SuccessResponse(success=True)


@router.post("/reset-password", response_model=SuccessResponse)
async def reset_password(
    request: ResetPasswordRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> SuccessResponse:
    await auth_service.reset_password(email=request.email)
    return SuccessResponse(success=True)


@router.get("/me", response_model=MeResponse)
async def me(context: AuthContext = Depends(get_auth_context)) -> MeResponse:
    return MeResponse(
        id=context.user_id,
        email=context.email,
        last_sign_in_at=context.last_sign_in_at,
    )
