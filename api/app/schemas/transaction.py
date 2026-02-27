from datetime import datetime
from pydantic import BaseModel, Field

class TransactionCreateRequest(BaseModel):
    kind: str = Field(pattern="^(income|expense|transfer|credit_charge|credit_payment)$")
    amount: float = Field(gt=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)
    description: str | None = Field(default=None, max_length=255)
    occurred_at: datetime | None = Field(default_factory=datetime.utcnow)
    category_id: str | None = None
    cash_wallet_id: str | None = None
    bank_account_id: str | None = None
    credit_card_id: str | None = None
    target_cash_wallet_id: str | None = None
    target_bank_account_id: str | None = None

class TransactionUpdateRequest(BaseModel):
    kind: str | None = Field(default=None, pattern="^(income|expense|transfer|credit_charge|credit_payment)$")
    amount: float | None = Field(default=None, gt=0)
    currency: str | None = Field(default=None, min_length=3, max_length=3)
    description: str | None = Field(default=None, max_length=255)
    occurred_at: datetime | None = None
    category_id: str | None = None

class TransactionResponse(BaseModel):
    id: str
    kind: str
    amount: float
    currency: str
    description: str | None = None
    occurred_at: datetime
    category_id: str | None = None
    cash_wallet_id: str | None = None
    bank_account_id: str | None = None
    credit_card_id: str | None = None
    target_cash_wallet_id: str | None = None
    target_bank_account_id: str | None = None
    created_at: datetime
    updated_at: datetime
