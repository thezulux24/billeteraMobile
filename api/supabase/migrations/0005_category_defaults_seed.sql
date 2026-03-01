-- 0005_category_defaults_seed.sql
-- Seeds default categories per user and keeps them available for transactions.

create or replace function public.seed_default_categories_for_user(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Create defaults if missing.
  insert into public.categories (user_id, name, kind, color, icon, is_system)
  values
    (p_user_id, 'Salary', 'income', '#4ade80', 'payments', true),
    (p_user_id, 'Freelance', 'income', '#22d3ee', 'laptop_mac', true),
    (p_user_id, 'Investments', 'income', '#a855f7', 'trending_up', true),

    (p_user_id, 'Food & Dining', 'expense', '#f87171', 'restaurant', true),
    (p_user_id, 'Transport', 'expense', '#fb923c', 'directions_car', true),
    (p_user_id, 'Shopping', 'expense', '#ec4899', 'shopping_bag', true),
    (p_user_id, 'Utilities', 'expense', '#3b82f6', 'bolt', true),
    (p_user_id, 'Entertainment', 'expense', '#fbbf24', 'movie', true),
    (p_user_id, 'Health', 'expense', '#f43f5e', 'medical_services', true),

    (p_user_id, 'Wallet Transfer', 'transfer', '#94a3b8', 'sync_alt', true),
    (p_user_id, 'Credit Card Payment', 'credit_payment', '#818cf8', 'credit_score', true)
  on conflict (user_id, name, kind) do nothing;

  -- If a default exists but was soft-deleted, restore it.
  with defaults(name, kind) as (
    values
      ('Salary', 'income'),
      ('Freelance', 'income'),
      ('Investments', 'income'),
      ('Food & Dining', 'expense'),
      ('Transport', 'expense'),
      ('Shopping', 'expense'),
      ('Utilities', 'expense'),
      ('Entertainment', 'expense'),
      ('Health', 'expense'),
      ('Wallet Transfer', 'transfer'),
      ('Credit Card Payment', 'credit_payment')
  )
  update public.categories c
     set deleted_at = null,
         is_system = true
    from defaults d
   where c.user_id = p_user_id
     and c.name = d.name
     and c.kind = d.kind
     and c.deleted_at is not null;
end;
$$;

create or replace function public.handle_new_user_categories()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.seed_default_categories_for_user(new.id);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_categories on auth.users;
create trigger on_auth_user_created_categories
after insert on auth.users
for each row execute function public.handle_new_user_categories();

-- Backfill defaults for existing users.
do $$
declare
  v_user_id uuid;
begin
  for v_user_id in
    select u.id from auth.users u
  loop
    perform public.seed_default_categories_for_user(v_user_id);
  end loop;
end;
$$;
