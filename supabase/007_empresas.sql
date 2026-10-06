-- v0.11 — Empresas: contas partilhadas como os agregados (mesmas tabelas, convites e regras de acesso — D98),
-- marcadas com tipo = 'empresa'. Criar empresas só para quem tem a permissão 'criar_empresa' (verificado no servidor).
-- Para abrir a todos: insert into public.permissoes(site_id, permissao, user_id) values ('financas','criar_empresa', null);

alter table public.agregados add column if not exists tipo text not null default 'agregado';
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'agregados_tipo_chk') then
    alter table public.agregados add constraint agregados_tipo_chk check (tipo in ('agregado','empresa'));
  end if;
end $$;

-- permissões por site (user_id null = todos os utilizadores com sessão)
create table if not exists public.permissoes (
  id bigint generated always as identity primary key,
  site_id text not null references public.sites(id) on delete cascade,
  permissao text not null,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create unique index if not exists permissoes_unica on public.permissoes(site_id, permissao, coalesce(user_id, '00000000-0000-0000-0000-000000000000'::uuid));
alter table public.permissoes enable row level security; -- sem políticas: só as funções abaixo a leem

create or replace function public.tem_permissao(p_site text, p_perm text)
returns boolean language sql stable security definer set search_path = '' as $$
  select (select auth.uid()) is not null and exists(select 1 from public.permissoes
    where site_id = p_site and permissao = p_perm and (user_id is null or user_id = (select auth.uid())))
$$;

-- agregado: continua 1 por pessoa (só conta os do tipo agregado)
create or replace function public.agregado_criar(p_site text, p_nome text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); a uuid;
begin
  if u is null then raise exception 'sem sessão'; end if;
  perform public.agregados_limpa();
  if (select count(*) from public.agregados where dono = u and site_id = p_site and tipo = 'agregado' and apagar_em is null) >= 1 then
    raise exception 'já tem um agregado neste site';
  end if;
  insert into public.agregados(site_id, nome, dono, tipo) values (p_site, btrim(p_nome), u, 'agregado') returning id into a;
  insert into public.agregado_membros(agregado_id, user_id, papel) values (a, u, 'dono');
  return a;
end $$;

create or replace function public.empresa_criar(p_site text, p_nome text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); a uuid;
begin
  if u is null then raise exception 'sem sessão'; end if;
  if not public.tem_permissao(p_site, 'criar_empresa') then raise exception 'sem permissão para criar empresas'; end if;
  perform public.agregados_limpa();
  if (select count(*) from public.agregados where dono = u and site_id = p_site and tipo = 'empresa' and apagar_em is null) >= 20 then
    raise exception 'limite de empresas atingido';
  end if;
  insert into public.agregados(site_id, nome, dono, tipo) values (p_site, btrim(p_nome), u, 'empresa') returning id into a;
  insert into public.agregado_membros(agregado_id, user_id, papel) values (a, u, 'dono');
  return a;
end $$;

-- os meus agregados e empresas neste site (agora com o tipo)
create or replace function public.meus_agregados(p_site text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then return '[]'::jsonb; end if;
  perform public.agregados_limpa();
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', g.id, 'nome', g.nome, 'tipo', g.tipo, 'dono', g.dono = u, 'apagar_em', g.apagar_em,
      'membros', (select coalesce(jsonb_agg(jsonb_build_object('user_id', m.user_id, 'papel', m.papel, 'email', au.email,
                    'nome', coalesce(p.nome, split_part(au.email, '@', 1)), 'eu', m.user_id = u) order by m.papel <> 'dono', m.created_at), '[]'::jsonb)
                  from public.agregado_membros m join auth.users au on au.id = m.user_id left join public.profiles p on p.id = m.user_id
                  where m.agregado_id = g.id),
      'convites', case when g.dono = u then (select coalesce(jsonb_agg(jsonb_build_object('id', c.id, 'email', c.email, 'created_at', c.created_at) order by c.created_at), '[]'::jsonb)
                  from public.agregado_convites c where c.agregado_id = g.id and c.estado = 'pendente') else '[]'::jsonb end
    ) order by g.created_at)
    from public.agregados g
    where g.site_id = p_site and ((g.apagar_em is null and exists(select 1 from public.agregado_membros m where m.agregado_id = g.id and m.user_id = u))
                                  or (g.apagar_em is not null and g.dono = u))), '[]'::jsonb);
end $$;

create or replace function public.meus_convites(p_site text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', c.id, 'agregado', g.nome, 'tipo', g.tipo, 'de_email', au.email,
           'de_nome', coalesce(p.nome, split_part(au.email, '@', 1)), 'created_at', c.created_at) order by c.created_at), '[]'::jsonb)
  from public.agregado_convites c join public.agregados g on g.id = c.agregado_id
       join auth.users au on au.id = c.convidado_por left join public.profiles p on p.id = c.convidado_por
  where c.user_id = (select auth.uid()) and c.estado = 'pendente' and g.site_id = p_site and g.apagar_em is null
$$;

do $$ declare f text; begin
  foreach f in array array['tem_permissao(text,text)','empresa_criar(text,text)','agregado_criar(text,text)','meus_agregados(text)','meus_convites(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;

-- quem pode criar empresas é inserido à parte (não fica no repositório):
--   insert into public.permissoes(site_id, permissao, user_id) values ('financas','criar_empresa','<user_id>');
