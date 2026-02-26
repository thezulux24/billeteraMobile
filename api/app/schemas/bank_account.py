from datetime import datetime

from pydantic import BaseModel, Field


class BankAccountCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    bank_name: str | None = Field(default=None, max_length=120)
    balance: float = Field(default=0, ge=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)


class BankAccountUpdateRequest(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    bank_name: str | None = Field(default=None, max_length=120)
    balance: float | None = Field(default=None, ge=0)
    currency: str | None = Field(default=None, min_length=3, max_length=3)


class BankAccountResponse(BaseModel):
    id: str
    name: str
    bank_name: str | None = None
    balance: float
    currency: str
    created_at: datetime
    updated_at: datetime
