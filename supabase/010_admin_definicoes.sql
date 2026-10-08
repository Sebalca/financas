-- v0.12 — Definições do admin (só para as Finanças): registos abertos/fechados, limites (gerais + por pessoa),
-- contas bloqueadas, avisos (gerais ou para uma pessoa) e aviso de contas novas para o admin.
-- Tudo verificado no servidor: as tabelas não têm políticas de escrita; só as funções security definer mexem nelas.

create table if not exists public.site_config (
  site_id text primary key references public.sites(id) on delete cascade,
  registos_abertos boolean not null default true,
  limites jsonb not null default '{"sug_dia":10,"faq_dia":10,"cats":40,"refs":300}'::jsonb,
  atualizado_em timestamptz not null default now()
);
insert into public.site_config(site_id) values ('financas') on conflict do nothing;

create table if not exists public.site_limites_user (
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  limites jsonb not null default '{}'::jsonb,
  primary key (site_id, user_id)
);
create table if not exists public.site_bloqueios (
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  motivo text check (motivo is null or char_length(motivo) <= 300),
  created_at timestamptz not null default now(),
  primary key (site_id, user_id)
);
create table if not exists public.site_avisos (
  id uuid primary key default gen_random_uuid(),
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,   -- null = para todos
  texto text not null check (char_length(texto) between 1 and 2000),
  created_at timestamptz not null default now()
);
create table if not exists public.site_avisos_lidos (
  aviso_id uuid not null references public.site_avisos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  lido_em timestamptz not null default now(),
  primary key (aviso_id, user_id)
);
alter table public.site_admins add column if not exists contas_vistas_em timestamptz;
alter table public.site_config enable row level security;
alter table public.site_limites_user enable row level security;
alter table public.site_bloqueios enable row level security;
alter table public.site_avisos enable row level security;
alter table public.site_avisos_lidos enable row level security;
-- sem políticas: só as funções abaixo

create or replace function public.fin_bloqueado(p_site text default 'financas')
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.site_bloqueios b where b.site_id = p_site and b.user_id = (select auth.uid()))
$$;
create or replace function public.fin_limites(p_site text, p_user uuid)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce((select limites from public.site_config where site_id = p_site), '{}'::jsonb)
      || coalesce((select limites from public.site_limites_user where site_id = p_site and user_id = p_user), '{}'::jsonb)
$$;
create or replace function public.fin_registos_abertos(p_site text default 'financas')
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce((select registos_abertos from public.site_config where site_id = p_site), true)
$$;

-- conta bloqueada: não lê nem grava os dados das Finanças (pessoais e de agregados/empresas)
create policy "financas: conta bloqueada" on public.financas_dados as restrictive for all to authenticated
  using (ferramenta <> 'financas' or not public.fin_bloqueado('financas')) with check (ferramenta <> 'financas' or not public.fin_bloqueado('financas'));
create policy "agregado_dados: conta bloqueada" on public.agregado_dados as restrictive for all to authenticated
  using (ferramenta <> 'financas' or not public.fin_bloqueado('financas')) with check (ferramenta <> 'financas' or not public.fin_bloqueado('financas'));
-- registos fechados: contas novas (sem dados) não começam a usar as Finanças
create policy "financas: registos fechados" on public.financas_dados as restrictive for insert to authenticated
  with check (ferramenta <> 'financas' or public.fin_registos_abertos('financas') or public.e_admin_site('financas'));

-- (parte 2: sem DELETE — desbloquear/apagar avisos marcam colunas)
alter table public.site_bloqueios add column if not exists ativo boolean not null default true;
alter table public.site_avisos add column if not exists apagado boolean not null default false;
create or replace function public.fin_bloqueado(p_site text default 'financas')
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.site_bloqueios b where b.site_id = p_site and b.user_id = (select auth.uid()) and b.ativo)
$$;
-- estado da pessoa ao entrar
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
    'novos', case when adm then (select count(*) from auth.users au where au.created_at > coalesce((select contas_vistas_em from public.site_admins where site_id = p_site and user_id = u), now() - interval '7 days')) else 0 end);
end $$;

create or replace function public.fin_aviso_lido(p_aviso uuid)
returns void language sql security definer set search_path = '' as $$
  insert into public.site_avisos_lidos(aviso_id, user_id)
  select p_aviso, auth.uid() where auth.uid() is not null and exists(select 1 from public.site_avisos a where a.id = p_aviso and (a.user_id is null or a.user_id = auth.uid()))
  on conflict do nothing
$$;

-- ---------- admin ----------
create or replace function public.admin_cfg(p_site text)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  return jsonb_build_object(
    'registos_abertos', public.fin_registos_abertos(p_site),
    'limites', coalesce((select limites from public.site_config where site_id = p_site), '{}'::jsonb),
    'excecoes', coalesce((select jsonb_agg(jsonb_build_object('email', au.email, 'limites', l.limites) order by au.email) from public.site_limites_user l join auth.users au on au.id = l.user_id where l.site_id = p_site and l.limites <> '{}'::jsonb), '[]'::jsonb),
    'bloqueios', coalesce((select jsonb_agg(jsonb_build_object('email', au.email, 'motivo', b.motivo, 'created_at', b.created_at) order by b.created_at desc) from public.site_bloqueios b join auth.users au on au.id = b.user_id where b.site_id = p_site and b.ativo), '[]'::jsonb),
    'avisos', coalesce((select jsonb_agg(jsonb_build_object('id', a.id, 'texto', a.texto, 'email', au.email, 'created_at', a.created_at,
                 'lidos', (select count(*) from public.site_avisos_lidos l where l.aviso_id = a.id)) order by a.created_at desc)
               from public.site_avisos a left join auth.users au on au.id = a.user_id where a.site_id = p_site and not a.apagado), '[]'::jsonb),
    'novos', coalesce((select jsonb_agg(jsonb_build_object('email', au.email, 'created_at', au.created_at) order by au.created_at desc)
               from auth.users au where au.created_at > coalesce((select contas_vistas_em from public.site_admins where site_id = p_site and user_id = auth.uid()), now() - interval '7 days')), '[]'::jsonb));
end $$;

create or replace function public.admin_cfg_gravar(p_site text, p_registos boolean, p_limites jsonb)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  insert into public.site_config(site_id, registos_abertos, limites, atualizado_em) values (p_site, p_registos, coalesce(p_limites, '{}'::jsonb), now())
  on conflict (site_id) do update set registos_abertos = excluded.registos_abertos, limites = excluded.limites, atualizado_em = now();
end $$;

-- devolve 'ok' | 'sem_conta'
create or replace function public.admin_limite_user(p_site text, p_email text, p_limites jsonb)
returns text language plpgsql security definer set search_path = '' as $$
declare alvo uuid;
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  select id into alvo from auth.users where lower(email) = lower(btrim(p_email)) limit 1;
  if alvo is null then return 'sem_conta'; end if;
  insert into public.site_limites_user(site_id, user_id, limites) values (p_site, alvo, coalesce(p_limites, '{}'::jsonb)) on conflict (site_id, user_id) do update set limites = excluded.limites;
  return 'ok';
end $$;

create or replace function public.admin_bloquear(p_site text, p_email text, p_bloquear boolean, p_motivo text)
returns text language plpgsql security definer set search_path = '' as $$
declare alvo uuid;
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  select id into alvo from auth.users where lower(email) = lower(btrim(p_email)) limit 1;
  if alvo is null then return 'sem_conta'; end if;
  if alvo = auth.uid() then return 'proprio'; end if;
  insert into public.site_bloqueios(site_id, user_id, motivo, ativo, created_at) values (p_site, alvo, nullif(btrim(coalesce(p_motivo,'')),''), p_bloquear, now())
  on conflict (site_id, user_id) do update set motivo = excluded.motivo, ativo = excluded.ativo, created_at = now();
  return 'ok';
end $$;

-- p_email null = aviso geral
create or replace function public.admin_aviso(p_site text, p_email text, p_texto text)
returns text language plpgsql security definer set search_path = '' as $$
declare alvo uuid;
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  if nullif(btrim(coalesce(p_email,'')),'') is not null then
    select id into alvo from auth.users where lower(email) = lower(btrim(p_email)) limit 1;
    if alvo is null then return 'sem_conta'; end if;
  end if;
  insert into public.site_avisos(site_id, user_id, texto) values (p_site, alvo, btrim(p_texto));
  return 'ok';
end $$;

create or replace function public.admin_aviso_apagar(p_site text, p_aviso uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  update public.site_avisos set apagado = true where id = p_aviso and site_id = p_site;
end $$;

create or replace function public.admin_novos_vistos(p_site text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_admin_site(p_site) then raise exception 'só admin'; end if;
  update public.site_admins set contas_vistas_em = now() where site_id = p_site and user_id = auth.uid();
end $$;

-- limites das sugestões e das perguntas (por pessoa e por dia)
create or replace function public.sugestoes_antes()
returns trigger language plpgsql security definer set search_path = '' as $$
declare lim int;
begin
  if (select count(*) from public.sugestoes s where s.site_id = new.site_id and s.created_at > now() - interval '1 hour') >= 60 then
    raise exception 'Demasiadas sugestões, tente mais tarde.';
  end if;
  if new.user_id is not null and not public.e_admin_site(new.site_id) then
    lim := coalesce((public.fin_limites(new.site_id, new.user_id)->>'sug_dia')::int, 10);
    if (select count(*) from public.sugestoes s where s.user_id = new.user_id and s.site_id = new.site_id and s.created_at > now() - interval '24 hours') >= lim then
      raise exception 'Limite de sugestões atingido (% por dia).', lim;
    end if;
  end if;
  return new;
end $$;

create or replace function public.faq_antes()
returns trigger language plpgsql security definer set search_path = '' as $$
declare lim int;
begin
  new.updated_at := now();
  if tg_op = 'INSERT' and not public.e_admin_site(new.site_id) then
    lim := coalesce((public.fin_limites(new.site_id, new.user_id)->>'faq_dia')::int, 10);
    if (select count(*) from public.faq_perguntas p where p.user_id = new.user_id and p.created_at > now() - interval '24 hours') >= lim then
      raise exception 'Limite de perguntas atingido (% por dia).', lim;
    end if;
  end if;
  if tg_op = 'UPDATE' and new.resposta is not null and new.estado = 'respondida' and old.respondida_em is null then
    new.respondida_em := now();
  end if;
  return new;
end $$;

do $$ declare f text; begin
  foreach f in array array['fin_estado(text)','fin_aviso_lido(uuid)','admin_cfg(text)','admin_cfg_gravar(text,boolean,jsonb)','admin_limite_user(text,text,jsonb)',
    'admin_bloquear(text,text,boolean,text)','admin_aviso(text,text,text)','admin_aviso_apagar(text,uuid)','admin_novos_vistos(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
  foreach f in array array['fin_bloqueado(text)','fin_limites(text,uuid)','fin_registos_abertos(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;
