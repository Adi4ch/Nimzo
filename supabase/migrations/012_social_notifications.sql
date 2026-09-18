-- Social mutations create notifications inside secure server-side functions.
create or replace function public.follow_user(target_user uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null or auth.uid() = target_user then raise exception 'Invalid follow target'; end if;
  insert into public.post_follows(follower_id, following_id) values (auth.uid(), target_user) on conflict do nothing;
  insert into public.notifications(user_id, actor_id, type, title, body) values (target_user, auth.uid(), 'follow', 'New follower', 'Someone followed you.');
end;
$$;
revoke all on function public.follow_user(uuid) from public, anon;
grant execute on function public.follow_user(uuid) to authenticated;

create or replace function public.add_post_comment(target_post uuid, comment_text text)
returns public.comments language plpgsql security definer set search_path = public as $$
declare result public.comments; owner_id uuid;
begin
  if auth.uid() is null or length(trim(coalesce(comment_text, ''))) = 0 then raise exception 'Invalid comment'; end if;
  insert into public.comments(post_id, user_id, text) values (target_post, auth.uid(), trim(comment_text)) returning * into result;
  select user_id into owner_id from public.social_posts where id = target_post;
  if owner_id is not null and owner_id <> auth.uid() then insert into public.notifications(user_id, actor_id, type, title, body, target_id) values (owner_id, auth.uid(), 'comment', 'New comment', 'Someone commented on your post.', target_post); end if;
  return result;
end;
$$;
revoke all on function public.add_post_comment(uuid, text) from public, anon;
grant execute on function public.add_post_comment(uuid, text) to authenticated;