from fastapi import APIRouter, Depends
from app.dependencies.auth import AuthContext, get_auth_context, get_category_service
from app.schemas.category import (
    CategoryCreateRequest,
    CategoryResponse,
    CategoryUpdateRequest,
)
from app.schemas.common import SuccessResponse
from app.services.category_service import CategoryService

router = APIRouter()

@router.get("", response_model=list[CategoryResponse])
async def list_categories(
    context: AuthContext = Depends(get_auth_context),
    category_service: CategoryService = Depends(get_category_service),
) -> list[CategoryResponse]:
    return await category_service.list_categories(
        access_token=context.access_token,
        user_id=context.user_id,
    )

@router.post("", response_model=CategoryResponse)
async def create_category(
    request: CategoryCreateRequest,
    context: AuthContext = Depends(get_auth_context),
    category_service: CategoryService = Depends(get_category_service),
) -> CategoryResponse:
    return await category_service.create_category(
        access_token=context.access_token,
        user_id=context.user_id,
        request=request,
    )

@router.delete("/{category_id}", response_model=SuccessResponse)
async def delete_category(
    category_id: str,
    context: AuthContext = Depends(get_auth_context),
    category_service: CategoryService = Depends(get_category_service),
) -> SuccessResponse:
    await category_service.delete_category(
        access_token=context.access_token,
        user_id=context.user_id,
        category_id=category_id,
    )
    return SuccessResponse(success=True)
