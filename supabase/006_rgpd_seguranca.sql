-- v0.10d — Segurança (aplicado: migração "seguranca_v010d") e RGPD (exportar: aplicado em "rgpd_exportar"; apagar conta: ver abaixo)

-- ===== Segurança =====
-- funções de trigger: ninguém as chama pela API (os triggers continuam a funcionar)
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function parkncharge.listings_guard() from public, anon, authenticated;
revoke execute on function parkncharge.photos_cover() from public, anon, authenticated;
revoke execute on function parkncharge.photos_limit() from public, anon, authenticated;
revoke execute on function parkncharge.sync_approx_location() from public, anon, authenticated;
alter function public.handle_new_user() set search_path = '';
alter function public.shares_completion_access(uuid,uuid) set search_path = '';
alter policy "ver todos os membros e convites da subcategoria partilhada comi" on public.subcategory_shares to authenticated;
revoke execute on function public.is_member_of_subcategory_share(uuid) from public, anon;
grant execute on function public.is_member_of_subcategory_share(uuid) to authenticated;
revoke execute on function public.promo_current_user_allowed() from public, anon;
grant execute on function public.promo_current_user_allowed() to authenticated;
revoke execute on function parkncharge.owns_listing(uuid) from public, anon;
grant execute on function parkncharge.owns_listing(uuid) to authenticated;
-- Ficam de propósito executáveis por anon: parkncharge.is_admin() e e_admin_site(text) (usadas em políticas de leitura pública; só dizem se QUEM PERGUNTA é admin)
-- e promo_is_allowed(text) (verificação antes do login no site de promoção).
-- As restantes funções security definer com execute para authenticated são as RPC da plataforma (agregados, admin_stats…): cada uma verifica auth.uid().

-- ===== RGPD: exportar (aplicado) =====
-- public.minha_conta_exportar() → jsonb com conta, perfil, finanças, dados dos sites, conquistas, partilhas, promoção, agregados (+dados), convites,
-- sugestões, perguntas, estatísticas de uso e parkncharge. Ver: select pg_get_functiondef('public.minha_conta_exportar()'::regprocedure);

-- ===== RGPD: apagar a conta — CORRER NO EDITOR SQL DO SUPABASE (o assistente não conseguiu aplicar) =====
create or replace function public.apagar_minha_conta(p_confirma text)
returns text language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid(); em text; a record; novo uuid;
begin
  if uid is null then raise exception 'sem_sessao'; end if;
  select email into em from auth.users where id=uid;
  if lower(trim(coalesce(p_confirma,''))) <> lower(coalesce(em,'')) then raise exception 'confirmacao'; end if;
  -- agregados de que é dono: passam para o membro mais antigo; sem outros membros, apagam-se em cascata
  for a in select id from public.agregados where dono=uid loop
    select m.user_id into novo from public.agregado_membros m where m.agregado_id=a.id and m.user_id<>uid order by m.created_at limit 1;
    if novo is not null then
      update public.agregados set dono=novo where id=a.id;
      update public.agregado_membros set papel='dono' where agregado_id=a.id and user_id=novo;
    end if;
  end loop;
  -- ligações sem "on delete cascade"
  delete from public.goal_completions where user_id=uid;
  delete from public.subcategory_shares where owner_id=uid or invited_user_id=uid;
  update parkncharge.listings set approved_by=null where approved_by=uid;
  update public.site_shared_items set created_by=null where created_by=uid;
  delete from public.sugestoes where user_id=uid;
  delete from public.faq_perguntas where user_id=uid and not publica;
  -- o resto apaga-se em cascata (perfil, finanças, dados dos sites, eventos, parkncharge…)
  delete from auth.users where id=uid;
  return 'ok';
end $$;
revoke execute on function public.apagar_minha_conta(text) from public, anon;
grant execute on function public.apagar_minha_conta(text) to authenticated;
-- Nota: ficheiros no Storage (fotos do parkncharge) não são apagados por esta função.
