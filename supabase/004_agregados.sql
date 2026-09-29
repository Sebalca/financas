-- v0.9c — Agregados (contas partilhadas entre utilizadores), reutilizáveis por outros sites via site_id.
-- Aplicado no projeto Sites via migração "agregados".
-- Regra (D98): a conta pessoal continua só do próprio (financas_dados não muda);
-- os dados de um agregado vivem em agregado_dados e só os membros os leem/alteram.
-- Escrita nas tabelas de gestão só através das funções abaixo (security definer).

create table if not exists public.agregados (
  id uuid primary key default gen_random_uuid(),
  site_id text not null references public.sites(id) on delete cascade,
  nome text not null check (char_length(btrim(nome)) between 1 and 80),
  dono uuid not null references auth.users(id) on delete cascade,
  apagar_em timestamptz,               -- apagado pelo dono: fica 30 dias para poder restaurar
  created_at timestamptz not null default now()
);
create index if not exists agregados_dono on public.agregados(dono);

create table if not exists public.agregado_membros (
  agregado_id uuid not null references public.agregados(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  papel text not null default 'editor' check (papel in ('dono','editor')),
  created_at timestamptz not null default now(),
  primary key (agregado_id, user_id)
);
create index if not exists agregado_membros_user on public.agregado_membros(user_id);

create table if not exists public.agregado_convites (
  id uuid primary key default gen_random_uuid(),
  agregado_id uuid not null references public.agregados(id) on delete cascade,
  email text not null,
  user_id uuid not null references auth.users(id) on delete cascade,   -- conta convidada (tem de existir)
  convidado_por uuid not null references auth.users(id) on delete cascade,
  estado text not null default 'pendente' check (estado in ('pendente','aceite','recusado','cancelado')),
  created_at timestamptz not null default now(),
  respondido_em timestamptz
);
create index if not exists agregado_convites_user on public.agregado_convites(user_id, estado);
create unique index if not exists agregado_convites_um_pendente on public.agregado_convites(agregado_id, user_id) where estado = 'pendente';

create table if not exists public.agregado_dados (
  agregado_id uuid not null references public.agregados(id) on delete cascade,
  ferramenta text not null,
  chave text not null default 'estado',
  dados jsonb not null default '{}'::jsonb,
  updated_by uuid default auth.uid() references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (agregado_id, ferramenta, chave)
);

-- ---------- auxiliares ----------
create or replace function public.e_membro_agregado(a uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.agregado_membros m join public.agregados g on g.id = m.agregado_id
                where m.agregado_id = a and m.user_id = (select auth.uid()) and g.apagar_em is null)
$$;
create or replace function public.e_dono_agregado(a uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.agregados g where g.id = a and g.dono = (select auth.uid()))
$$;

create or replace function public.agregado_dados_updated_at() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at := now(); new.updated_by := auth.uid(); return new; end $$;
drop trigger if exists agregado_dados_updated_at on public.agregado_dados;
create trigger agregado_dados_updated_at before update on public.agregado_dados for each row execute function public.agregado_dados_updated_at();

-- ---------- RLS ----------
alter table public.agregados enable row level security;
alter table public.agregado_membros enable row level security;
alter table public.agregado_convites enable row level security;
alter table public.agregado_dados enable row level security;

create policy "agregados: membros veem; dono vê os apagados" on public.agregados for select to authenticated
  using (public.e_membro_agregado(id) or dono = (select auth.uid()));
create policy "agregado_membros: membros veem os do mesmo agregado" on public.agregado_membros for select to authenticated
  using (public.e_membro_agregado(agregado_id));
create policy "agregado_convites: o convidado e o dono veem" on public.agregado_convites for select to authenticated
  using (user_id = (select auth.uid()) or public.e_dono_agregado(agregado_id));
create policy "agregado_dados: membros leem" on public.agregado_dados for select to authenticated using (public.e_membro_agregado(agregado_id));
create policy "agregado_dados: membros criam" on public.agregado_dados for insert to authenticated with check (public.e_membro_agregado(agregado_id));
create policy "agregado_dados: membros alteram" on public.agregado_dados for update to authenticated
  using (public.e_membro_agregado(agregado_id)) with check (public.e_membro_agregado(agregado_id));
-- sem insert/update/delete diretos em agregados, membros e convites: só pelas funções

-- ---------- funções (RPC) ----------
create or replace function public.agregados_limpa() returns void language sql security definer set search_path = '' as $$
  delete from public.agregados where apagar_em is not null and apagar_em < now()
$$;

create or replace function public.agregado_criar(p_site text, p_nome text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); a uuid;
begin
  if u is null then raise exception 'sem sessão'; end if;
  perform public.agregados_limpa();
  if (select count(*) from public.agregados where dono = u and site_id = p_site and apagar_em is null) >= 1 then
    raise exception 'já tem um agregado neste site';
  end if;
  insert into public.agregados(site_id, nome, dono) values (p_site, btrim(p_nome), u) returning id into a;
  insert into public.agregado_membros(agregado_id, user_id, papel) values (a, u, 'dono');
  return a;
end $$;

create or replace function public.agregado_renomear(p_agregado uuid, p_nome text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_dono_agregado(p_agregado) then raise exception 'só o dono'; end if;
  update public.agregados set nome = btrim(p_nome) where id = p_agregado;
end $$;

-- devolve: 'ok' | 'sem_conta' | 'ja_membro' | 'ja_convidado' | 'proprio' | 'limite'
create or replace function public.agregado_convidar(p_agregado uuid, p_email text)
returns text language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); alvo uuid; e text := lower(btrim(p_email));
begin
  if not public.e_dono_agregado(p_agregado) or not public.e_membro_agregado(p_agregado) then raise exception 'só o dono'; end if;
  if (select count(*) from public.agregado_convites where convidado_por = u and created_at > now() - interval '1 day') >= 20 then return 'limite'; end if;
  select id into alvo from auth.users where lower(email) = e limit 1;
  if alvo is null then return 'sem_conta'; end if;
  if alvo = u then return 'proprio'; end if;
  if exists(select 1 from public.agregado_membros where agregado_id = p_agregado and user_id = alvo) then return 'ja_membro'; end if;
  if exists(select 1 from public.agregado_convites where agregado_id = p_agregado and user_id = alvo and estado = 'pendente') then return 'ja_convidado'; end if;
  insert into public.agregado_convites(agregado_id, email, user_id, convidado_por) values (p_agregado, e, alvo, u);
  return 'ok';
end $$;

create or replace function public.agregado_cancelar_convite(p_convite uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare a uuid;
begin
  select agregado_id into a from public.agregado_convites where id = p_convite and estado = 'pendente';
  if a is null or not public.e_dono_agregado(a) then raise exception 'convite inválido'; end if;
  update public.agregado_convites set estado = 'cancelado', respondido_em = now() where id = p_convite;
end $$;

create or replace function public.agregado_responder(p_convite uuid, p_aceitar boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare c record;
begin
  select * into c from public.agregado_convites where id = p_convite and user_id = auth.uid() and estado = 'pendente';
  if c.id is null then raise exception 'convite inválido'; end if;
  if not exists(select 1 from public.agregados where id = c.agregado_id and apagar_em is null) then raise exception 'agregado apagado'; end if;
  update public.agregado_convites set estado = case when p_aceitar then 'aceite' else 'recusado' end, respondido_em = now() where id = p_convite;
  if p_aceitar then
    insert into public.agregado_membros(agregado_id, user_id, papel) values (c.agregado_id, c.user_id, 'editor') on conflict do nothing;
  end if;
end $$;

create or replace function public.agregado_sair(p_agregado uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if public.e_dono_agregado(p_agregado) then raise exception 'o dono não pode sair; pode apagar o agregado'; end if;
  delete from public.agregado_membros where agregado_id = p_agregado and user_id = auth.uid();
end $$;

create or replace function public.agregado_remover(p_agregado uuid, p_user uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_dono_agregado(p_agregado) then raise exception 'só o dono'; end if;
  if p_user = auth.uid() then raise exception 'o dono não se pode remover'; end if;
  delete from public.agregado_membros where agregado_id = p_agregado and user_id = p_user;
end $$;

-- apagar: fica 30 dias (só o dono vê e pode restaurar); depois é apagado de vez (com os dados)
create or replace function public.agregado_apagar(p_agregado uuid)
returns timestamptz language plpgsql security definer set search_path = '' as $$
declare t timestamptz := now() + interval '30 days';
begin
  if not public.e_dono_agregado(p_agregado) then raise exception 'só o dono'; end if;
  update public.agregados set apagar_em = t where id = p_agregado;
  update public.agregado_convites set estado = 'cancelado', respondido_em = now() where agregado_id = p_agregado and estado = 'pendente';
  return t;
end $$;

create or replace function public.agregado_restaurar(p_agregado uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_dono_agregado(p_agregado) then raise exception 'só o dono'; end if;
  perform public.agregados_limpa();
  update public.agregados set apagar_em = null where id = p_agregado and apagar_em is not null;
end $$;

-- os meus agregados neste site, com membros (nome/email) e convites pendentes (só para o dono)
create or replace function public.meus_agregados(p_site text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid();
begin
  if u is null then return '[]'::jsonb; end if;
  perform public.agregados_limpa();
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', g.id, 'nome', g.nome, 'dono', g.dono = u, 'apagar_em', g.apagar_em,
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

-- convites pendentes para mim neste site
create or replace function public.meus_convites(p_site text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', c.id, 'agregado', g.nome, 'de_email', au.email,
           'de_nome', coalesce(p.nome, split_part(au.email, '@', 1)), 'created_at', c.created_at) order by c.created_at), '[]'::jsonb)
  from public.agregado_convites c join public.agregados g on g.id = c.agregado_id
       join auth.users au on au.id = c.convidado_por left join public.profiles p on p.id = c.convidado_por
  where c.user_id = (select auth.uid()) and c.estado = 'pendente' and g.site_id = p_site and g.apagar_em is null
$$;

revoke execute on function public.agregados_limpa() from public, anon, authenticated;
revoke execute on function public.agregado_dados_updated_at() from public, anon, authenticated;
do $$ declare f text; begin
  foreach f in array array['e_membro_agregado(uuid)','e_dono_agregado(uuid)','agregado_criar(text,text)','agregado_renomear(uuid,text)',
    'agregado_convidar(uuid,text)','agregado_cancelar_convite(uuid)','agregado_responder(uuid,boolean)','agregado_sair(uuid)',
    'agregado_remover(uuid,uuid)','agregado_apagar(uuid)','agregado_restaurar(uuid)','meus_agregados(text)','meus_convites(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;
