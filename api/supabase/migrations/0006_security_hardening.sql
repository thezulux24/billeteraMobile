-- 0006_security_hardening.sql
-- Security/performance hardening for Supabase linter findings.

-- 1) RLS on schema_migrations to avoid exposure through PostgREST.
alter table if exists public.schema_migrations enable row level security;

-- 2) Fix mutable search_path warnings on trigger/helper functions.
alter function public.set_updated_at() set search_path = public;
alter function public._tx_validate_category(uuid, text, uuid) set search_path = public;
alter function public._tx_validate_references(
  uuid, uuid, uuid, uuid, uuid, uuid
) set search_path = public;
alter function public._tx_validate_shape(
  text, uuid, uuid, uuid, uuid, uuid
) set search_path = public;
alter function public._tx_adjust_asset_balance(
  uuid, uuid, uuid, numeric
) set search_path = public;
alter function public._tx_adjust_credit_card_debt(
  uuid, uuid, numeric
) set search_path = public;
alter function public._tx_apply_effect(public.transactions, integer) set search_path = public;
alter function public.trg_transactions_integrity_before() set search_path = public;
alter function public.trg_transactions_apply_effects() set search_path = public;

-- 3) Optimize RLS policies by caching auth.uid() via init plan.

-- profiles
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (id = (select auth.uid()) and deleted_at is null);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (id = (select auth.uid()) and deleted_at is null)
with check (id = (select auth.uid()));

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check (id = (select auth.uid()));

-- cash_wallets
drop policy if exists "cash_wallets_select_own" on public.cash_wallets;
create policy "cash_wallets_select_own"
on public.cash_wallets
for select
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null);

drop policy if exists "cash_wallets_insert_own" on public.cash_wallets;
create policy "cash_wallets_insert_own"
on public.cash_wallets
for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "cash_wallets_update_own" on public.cash_wallets;
create policy "cash_wallets_update_own"
on public.cash_wallets
for update
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null)
with check (user_id = (select auth.uid()));

-- bank_accounts
drop policy if exists "bank_accounts_select_own" on public.bank_accounts;
create policy "bank_accounts_select_own"
on public.bank_accounts
for select
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null);

drop policy if exists "bank_accounts_insert_own" on public.bank_accounts;
create policy "bank_accounts_insert_own"
on public.bank_accounts
for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "bank_accounts_update_own" on public.bank_accounts;
create policy "bank_accounts_update_own"
on public.bank_accounts
for update
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null)
with check (user_id = (select auth.uid()));

-- credit_cards
drop policy if exists "credit_cards_select_own" on public.credit_cards;
create policy "credit_cards_select_own"
on public.credit_cards
for select
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null);

drop policy if exists "credit_cards_insert_own" on public.credit_cards;
create policy "credit_cards_insert_own"
on public.credit_cards
for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "credit_cards_update_own" on public.credit_cards;
create policy "credit_cards_update_own"
on public.credit_cards
for update
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null)
with check (user_id = (select auth.uid()));

-- categories
drop policy if exists "categories_select_own" on public.categories;
create policy "categories_select_own"
on public.categories
for select
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null);

drop policy if exists "categories_insert_own" on public.categories;
create policy "categories_insert_own"
on public.categories
for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "categories_update_own" on public.categories;
create policy "categories_update_own"
on public.categories
for update
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null)
with check (user_id = (select auth.uid()));

-- transactions
drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own"
on public.transactions
for select
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null);

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own"
on public.transactions
for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own"
on public.transactions
for update
to authenticated
using (user_id = (select auth.uid()) and deleted_at is null)
with check (user_id = (select auth.uid()));
