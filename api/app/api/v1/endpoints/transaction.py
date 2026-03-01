from datetime import datetime

from fastapi import APIRouter, Depends, Query
from app.dependencies.auth import AuthContext, get_auth_context, get_transaction_service
from app.schemas.common import SuccessResponse
from app.schemas.transaction import (
    TransactionCreateRequest,
    TransactionResponse,
    TransactionUpdateRequest,
)
from app.services.transaction_service import TransactionService

router = APIRouter()

@router.get("", response_model=list[TransactionResponse])
async def list_transactions(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    kind: str | None = Query(
        default=None,
        pattern="^(income|expense|transfer|credit_charge|credit_payment)$",
    ),
    category_id: str | None = Query(default=None),
    cash_wallet_id: str | None = Query(default=None),
    bank_account_id: str | None = Query(default=None),
    credit_card_id: str | None = Query(default=None),
    occurred_from: datetime | None = Query(default=None),
    occurred_to: datetime | None = Query(default=None),
    context: AuthContext = Depends(get_auth_context),
    transaction_service: TransactionService = Depends(get_transaction_service),
) -> list[TransactionResponse]:
    return await transaction_service.list_transactions(
        access_token=context.access_token,
        user_id=context.user_id,
        limit=limit,
        offset=offset,
        kind=kind,
        category_id=category_id,
        cash_wallet_id=cash_wallet_id,
        bank_account_id=bank_account_id,
        credit_card_id=credit_card_id,
        occurred_from=occurred_from,
        occurred_to=occurred_to,
    )

@router.post("", response_model=TransactionResponse)
async def create_transaction(
    request: TransactionCreateRequest,
    context: AuthContext = Depends(get_auth_context),
    transaction_service: TransactionService = Depends(get_transaction_service),
) -> TransactionResponse:
    return await transaction_service.create_transaction(
        access_token=context.access_token,
        user_id=context.user_id,
        request=request,
    )


@router.patch("/{transaction_id}", response_model=TransactionResponse)
async def patch_transaction(
    transaction_id: str,
    request: TransactionUpdateRequest,
    context: AuthContext = Depends(get_auth_context),
    transaction_service: TransactionService = Depends(get_transaction_service),
) -> TransactionResponse:
    return await transaction_service.update_transaction(
        access_token=context.access_token,
        user_id=context.user_id,
        transaction_id=transaction_id,
        request=request,
    )


@router.delete("/{transaction_id}", response_model=SuccessResponse)
async def delete_transaction(
    transaction_id: str,
    context: AuthContext = Depends(get_auth_context),
    transaction_service: TransactionService = Depends(get_transaction_service),
) -> SuccessResponse:
    await transaction_service.delete_transaction(
        access_token=context.access_token,
        user_id=context.user_id,
        transaction_id=transaction_id,
    )
    return SuccessResponse(success=True)
