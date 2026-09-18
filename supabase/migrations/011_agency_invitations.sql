-- Agency owners and hosts can safely accept or reject invitations.
create or replace function public.respond_agency_invitation(target_agency uuid, should_accept boolean)
returns public.agency_hosts language plpgsql security definer set search_path = public as $$
declare result public.agency_hosts;
begin
  if not exists (select 1 from public.agency_hosts where agency_id = target_agency and host_id = auth.uid() and status = 'pending') then raise exception 'Invitation not found'; end if;
  update public.agency_hosts set status = case when should_accept then 'active' else 'rejected' end where agency_id = target_agency and host_id = auth.uid() returning * into result;
  if should_accept then update public.host_profiles set agency_name = (select name from public.agencies where id = target_agency), updated_at = now() where user_id = auth.uid(); end if;
  return result;
end;
$$;
revoke all on function public.respond_agency_invitation(uuid, boolean) from public, anon;
grant execute on function public.respond_agency_invitation(uuid, boolean) to authenticated;