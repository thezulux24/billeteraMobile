from datetime import datetime
from pydantic import BaseModel, Field, field_validator
import re

_PROVIDER_VALUES = {"visa", "mastercard", "amex", "other"}
_TIER_VALUES     = {"classic", "gold", "platinum", "black"}


class CreditCardCreateRequest(BaseModel):
    name:          str        = Field(min_length=1, max_length=80)
    issuer:        str | None = Field(default=None, max_length=120)
    last_four:     str | None = Field(default=None, max_length=4,  description="Last 4 digits of the card")
    card_provider: str | None = Field(default=None, max_length=20, description="visa | mastercard | amex | other")
    tier:          str | None = Field(default="classic", max_length=15)
    credit_limit:  float      = Field(default=0, ge=0)
    current_debt:  float      = Field(default=0, ge=0)
    statement_day: int | None = Field(default=None, ge=1, le=31)
    due_day:       int | None = Field(default=None, ge=1, le=31)
    currency:      str        = Field(default="USD", min_length=3, max_length=3)

    @field_validator("last_four")
    @classmethod
    def validate_last_four(cls, v: str | None) -> str | None:
        if v is not None and not re.fullmatch(r"\d{4}", v):
            raise ValueError("last_four must be exactly 4 digits")
        return v

    @field_validator("card_provider")
    @classmethod
    def validate_provider(cls, v: str | None) -> str | None:
        if v is not None and v.lower() not in _PROVIDER_VALUES:
            raise ValueError(f"card_provider must be one of {_PROVIDER_VALUES}")
        return v.lower() if v else v

    @field_validator("tier")
    @classmethod
    def validate_tier(cls, v: str | None) -> str | None:
        if v is not None and v.lower() not in _TIER_VALUES:
            raise ValueError(f"tier must be one of {_TIER_VALUES}")
        return v.lower() if v else v


class CreditCardUpdateRequest(BaseModel):
    name:          str | None   = Field(default=None, min_length=1, max_length=80)
    issuer:        str | None   = Field(default=None, max_length=120)
    last_four:     str | None   = Field(default=None, max_length=4)
    card_provider: str | None   = Field(default=None, max_length=20)
    tier:          str | None   = Field(default=None, max_length=15)
    credit_limit:  float | None = Field(default=None, ge=0)
    current_debt:  float | None = Field(default=None, ge=0)
    statement_day: int | None   = Field(default=None, ge=1, le=31)
    due_day:       int | None   = Field(default=None, ge=1, le=31)
    currency:      str | None   = Field(default=None, min_length=3, max_length=3)

    @field_validator("last_four")
    @classmethod
    def validate_last_four(cls, v: str | None) -> str | None:
        if v is not None and not re.fullmatch(r"\d{4}", v):
            raise ValueError("last_four must be exactly 4 digits")
        return v

    @field_validator("card_provider")
    @classmethod
    def validate_provider(cls, v: str | None) -> str | None:
        if v is not None and v.lower() not in _PROVIDER_VALUES:
            raise ValueError(f"card_provider must be one of {_PROVIDER_VALUES}")
        return v.lower() if v else v

    @field_validator("tier")
    @classmethod
    def validate_tier(cls, v: str | None) -> str | None:
        if v is not None and v.lower() not in _TIER_VALUES:
            raise ValueError(f"tier must be one of {_TIER_VALUES}")
        return v.lower() if v else v


class CreditCardResponse(BaseModel):
    id:            str
    name:          str
    issuer:        str | None = None
    last_four:     str | None = None
    card_provider: str | None = None
    tier:          str
    credit_limit:  float
    current_debt:  float
    statement_day: int | None = None
    due_day:       int | None = None
    currency:      str
    created_at:    datetime
    updated_at:    datetime
