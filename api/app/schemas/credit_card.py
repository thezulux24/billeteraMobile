from datetime import datetime
from pydantic import BaseModel, Field

class CreditCardCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    issuer: str | None = Field(default=None, max_length=120)
    tier: str | None = Field(default="classic", max_length=15)
    credit_limit: float = Field(default=0, ge=0)
    current_debt: float = Field(default=0, ge=0)
    statement_day: int | None = Field(default=None, ge=1, le=31)
    due_day: int | None = Field(default=None, ge=1, le=31)
    currency: str = Field(default="USD", min_length=3, max_length=3)

class CreditCardUpdateRequest(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    issuer: str | None = Field(default=None, max_length=120)
    tier: str | None = Field(default=None, max_length=15)
    credit_limit: float | None = Field(default=None, ge=0)
    current_debt: float | None = Field(default=None, ge=0)
    statement_day: int | None = Field(default=None, ge=1, le=31)
    due_day: int | None = Field(default=None, ge=1, le=31)
    currency: str | None = Field(default=None, min_length=3, max_length=3)

class CreditCardResponse(BaseModel):
    id: str
    name: str
    issuer: str | None = None
    tier: str
    credit_limit: float
    current_debt: float
    statement_day: int | None = None
    due_day: int | None = None
    currency: str
    created_at: datetime
    updated_at: datetime
