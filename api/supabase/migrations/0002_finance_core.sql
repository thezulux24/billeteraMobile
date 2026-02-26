-- 0002_finance_core.sql
-- Core financial model: wallets, accounts, cards, categories and transactions.

create table if not exists public.cash_wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  balance numeric(14,2) not null default 0,
  currency varchar(3) not null default 'USD',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz null
);

create table if not exists public.bank_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  bank_name text,
  balance numeric(14,2) not null default 0,
  currency varchar(3) not null default 'USD',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz null
);

create table if not exists public.credit_cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  issuer text,
  credit_limit numeric(14,2) not null default 0,
  current_debt numeric(14,2) not null default 0,
  statement_day smallint check (statement_day between 1 and 31),
  due_day smallint check (due_day between 1 and 31),
  currency varchar(3) not null default 'USD',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz null
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  kind text not null check (kind in ('income', 'expense', 'transfer', 'credit_payment')),
  color text,
  icon text,
  is_system boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz null,
  unique (user_id, name, kind)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (
    kind in ('income', 'expense', 'transfer', 'credit_charge', 'credit_payment')
  ),
  amount numeric(14,2) not null check (amount > 0),
  currency varchar(3) not null default 'USD',
  description text,
  occurred_at timestamptz not null default timezone('utc', now()),
  category_id uuid references public.categories(id),
  cash_wallet_id uuid references public.cash_wallets(id),
  bank_account_id uuid references public.bank_accounts(id),
  credit_card_id uuid references public.credit_cards(id),
  target_cash_wallet_id uuid references public.cash_wallets(id),
  target_bank_account_id uuid references public.bank_accounts(id),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  deleted_at timestamptz null
);

create index if not exists idx_cash_wallets_user_id on public.cash_wallets (user_id);
create index if not exists idx_bank_accounts_user_id on public.bank_accounts (user_id);
create index if not exists idx_credit_cards_user_id on public.credit_cards (user_id);
create index if not exists idx_categories_user_id_kind on public.categories (user_id, kind);
create index if not exists idx_transactions_user_id_occurred_at on public.transactions (user_id, occurred_at desc);
create index if not exists idx_transactions_category_id on public.transactions (category_id);

drop trigger if exists trg_cash_wallets_updated_at on public.cash_wallets;
create trigger trg_cash_wallets_updated_at
before update on public.cash_wallets
for each row execute function public.set_updated_at();

drop trigger if exists trg_bank_accounts_updated_at on public.bank_accounts;
create trigger trg_bank_accounts_updated_at
before update on public.bank_accounts
for each row execute function public.set_updated_at();

drop trigger if exists trg_credit_cards_updated_at on public.credit_cards;
create trigger trg_credit_cards_updated_at
before update on public.credit_cards
for each row execute function public.set_updated_at();

drop trigger if exists trg_categories_updated_at on public.categories;
create trigger trg_categories_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

drop trigger if exists trg_transactions_updated_at on public.transactions;
create trigger trg_transactions_updated_at
before update on public.transactions
for each row execute function public.set_updated_at();

alter table public.cash_wallets enable row level security;
alter table public.bank_accounts enable row level security;
alter table public.credit_cards enable row level security;
alter table public.categories enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "cash_wallets_select_own" on public.cash_wallets;
create policy "cash_wallets_select_own"
on public.cash_wallets
for select
to authenticated
using (user_id = auth.uid() and deleted_at is null);

drop policy if exists "cash_wallets_insert_own" on public.cash_wallets;
create policy "cash_wallets_insert_own"
on public.cash_wallets
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "cash_wallets_update_own" on public.cash_wallets;
create policy "cash_wallets_update_own"
on public.cash_wallets
for update
to authenticated
using (user_id = auth.uid() and deleted_at is null)
with check (user_id = auth.uid());

drop policy if exists "bank_accounts_select_own" on public.bank_accounts;
create policy "bank_accounts_select_own"
on public.bank_accounts
for select
to authenticated
using (user_id = auth.uid() and deleted_at is null);

drop policy if exists "bank_accounts_insert_own" on public.bank_accounts;
create policy "bank_accounts_insert_own"
on public.bank_accounts
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "bank_accounts_update_own" on public.bank_accounts;
create policy "bank_accounts_update_own"
on public.bank_accounts
for update
to authenticated
using (user_id = auth.uid() and deleted_at is null)
with check (user_id = auth.uid());

drop policy if exists "credit_cards_select_own" on public.credit_cards;
create policy "credit_cards_select_own"
on public.credit_cards
for select
to authenticated
using (user_id = auth.uid() and deleted_at is null);

drop policy if exists "credit_cards_insert_own" on public.credit_cards;
create policy "credit_cards_insert_own"
on public.credit_cards
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "credit_cards_update_own" on public.credit_cards;
create policy "credit_cards_update_own"
on public.credit_cards
for update
to authenticated
using (user_id = auth.uid() and deleted_at is null)
with check (user_id = auth.uid());

drop policy if exists "categories_select_own" on public.categories;
create policy "categories_select_own"
on public.categories
for select
to authenticated
using (user_id = auth.uid() and deleted_at is null);

drop policy if exists "categories_insert_own" on public.categories;
create policy "categories_insert_own"
on public.categories
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "categories_update_own" on public.categories;
create policy "categories_update_own"
on public.categories
for update
to authenticated
using (user_id = auth.uid() and deleted_at is null)
with check (user_id = auth.uid());

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own"
on public.transactions
for select
to authenticated
using (user_id = auth.uid() and deleted_at is null);

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own"
on public.transactions
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own"
on public.transactions
for update
to authenticated
using (user_id = auth.uid() and deleted_at is null)
with check (user_id = auth.uid());
