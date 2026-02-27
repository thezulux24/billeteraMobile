-- 0003_credit_card_fields.sql
-- Adds last_four (card's last 4 digits) and card_provider (Visa/Mastercard/Amex/Other)
-- to the credit_cards table. Both columns are nullable so existing rows are unaffected.

alter table public.credit_cards
  add column if not exists last_four varchar(4)
    check (last_four ~ '^\d{4}$'),
  add column if not exists card_provider text
    check (card_provider in ('visa', 'mastercard', 'amex', 'other'));
