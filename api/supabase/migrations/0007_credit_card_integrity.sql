-- 0007_credit_card_integrity.sql
-- Enforces credit card debt bounds for all writes, including transaction side effects.

create or replace function public.trg_credit_cards_validate_limits()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.credit_limit < 0 then
    raise exception using
      message = 'INVALID_CREDIT_LIMIT',
      detail = 'credit_limit cannot be negative.';
  end if;

  if new.current_debt < 0 then
    raise exception using
      message = 'INVALID_CREDIT_PAYMENT',
      detail = 'Payment amount exceeds current credit card debt.';
  end if;

  if new.current_debt > new.credit_limit then
    raise exception using
      message = 'CREDIT_LIMIT_EXCEEDED',
      detail = 'Transaction exceeds available credit limit.';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_credit_cards_validate_limits on public.credit_cards;
create trigger trg_credit_cards_validate_limits
before insert or update on public.credit_cards
for each row execute function public.trg_credit_cards_validate_limits();
