-- Persistent event-driven task and achievement progress.
alter table public.user_achievements add column if not exists progress integer not null default 0;
create index if not exists daily_task_progress_user_date_idx on public.daily_task_progress(user_id, task_date);

create or replace function public.record_user_activity(event_code text)
returns void language plpgsql security definer set search_path = public as $$
declare actor uuid := auth.uid(); task_row public.daily_tasks; achievement_row public.achievements; current_progress integer; target_progress integer;
begin
  if actor is null then raise exception 'Authentication required'; end if;
  update public.profiles set active_xp = active_xp + 1, updated_at = now() where id = actor;
  for task_row in select * from public.daily_tasks where active and code = event_code loop
    insert into public.daily_task_progress(user_id, task_id, task_date, progress) values (actor, task_row.id, current_date, 1) on conflict (user_id, task_id, task_date) do update set progress = least(public.daily_task_progress.progress + 1, task_row.target);
  end loop;
  for achievement_row in select * from public.achievements where code = event_code loop
    insert into public.user_achievements(user_id, achievement_id, progress) values (actor, achievement_row.id, 1) on conflict (user_id, achievement_id) do update set progress = least(public.user_achievements.progress + 1, achievement_row.target);
  end loop;
end;
$$;
revoke all on function public.record_user_activity(text) from public, anon;
grant execute on function public.record_user_activity(text) to authenticated;

create or replace function public.claim_achievement_reward(target_achievement uuid)
returns public.user_achievements language plpgsql security definer set search_path = public as $$
declare claimant uuid := auth.uid(); achievement public.achievements; result public.user_achievements;
begin
  select * into achievement from public.achievements where id = target_achievement;
  select * into result from public.user_achievements where user_id = claimant and achievement_id = target_achievement for update;
  if achievement.id is null or result.user_id is null or result.progress < achievement.target then raise exception 'Achievement is not complete'; end if;
  if result.claimed_at is not null then return result; end if;
  update public.wallets set balance = balance + achievement.reward_coins, updated_at = now() where user_id = claimant;
  insert into public.wallet_transactions(wallet_id, type, amount, description) select id, 'adjustment', achievement.reward_coins, 'Achievement reward' from public.wallets where user_id = claimant;
  update public.user_achievements set claimed_at = now() where user_id = claimant and achievement_id = target_achievement returning * into result;
  return result;
end;
$$;
revoke all on function public.claim_achievement_reward(uuid) from public, anon;
grant execute on function public.claim_achievement_reward(uuid) to authenticated;