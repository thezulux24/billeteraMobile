from fastapi import APIRouter, Depends
from app.dependencies.auth import AuthContext, get_auth_context, get_credit_card_service
from app.schemas.credit_card import (
    CreditCardCreateRequest,
    CreditCardResponse,
    CreditCardUpdateRequest,
)
from app.schemas.common import SuccessResponse
from app.services.credit_card_service import CreditCardService

router = APIRouter()

@router.get("", response_model=list[CreditCardResponse])
async def list_credit_cards(
    context: AuthContext = Depends(get_auth_context),
    card_service: CreditCardService = Depends(get_credit_card_service),
) -> list[CreditCardResponse]:
    return await card_service.list_cards(
        access_token=context.access_token,
        user_id=context.user_id,
    )

@router.post("", response_model=CreditCardResponse)
async def create_credit_card(
    request: CreditCardCreateRequest,
    context: AuthContext = Depends(get_auth_context),
    card_service: CreditCardService = Depends(get_credit_card_service),
) -> CreditCardResponse:
    return await card_service.create_card(
        access_token=context.access_token,
        user_id=context.user_id,
        request=request,
    )

@router.patch("/{card_id}", response_model=CreditCardResponse)
async def patch_credit_card(
    card_id: str,
    request: CreditCardUpdateRequest,
    context: AuthContext = Depends(get_auth_context),
    card_service: CreditCardService = Depends(get_credit_card_service),
) -> CreditCardResponse:
    return await card_service.update_card(
        access_token=context.access_token,
        user_id=context.user_id,
        card_id=card_id,
        request=request,
    )

@router.delete("/{card_id}", response_model=SuccessResponse)
async def delete_credit_card(
    card_id: str,
    context: AuthContext = Depends(get_auth_context),
    card_service: CreditCardService = Depends(get_credit_card_service),
) -> SuccessResponse:
    await card_service.delete_card(
        access_token=context.access_token,
        user_id=context.user_id,
        card_id=card_id,
    )
    return SuccessResponse(success=True)
