from datetime import datetime

from pydantic import BaseModel, Field


class ProfileResponse(BaseModel):
    id: str
    base_currency: str = Field(min_length=3, max_length=3)
    ai_enabled: bool
    created_at: datetime
    updated_at: datetime


class ProfileUpdateRequest(BaseModel):
    base_currency: str | None = Field(default=None, min_length=3, max_length=3)
    ai_enabled: bool | None = None

