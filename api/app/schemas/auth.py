from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class CredentialsRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=20)


class ResetPasswordRequest(BaseModel):
    email: EmailStr


class SignOutRequest(BaseModel):
    refresh_token: str = Field(min_length=20)


class AuthUser(BaseModel):
    id: str
    email: EmailStr


class AuthSessionResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    token_type: str
    user: AuthUser


class MeResponse(BaseModel):
    id: str
    email: EmailStr
    last_sign_in_at: datetime | None = None

