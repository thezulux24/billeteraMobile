from fastapi import APIRouter, Depends

from app.dependencies.auth import (
    AuthContext,
    get_auth_context,
    get_cash_wallet_service,
)
from app.schemas.cash_wallet import (
    CashWalletCreateRequest,
    CashWalletResponse,
    CashWalletUpdateRequest,
)
from app.schemas.common import SuccessResponse
from app.services.cash_wallet_service import CashWalletService

router = APIRouter()


@router.get("", response_model=list[CashWalletResponse])
async def list_cash_wallets(
    context: AuthContext = Depends(get_auth_context),
    cash_wallet_service: CashWalletService = Depends(get_cash_wallet_service),
) -> list[CashWalletResponse]:
    return await cash_wallet_service.list_wallets(
        access_token=context.access_token,
        user_id=context.user_id,
    )


@router.post("", response_model=CashWalletResponse)
async def create_cash_wallet(
    request: CashWalletCreateRequest,
    context: AuthContext = Depends(get_auth_context),
    cash_wallet_service: CashWalletService = Depends(get_cash_wallet_service),
) -> CashWalletResponse:
    return await cash_wallet_service.create_wallet(
        access_token=context.access_token,
        user_id=context.user_id,
        request=request,
    )


@router.patch("/{wallet_id}", response_model=CashWalletResponse)
async def patch_cash_wallet(
    wallet_id: str,
    request: CashWalletUpdateRequest,
    context: AuthContext = Depends(get_auth_context),
    cash_wallet_service: CashWalletService = Depends(get_cash_wallet_service),
) -> CashWalletResponse:
    return await cash_wallet_service.update_wallet(
        access_token=context.access_token,
        user_id=context.user_id,
        wallet_id=wallet_id,
        request=request,
    )


@router.delete("/{wallet_id}", response_model=SuccessResponse)
async def delete_cash_wallet(
    wallet_id: str,
    context: AuthContext = Depends(get_auth_context),
    cash_wallet_service: CashWalletService = Depends(get_cash_wallet_service),
) -> SuccessResponse:
    await cash_wallet_service.delete_wallet(
        access_token=context.access_token,
        user_id=context.user_id,
        wallet_id=wallet_id,
    )
    return SuccessResponse(success=True)
