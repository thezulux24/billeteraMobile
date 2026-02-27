from fastapi import APIRouter, Depends, Query
from app.dependencies.auth import AuthContext, get_auth_context, get_transaction_service
from app.schemas.transaction import (
    TransactionCreateRequest,
    TransactionResponse,
)
from app.services.transaction_service import TransactionService

router = APIRouter()

@router.get("", response_model=list[TransactionResponse])
async def list_transactions(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    context: AuthContext = Depends(get_auth_context),
    transaction_service: TransactionService = Depends(get_transaction_service),
) -> list[TransactionResponse]:
    return await transaction_service.list_transactions(
        access_token=context.access_token,
        user_id=context.user_id,
        limit=limit,
        offset=offset,
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
