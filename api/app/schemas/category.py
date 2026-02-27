from datetime import datetime
from pydantic import BaseModel, Field

class CategoryCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    kind: str = Field(pattern="^(income|expense|transfer|credit_payment)$")
    color: str | None = Field(default=None, max_length=20)
    icon: str | None = Field(default=None, max_length=50)
    is_system: bool = False

class CategoryUpdateRequest(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    kind: str | None = Field(default=None, pattern="^(income|expense|transfer|credit_payment)$")
    color: str | None = Field(default=None, max_length=20)
    icon: str | None = Field(default=None, max_length=50)

class CategoryResponse(BaseModel):
    id: str
    name: str
    kind: str
    color: str | None = None
    icon: str | None = None
    is_system: bool
    created_at: datetime
    updated_at: datetime
