-- v0.18 — Conta de demonstração demo@frisk.pt (password pública "demo2026"; dados fictícios).
-- A conta é criada no Supabase (auth), não neste ficheiro. Todas as noites (03:30 UTC) volta ao início: dados, agregado, empresa,
-- chat e palavra-passe. Não pode convidar ninguém (para não mandar convites a contas reais).

-- as mensagens escondidas (reposição da demo) deixam de aparecer; nada se apaga
alter table public.agregado_mensagens add column if not exists oculta boolean not null default false;

create table if not exists public.demo_seed (chave text primary key, dados jsonb not null);
alter table public.demo_seed enable row level security; -- sem políticas: ninguém lê diretamente

create or replace function public.demo_uid() returns uuid language sql stable security definer set search_path = '' as $$
  select id from auth.users where lower(email) = 'demo@frisk.pt' limit 1
$$;
revoke execute on function public.demo_uid() from public, anon, authenticated;

create or replace function public.demo_repor() returns text language plpgsql security definer set search_path = '' as $$
declare u uuid := public.demo_uid(); ga uuid; ge uuid; agora jsonb := jsonb_build_object('updatedAt', (extract(epoch from now())*1000)::bigint);
begin
  if u is null then return 'sem conta demo'; end if;
  -- agregado e empresa da demo (cria se não existirem)
  select id into ga from public.agregados where dono = u and tipo = 'agregado' and site_id = 'financas' order by created_at limit 1;
  if ga is null then insert into public.agregados(site_id, nome, dono, tipo) values ('financas', 'Família Demo', u, 'agregado') returning id into ga; end if;
  select id into ge from public.agregados where dono = u and tipo = 'empresa' and site_id = 'financas' order by created_at limit 1;
  if ge is null then insert into public.agregados(site_id, nome, dono, tipo) values ('financas', 'Demo, Lda.', u, 'empresa') returning id into ge; end if;
  update public.agregados set apagar_em = null, nome = case when id = ga then 'Família Demo' else 'Demo, Lda.' end where id in (ga, ge);
  insert into public.agregado_membros(agregado_id, user_id, papel) values (ga, u, 'dono'), (ge, u, 'dono') on conflict do nothing;
  -- outros agregados/empresas que a demo tenha criado: marcados para apagar
  update public.agregados set apagar_em = now() where dono = u and id not in (ga, ge) and apagar_em is null;
  -- dados
  insert into public.financas_dados(user_id, ferramenta, chave, dados) select u, 'financas', 'estado', dados || agora from public.demo_seed where chave = 'pessoal'
  on conflict (user_id, ferramenta, chave) do update set dados = excluded.dados, updated_at = now();
  insert into public.agregado_dados(agregado_id, ferramenta, chave, dados, updated_by) select ga, 'financas', 'estado', dados || agora, u from public.demo_seed where chave = 'agregado'
  on conflict (agregado_id, ferramenta, chave) do update set dados = excluded.dados, updated_at = now();
  insert into public.agregado_dados(agregado_id, ferramenta, chave, dados, updated_by) select ge, 'financas', 'estado', dados || agora, u from public.demo_seed where chave = 'empresa'
  on conflict (agregado_id, ferramenta, chave) do update set dados = excluded.dados, updated_at = now();
  -- chat: limpa e deixa duas mensagens de exemplo
  update public.agregado_mensagens set oculta = true where agregado_id in (ga, ge) and not oculta;
  insert into public.agregado_mensagens(agregado_id, user_id, texto, created_at) values
    (ga, u, 'Olá! Este é o chat do agregado — só os membros o veem.', now() - interval '1 hour'),
    (ge, u, 'Chat da empresa: combinem aqui pagamentos, faturas e prazos.', now() - interval '1 hour');
  update public.agregado_convites set estado = 'cancelado', respondido_em = now() where (convidado_por = u or user_id = u) and estado = 'pendente';
  update public.site_bloqueios set ativo = false where user_id = u and ativo;
  -- palavra-passe volta a "demo2026"
  update auth.users set encrypted_password = extensions.crypt('demo2026', extensions.gen_salt('bf')), email = 'demo@frisk.pt', updated_at = now() where id = u;
  return 'ok';
end $$;
revoke execute on function public.demo_repor() from public, anon, authenticated;

-- a demo não convida ninguém
create or replace function public.agregado_convidar(p_agregado uuid, p_email text)
returns text language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); alvo uuid; e text := lower(btrim(p_email));
begin
  if u = public.demo_uid() then return 'demo'; end if;
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

-- o chat não mostra nem conta as mensagens escondidas
create or replace function public.chat_mensagens(p_agregado uuid, p_desde timestamptz default null)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.e_membro_agregado(p_agregado) then raise exception 'sem acesso'; end if;
  return coalesce((select jsonb_agg(x order by x.created_at) from (
    select m.id, m.texto, m.created_at, m.user_id = auth.uid() as eu,
           coalesce(p.nome, split_part(au.email, '@', 1)) as autor
    from public.agregado_mensagens m join auth.users au on au.id = m.user_id left join public.profiles p on p.id = m.user_id
    where m.agregado_id = p_agregado and not m.oculta and (p_desde is null or m.created_at > p_desde)
    order by m.created_at desc limit 200) x), '[]'::jsonb);
end $$;
create or replace function public.chat_por_ler(p_site text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_object_agg(g.id, n), '{}'::jsonb) from (
    select g.id, (select count(*) from public.agregado_mensagens m
                  where m.agregado_id = g.id and m.user_id <> auth.uid() and not m.oculta
                    and m.created_at > coalesce((select l.lido_em from public.agregado_chat_lido l where l.agregado_id = g.id and l.user_id = auth.uid()), mb.created_at)) as n
    from public.agregados g join public.agregado_membros mb on mb.agregado_id = g.id and mb.user_id = auth.uid()
    where g.site_id = p_site and g.apagar_em is null) g
  where g.n > 0
$$;

-- reposição todas as noites (pg_cron)
create extension if not exists pg_cron;
select cron.schedule('demo-repor', '30 3 * * *', 'select public.demo_repor()');
