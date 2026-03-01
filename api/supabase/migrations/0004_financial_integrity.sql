-- 0004_financial_integrity.sql
-- Enforces transaction shape and keeps asset balances / card debt in sync.

create or replace function public._tx_validate_category(
  p_user_id uuid,
  p_kind text,
  p_category_id uuid
)
returns void
language plpgsql
as $$
declare
  v_category_kind text;
begin
  if p_category_id is null then
    return;
  end if;

  select c.kind
    into v_category_kind
    from public.categories c
   where c.id = p_category_id
     and c.user_id = p_user_id
     and c.deleted_at is null;

  if v_category_kind is null then
    raise exception using
      message = 'INVALID_CATEGORY',
      detail = 'Category not found or not available for current user.';
  end if;

  if p_kind = 'income' and v_category_kind <> 'income' then
    raise exception using
      message = 'INVALID_CATEGORY_KIND',
      detail = 'Income transactions require an income category.';
  end if;

  if p_kind in ('expense', 'credit_charge') and v_category_kind <> 'expense' then
    raise exception using
      message = 'INVALID_CATEGORY_KIND',
      detail = 'Expense and credit charge transactions require an expense category.';
  end if;

  if p_kind = 'transfer' and v_category_kind <> 'transfer' then
    raise exception using
      message = 'INVALID_CATEGORY_KIND',
      detail = 'Transfer transactions require a transfer category.';
  end if;

  if p_kind = 'credit_payment' and v_category_kind not in ('credit_payment', 'transfer') then
    raise exception using
      message = 'INVALID_CATEGORY_KIND',
      detail = 'Credit payment transactions require a credit_payment or transfer category.';
  end if;
end;
$$;

create or replace function public._tx_validate_references(
  p_user_id uuid,
  p_cash_wallet_id uuid,
  p_bank_account_id uuid,
  p_credit_card_id uuid,
  p_target_cash_wallet_id uuid,
  p_target_bank_account_id uuid
)
returns void
language plpgsql
as $$
begin
  if p_cash_wallet_id is not null then
    perform 1
      from public.cash_wallets cw
     where cw.id = p_cash_wallet_id
       and cw.user_id = p_user_id
       and cw.deleted_at is null;
    if not found then
      raise exception using
        message = 'INVALID_CASH_WALLET',
        detail = 'cash_wallet_id not found, deleted, or not owned by user.';
    end if;
  end if;

  if p_bank_account_id is not null then
    perform 1
      from public.bank_accounts ba
     where ba.id = p_bank_account_id
       and ba.user_id = p_user_id
       and ba.deleted_at is null;
    if not found then
      raise exception using
        message = 'INVALID_BANK_ACCOUNT',
        detail = 'bank_account_id not found, deleted, or not owned by user.';
    end if;
  end if;

  if p_credit_card_id is not null then
    perform 1
      from public.credit_cards cc
     where cc.id = p_credit_card_id
       and cc.user_id = p_user_id
       and cc.deleted_at is null;
    if not found then
      raise exception using
        message = 'INVALID_CREDIT_CARD',
        detail = 'credit_card_id not found, deleted, or not owned by user.';
    end if;
  end if;

  if p_target_cash_wallet_id is not null then
    perform 1
      from public.cash_wallets cw
     where cw.id = p_target_cash_wallet_id
       and cw.user_id = p_user_id
       and cw.deleted_at is null;
    if not found then
      raise exception using
        message = 'INVALID_TARGET_CASH_WALLET',
        detail = 'target_cash_wallet_id not found, deleted, or not owned by user.';
    end if;
  end if;

  if p_target_bank_account_id is not null then
    perform 1
      from public.bank_accounts ba
     where ba.id = p_target_bank_account_id
       and ba.user_id = p_user_id
       and ba.deleted_at is null;
    if not found then
      raise exception using
        message = 'INVALID_TARGET_BANK_ACCOUNT',
        detail = 'target_bank_account_id not found, deleted, or not owned by user.';
    end if;
  end if;
end;
$$;

create or replace function public._tx_validate_shape(
  p_kind text,
  p_cash_wallet_id uuid,
  p_bank_account_id uuid,
  p_credit_card_id uuid,
  p_target_cash_wallet_id uuid,
  p_target_bank_account_id uuid
)
returns void
language plpgsql
as $$
declare
  v_asset_count int := (p_cash_wallet_id is not null)::int + (p_bank_account_id is not null)::int;
  v_target_asset_count int := (p_target_cash_wallet_id is not null)::int + (p_target_bank_account_id is not null)::int;
  v_has_credit_card boolean := p_credit_card_id is not null;
begin
  if p_kind = 'income' then
    if v_asset_count <> 1 or v_has_credit_card or v_target_asset_count <> 0 then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'income requires one asset source (cash_wallet_id or bank_account_id).';
    end if;
    return;
  end if;

  if p_kind = 'expense' then
    if v_target_asset_count <> 0 then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'expense does not accept target asset fields.';
    end if;

    -- Supports both cash/bank expenses and card expenses.
    if not (
      (v_asset_count = 1 and not v_has_credit_card)
      or
      (v_asset_count = 0 and v_has_credit_card)
    ) then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'expense must use exactly one asset OR one credit_card_id.';
    end if;
    return;
  end if;

  if p_kind = 'transfer' then
    if v_asset_count <> 1 or v_target_asset_count <> 1 or v_has_credit_card then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'transfer requires one source asset and one target asset.';
    end if;

    if p_cash_wallet_id is not null and p_target_cash_wallet_id = p_cash_wallet_id then
      raise exception using
        message = 'INVALID_TRANSFER_TARGET',
        detail = 'source and target cash wallet cannot be the same.';
    end if;

    if p_bank_account_id is not null and p_target_bank_account_id = p_bank_account_id then
      raise exception using
        message = 'INVALID_TRANSFER_TARGET',
        detail = 'source and target bank account cannot be the same.';
    end if;
    return;
  end if;

  if p_kind = 'credit_charge' then
    if v_has_credit_card is false or v_asset_count <> 0 or v_target_asset_count <> 0 then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'credit_charge requires credit_card_id and no asset fields.';
    end if;
    return;
  end if;

  if p_kind = 'credit_payment' then
    if v_has_credit_card is false or v_asset_count <> 1 or v_target_asset_count <> 0 then
      raise exception using
        message = 'INVALID_TRANSACTION_SHAPE',
        detail = 'credit_payment requires one source asset and one credit_card_id.';
    end if;
    return;
  end if;

  raise exception using
    message = 'INVALID_TRANSACTION_KIND',
    detail = 'Unsupported transaction kind.';
end;
$$;

create or replace function public._tx_adjust_asset_balance(
  p_user_id uuid,
  p_cash_wallet_id uuid,
  p_bank_account_id uuid,
  p_delta numeric
)
returns void
language plpgsql
as $$
begin
  if p_cash_wallet_id is not null then
    update public.cash_wallets
       set balance = balance + p_delta
     where id = p_cash_wallet_id
       and user_id = p_user_id
       and deleted_at is null;

    if not found then
      raise exception using
        message = 'ASSET_NOT_FOUND',
        detail = 'cash_wallet_id not found while applying transaction effect.';
    end if;
    return;
  end if;

  if p_bank_account_id is not null then
    update public.bank_accounts
       set balance = balance + p_delta
     where id = p_bank_account_id
       and user_id = p_user_id
       and deleted_at is null;

    if not found then
      raise exception using
        message = 'ASSET_NOT_FOUND',
        detail = 'bank_account_id not found while applying transaction effect.';
    end if;
    return;
  end if;

  raise exception using
    message = 'ASSET_REFERENCE_REQUIRED',
    detail = 'Transaction effect requires a source asset reference.';
end;
$$;

create or replace function public._tx_adjust_credit_card_debt(
  p_user_id uuid,
  p_credit_card_id uuid,
  p_delta numeric
)
returns void
language plpgsql
as $$
begin
  update public.credit_cards
     set current_debt = current_debt + p_delta
   where id = p_credit_card_id
     and user_id = p_user_id
     and deleted_at is null;

  if not found then
    raise exception using
      message = 'CREDIT_CARD_NOT_FOUND',
      detail = 'credit_card_id not found while applying transaction effect.';
  end if;
end;
$$;

create or replace function public._tx_apply_effect(
  p_tx public.transactions,
  p_multiplier int
)
returns void
language plpgsql
as $$
begin
  if p_tx.kind = 'income' then
    perform public._tx_adjust_asset_balance(
      p_tx.user_id,
      p_tx.cash_wallet_id,
      p_tx.bank_account_id,
      p_tx.amount * p_multiplier
    );
    return;
  end if;

  if p_tx.kind = 'expense' then
    if p_tx.credit_card_id is not null then
      perform public._tx_adjust_credit_card_debt(
        p_tx.user_id,
        p_tx.credit_card_id,
        p_tx.amount * p_multiplier
      );
    else
      perform public._tx_adjust_asset_balance(
        p_tx.user_id,
        p_tx.cash_wallet_id,
        p_tx.bank_account_id,
        -p_tx.amount * p_multiplier
      );
    end if;
    return;
  end if;

  if p_tx.kind = 'transfer' then
    perform public._tx_adjust_asset_balance(
      p_tx.user_id,
      p_tx.cash_wallet_id,
      p_tx.bank_account_id,
      -p_tx.amount * p_multiplier
    );

    perform public._tx_adjust_asset_balance(
      p_tx.user_id,
      p_tx.target_cash_wallet_id,
      p_tx.target_bank_account_id,
      p_tx.amount * p_multiplier
    );
    return;
  end if;

  if p_tx.kind = 'credit_charge' then
    perform public._tx_adjust_credit_card_debt(
      p_tx.user_id,
      p_tx.credit_card_id,
      p_tx.amount * p_multiplier
    );
    return;
  end if;

  if p_tx.kind = 'credit_payment' then
    perform public._tx_adjust_asset_balance(
      p_tx.user_id,
      p_tx.cash_wallet_id,
      p_tx.bank_account_id,
      -p_tx.amount * p_multiplier
    );

    perform public._tx_adjust_credit_card_debt(
      p_tx.user_id,
      p_tx.credit_card_id,
      -p_tx.amount * p_multiplier
    );
    return;
  end if;
end;
$$;

create or replace function public.trg_transactions_integrity_before()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and new.user_id is distinct from old.user_id then
    raise exception using
      message = 'IMMUTABLE_TRANSACTION_USER',
      detail = 'user_id cannot be changed once a transaction is created.';
  end if;

  new.currency := upper(new.currency);

  -- Soft delete update should skip shape validation.
  if tg_op = 'UPDATE' and new.deleted_at is not null then
    return new;
  end if;

  perform public._tx_validate_shape(
    new.kind,
    new.cash_wallet_id,
    new.bank_account_id,
    new.credit_card_id,
    new.target_cash_wallet_id,
    new.target_bank_account_id
  );

  perform public._tx_validate_references(
    new.user_id,
    new.cash_wallet_id,
    new.bank_account_id,
    new.credit_card_id,
    new.target_cash_wallet_id,
    new.target_bank_account_id
  );

  perform public._tx_validate_category(
    new.user_id,
    new.kind,
    new.category_id
  );

  return new;
end;
$$;

create or replace function public.trg_transactions_apply_effects()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if new.deleted_at is null then
      perform public._tx_apply_effect(new, 1);
    end if;
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if old.deleted_at is null and new.deleted_at is not null then
      perform public._tx_apply_effect(old, -1);
      return new;
    end if;

    if old.deleted_at is not null and new.deleted_at is null then
      perform public._tx_apply_effect(new, 1);
      return new;
    end if;

    if old.deleted_at is null and new.deleted_at is null then
      if old.kind is distinct from new.kind
         or old.amount is distinct from new.amount
         or old.cash_wallet_id is distinct from new.cash_wallet_id
         or old.bank_account_id is distinct from new.bank_account_id
         or old.credit_card_id is distinct from new.credit_card_id
         or old.target_cash_wallet_id is distinct from new.target_cash_wallet_id
         or old.target_bank_account_id is distinct from new.target_bank_account_id then
        perform public._tx_apply_effect(old, -1);
        perform public._tx_apply_effect(new, 1);
      end if;
    end if;

    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.deleted_at is null then
      perform public._tx_apply_effect(old, -1);
    end if;
    return old;
  end if;

  return null;
end;
$$;

drop trigger if exists trg_transactions_integrity_before on public.transactions;
create trigger trg_transactions_integrity_before
before insert or update on public.transactions
for each row execute function public.trg_transactions_integrity_before();

drop trigger if exists trg_transactions_apply_effects on public.transactions;
create trigger trg_transactions_apply_effects
after insert or update or delete on public.transactions
for each row execute function public.trg_transactions_apply_effects();
