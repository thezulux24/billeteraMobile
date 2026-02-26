from fastapi import APIRouter

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.bank_account import router as bank_account_router
from app.api.v1.endpoints.cash_wallet import router as cash_wallet_router
from app.api.v1.endpoints.profile import router as profile_router

api_v1_router = APIRouter()
api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_v1_router.include_router(profile_router, prefix="/profile", tags=["profile"])
api_v1_router.include_router(
    cash_wallet_router,
    prefix="/cash-wallets",
    tags=["cash_wallets"],
)
api_v1_router.include_router(
    bank_account_router,
    prefix="/bank-accounts",
    tags=["bank_accounts"],
)
