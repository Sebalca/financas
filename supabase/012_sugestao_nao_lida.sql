-- v0.16 — Marcar uma sugestão como "não lida" (volta a aparecer o aviso).
-- p_como: 'admin' (lista do admin: por_ler) ou 'autor' (as minhas sugestões: por_ler_user). Cada um só mexe no seu lado.
create or replace function public.sugestao_nao_lida(p_sugestao uuid, p_como text)
returns void language plpgsql security definer set search_path = '' as $$
declare s record;
begin
  select * into s from public.sugestoes where id = p_sugestao;
  if s.id is null then return; end if;
  if p_como = 'autor' and s.user_id = auth.uid() then update public.sugestoes set por_ler_user = true where id = p_sugestao; end if;
  if p_como = 'admin' and public.e_admin_site(s.site_id) then update public.sugestoes set por_ler = true where id = p_sugestao; end if;
end $$;
revoke execute on function public.sugestao_nao_lida(uuid, text) from public, anon;
grant execute on function public.sugestao_nao_lida(uuid, text) to authenticated;
