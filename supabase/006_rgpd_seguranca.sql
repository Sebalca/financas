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

-- ===== v0.10e: RGPD só das Finanças =====
-- public.financas_exportar() (aplicado): conta (email), financas_dados, preferências do site, agregados das Finanças (+dados), convites, sugestões, perguntas e estatísticas do site.
-- public.minha_conta_exportar() fica disponível para a plataforma, mas as Finanças já não a usam.

-- Apagar os dados das Finanças (a conta de login continua) — CORRER NO EDITOR SQL DO SUPABASE (o assistente não conseguiu aplicar)
create or replace function public.financas_apagar_dados(p_confirma text)
returns text language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid(); em text; a record; novo uuid;
begin
  if uid is null then raise exception 'sem_sessao'; end if;
  select email into em from auth.users where id=uid;
  if lower(trim(coalesce(p_confirma,''))) <> lower(coalesce(em,'')) then raise exception 'confirmacao'; end if;
  -- agregados de que é dono: passam para o membro mais antigo; sem outros membros, são apagados
  for a in select id from public.agregados where dono=uid and site_id='financas' loop
    select m.user_id into novo from public.agregado_membros m where m.agregado_id=a.id and m.user_id<>uid order by m.created_at limit 1;
    if novo is null then
      delete from public.agregados where id=a.id;
    else
      update public.agregados set dono=novo where id=a.id;
      update public.agregado_membros set papel='dono' where agregado_id=a.id and user_id=novo;
    end if;
  end loop;
  delete from public.agregado_membros where user_id=uid and agregado_id in (select id from public.agregados where site_id='financas');
  delete from public.agregado_convites where (user_id=uid or convidado_por=uid) and agregado_id in (select id from public.agregados where site_id='financas');
  delete from public.financas_dados where user_id=uid;
  delete from public.user_site_data where user_id=uid and site_id='financas';
  delete from public.site_eventos where user_id=uid and site_id='financas';
  delete from public.sugestoes where user_id=uid and site_id='financas';
  delete from public.faq_perguntas where user_id=uid and site_id='financas' and not publica;
  update public.faq_perguntas set user_id=null where user_id=uid and site_id='financas';
  return 'ok';
end $$;
revoke execute on function public.financas_apagar_dados(text) from public, anon;
grant execute on function public.financas_apagar_dados(text) to authenticated;
