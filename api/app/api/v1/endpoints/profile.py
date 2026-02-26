from fastapi import APIRouter, Depends

from app.dependencies.auth import AuthContext, get_auth_context, get_profile_service
from app.schemas.profile import ProfileResponse, ProfileUpdateRequest
from app.services.profile_service import ProfileService

router = APIRouter()


@router.get("", response_model=ProfileResponse)
async def get_profile(
    context: AuthContext = Depends(get_auth_context),
    profile_service: ProfileService = Depends(get_profile_service),
) -> ProfileResponse:
    return await profile_service.get_profile(
        access_token=context.access_token,
        user_id=context.user_id,
    )


@router.patch("", response_model=ProfileResponse)
async def patch_profile(
    request: ProfileUpdateRequest,
    context: AuthContext = Depends(get_auth_context),
    profile_service: ProfileService = Depends(get_profile_service),
) -> ProfileResponse:
    return await profile_service.update_profile(
        access_token=context.access_token,
        user_id=context.user_id,
        update=request,
    )

