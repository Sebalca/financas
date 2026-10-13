-- v0.18 — Limite de movimentos importados por mês (mov_mes) e alertas de limites para o admin.
update public.site_config set limites = limites || '{"mov_mes":500}'::jsonb where site_id = 'financas' and not (limites ? 'mov_mes');

create table if not exists public.site_alertas (
  id uuid primary key default gen_random_uuid(),
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  tipo text not null check (char_length(tipo) <= 40),
  detalhe jsonb not null default '{}'::jsonb,
  visto boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists site_alertas_site on public.site_alertas(site_id, visto, created_at desc);
alter table public.site_alertas enable row level security; -- sem políticas: só as funções

-- a pessoa (a app) avisa que chegou a um limite; no máximo 1 alerta por pessoa/tipo por hora
create or replace function public.fin_limite_atingido(p_site text, p_tipo text, p_detalhe jsonb default '{}'::jsonb)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null or p_tipo not in ('mov_mes','cats','refs','sug_dia','faq_dia') then return; end if;
  if exists(select 1 from public.site_alertas where user_id = auth.uid() and site_id = p_site and tipo = p_tipo and created_at > now() - interval '1 hour') then return; end if;
  insert into public.site_alertas(site_id, user_id, tipo, detalhe) values (p_site, auth.uid(), p_tipo, coalesce(p_detalhe, '{}'::jsonb) - 'email');
end $$;

create or replace function public.admin_alertas_vistos(p_site text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  update public.site_alertas set visto = true where site_id = p_site and not visto;
end $$;

create or replace function public.admin_alertas(p_site text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('email', au.email, 'tipo', a.tipo, 'detalhe', a.detalhe, 'visto', a.visto, 'created_at', a.created_at) order by a.created_at desc)
    from (select * from public.site_alertas where site_id = p_site order by created_at desc limit 100) a join auth.users au on au.id = a.user_id), '[]'::jsonb);
end $$;

create or replace function public.fin_estado(p_site text default 'financas')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare u uuid := auth.uid(); adm boolean; tem boolean; b record;
begin
  if u is null then return '{}'::jsonb; end if;
  adm := public.e_admin_site(p_site);
  select * into b from public.site_bloqueios where site_id = p_site and user_id = u and ativo;
  tem := exists(select 1 from public.financas_dados where user_id = u and ferramenta = 'financas')
      or exists(select 1 from public.agregado_membros m join public.agregados g on g.id = m.agregado_id where m.user_id = u and g.site_id = p_site);
  return jsonb_build_object(
    'bloqueado', b.user_id is not null and not adm, 'motivo', b.motivo,
    'registos_fechados', not adm and not tem and not public.fin_registos_abertos(p_site),
    'limites', public.fin_limites(p_site, u),
    'avisos', coalesce((select jsonb_agg(jsonb_build_object('id', a.id, 'texto', a.texto, 'created_at', a.created_at, 'privado', a.user_id is not null) order by a.created_at)
       from public.site_avisos a where a.site_id = p_site and not a.apagado and (a.user_id is null or a.user_id = u)
         and a.created_at > (select au.created_at - interval '1 day' from auth.users au where au.id = u)
         and not exists(select 1 from public.site_avisos_lidos l where l.aviso_id = a.id and l.user_id = u)), '[]'::jsonb),
    'novos', case when adm then (select count(*) from auth.users au where au.created_at > coalesce((select contas_vistas_em from public.site_admins where site_id = p_site and user_id = u), now() - interval '7 days')) else 0 end,
    'alertas', case when adm then (select count(*) from public.site_alertas where site_id = p_site and not visto) else 0 end,
    'demo', lower(coalesce((select email from auth.users where id = u), '')) = 'demo@frisk.pt');
end $$;

do $$ declare f text; begin
  foreach f in array array['fin_limite_atingido(text,text,jsonb)','admin_alertas_vistos(text)','admin_alertas(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;
