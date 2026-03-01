import re
from datetime import UTC, datetime
from pydantic import BaseModel, Field, field_validator, model_validator

UUID_PATTERN = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$",
)

class TransactionCreateRequest(BaseModel):
    kind: str = Field(pattern="^(income|expense|transfer|credit_charge|credit_payment)$")
    amount: float = Field(gt=0)
    currency: str = Field(default="USD", min_length=3, max_length=3)
    description: str | None = Field(default=None, max_length=255)
    occurred_at: datetime | None = Field(
        default_factory=lambda: datetime.now(UTC),
    )
    category_id: str | None = None
    cash_wallet_id: str | None = None
    bank_account_id: str | None = None
    credit_card_id: str | None = None
    target_cash_wallet_id: str | None = None
    target_bank_account_id: str | None = None

    @field_validator("currency")
    @classmethod
    def normalize_currency(cls, value: str) -> str:
        return value.upper()

    @field_validator(
        "category_id",
        "cash_wallet_id",
        "bank_account_id",
        "credit_card_id",
        "target_cash_wallet_id",
        "target_bank_account_id",
    )
    @classmethod
    def validate_uuid_like(cls, value: str | None) -> str | None:
        if value is None:
            return None
        if not UUID_PATTERN.fullmatch(value):
            raise ValueError("must be a valid UUID string.")
        return value

    @model_validator(mode="after")
    def validate_shape(self) -> "TransactionCreateRequest":
        asset_count = int(self.cash_wallet_id is not None) + int(
            self.bank_account_id is not None,
        )
        target_asset_count = int(self.target_cash_wallet_id is not None) + int(
            self.target_bank_account_id is not None,
        )
        has_credit_card = self.credit_card_id is not None

        if self.kind == "income":
            if asset_count != 1 or has_credit_card or target_asset_count != 0:
                raise ValueError(
                    "income requires exactly one source asset and no credit card/target assets.",
                )
            return self

        if self.kind == "expense":
            valid_expense_shape = (
                (asset_count == 1 and not has_credit_card)
                or (asset_count == 0 and has_credit_card)
            )
            if not valid_expense_shape or target_asset_count != 0:
                raise ValueError(
                    "expense must use exactly one source asset OR one credit card, without target assets.",
                )
            return self

        if self.kind == "transfer":
            if asset_count != 1 or target_asset_count != 1 or has_credit_card:
                raise ValueError(
                    "transfer requires exactly one source asset and one target asset.",
                )
            return self

        if self.kind == "credit_charge":
            if asset_count != 0 or target_asset_count != 0 or not has_credit_card:
                raise ValueError(
                    "credit_charge requires credit_card_id and no asset references.",
                )
            return self

        if self.kind == "credit_payment":
            if asset_count != 1 or target_asset_count != 0 or not has_credit_card:
                raise ValueError(
                    "credit_payment requires one source asset and one credit_card_id.",
                )
            return self

        return self

class TransactionUpdateRequest(BaseModel):
    kind: str | None = Field(default=None, pattern="^(income|expense|transfer|credit_charge|credit_payment)$")
    amount: float | None = Field(default=None, gt=0)
    currency: str | None = Field(default=None, min_length=3, max_length=3)
    description: str | None = Field(default=None, max_length=255)
    occurred_at: datetime | None = None
    category_id: str | None = None
    cash_wallet_id: str | None = None
    bank_account_id: str | None = None
    credit_card_id: str | None = None
    target_cash_wallet_id: str | None = None
    target_bank_account_id: str | None = None

    @field_validator("currency")
    @classmethod
    def normalize_currency(cls, value: str | None) -> str | None:
        if value is None:
            return None
        return value.upper()

    @field_validator(
        "category_id",
        "cash_wallet_id",
        "bank_account_id",
        "credit_card_id",
        "target_cash_wallet_id",
        "target_bank_account_id",
    )
    @classmethod
    def validate_uuid_like(cls, value: str | None) -> str | None:
        if value is None:
            return None
        if not UUID_PATTERN.fullmatch(value):
            raise ValueError("must be a valid UUID string.")
        return value

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
