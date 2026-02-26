from fastapi import APIRouter, Depends

from app.dependencies.auth import AuthContext, get_auth_context, get_bank_account_service
from app.schemas.bank_account import (
    BankAccountCreateRequest,
    BankAccountResponse,
    BankAccountUpdateRequest,
)
from app.schemas.common import SuccessResponse
from app.services.bank_account_service import BankAccountService

router = APIRouter()


@router.get("", response_model=list[BankAccountResponse])
async def list_bank_accounts(
    context: AuthContext = Depends(get_auth_context),
    bank_account_service: BankAccountService = Depends(get_bank_account_service),
) -> list[BankAccountResponse]:
    return await bank_account_service.list_accounts(
        access_token=context.access_token,
        user_id=context.user_id,
    )


@router.post("", response_model=BankAccountResponse)
async def create_bank_account(
    request: BankAccountCreateRequest,
    context: AuthContext = Depends(get_auth_context),
    bank_account_service: BankAccountService = Depends(get_bank_account_service),
) -> BankAccountResponse:
    return await bank_account_service.create_account(
        access_token=context.access_token,
        user_id=context.user_id,
        request=request,
    )


@router.patch("/{account_id}", response_model=BankAccountResponse)
async def patch_bank_account(
    account_id: str,
    request: BankAccountUpdateRequest,
    context: AuthContext = Depends(get_auth_context),
    bank_account_service: BankAccountService = Depends(get_bank_account_service),
) -> BankAccountResponse:
    return await bank_account_service.update_account(
        access_token=context.access_token,
        user_id=context.user_id,
        account_id=account_id,
        request=request,
    )


@router.delete("/{account_id}", response_model=SuccessResponse)
async def delete_bank_account(
    account_id: str,
    context: AuthContext = Depends(get_auth_context),
    bank_account_service: BankAccountService = Depends(get_bank_account_service),
) -> SuccessResponse:
    await bank_account_service.delete_account(
        access_token=context.access_token,
        user_id=context.user_id,
        account_id=account_id,
    )
    return SuccessResponse(success=True)
