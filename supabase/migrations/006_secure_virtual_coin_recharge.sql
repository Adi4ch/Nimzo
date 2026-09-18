-- Server-side demo recharge for virtual coins. No real-money payment is involved.
create or replace function public.recharge_virtual_coins(p_wallet_id uuid, p_amount bigint)
returns public.wallets
language plpgsql
security definer
set search_path = public
as $$
declare
  updated_wallet public.wallets;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  if p_amount <= 0 or p_amount > 1000000 then
    raise exception 'Recharge amount is invalid';
  end if;

  update public.wallets
  set balance = balance + p_amount, updated_at = now()
  where id = p_wallet_id and user_id = auth.uid()
  returning * into updated_wallet;

  if updated_wallet.id is null then
    raise exception 'Wallet not found';
  end if;

  insert into public.wallet_transactions (wallet_id, type, amount, description)
  values (p_wallet_id, 'recharge', p_amount, 'Demo virtual coin recharge');

  return updated_wallet;
end;
$$;

revoke all on function public.recharge_virtual_coins(uuid, bigint) from public;
grant execute on function public.recharge_virtual_coins(uuid, bigint) to authenticated;