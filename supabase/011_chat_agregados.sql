-- v0.14 — Chat nos agregados e nas empresas (só os membros que aceitaram o convite — D98).
-- As mensagens leem-se e escrevem-se só pelas funções abaixo (security definer, verificam se é membro).

create table if not exists public.agregado_mensagens (
  id uuid primary key default gen_random_uuid(),
  agregado_id uuid not null references public.agregados(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  texto text not null check (char_length(btrim(texto)) between 1 and 2000),
  created_at timestamptz not null default now()
);
create index if not exists agregado_mensagens_agr on public.agregado_mensagens(agregado_id, created_at);
create table if not exists public.agregado_chat_lido (
  agregado_id uuid not null references public.agregados(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  lido_em timestamptz not null default now(),
  primary key (agregado_id, user_id)
);
alter table public.agregado_mensagens enable row level security;
alter table public.agregado_chat_lido enable row level security;
create policy "agregado_mensagens: membros leem" on public.agregado_mensagens for select to authenticated using (public.e_membro_agregado(agregado_id));
-- sem políticas de escrita: só chat_enviar

-- mensagens (as últimas 200, ou as depois de p_desde)
create or replace function public.chat_mensagens(p_agregado uuid, p_desde timestamptz default null)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.e_membro_agregado(p_agregado) then raise exception 'sem acesso'; end if;
  return coalesce((select jsonb_agg(x order by x.created_at) from (
    select m.id, m.texto, m.created_at, m.user_id = auth.uid() as eu,
           coalesce(p.nome, split_part(au.email, '@', 1)) as autor
    from public.agregado_mensagens m join auth.users au on au.id = m.user_id left join public.profiles p on p.id = m.user_id
    where m.agregado_id = p_agregado and (p_desde is null or m.created_at > p_desde)
    order by m.created_at desc limit 200) x), '[]'::jsonb);
end $$;

create or replace function public.chat_enviar(p_agregado uuid, p_texto text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare r public.agregado_mensagens;
begin
  if not public.e_membro_agregado(p_agregado) then raise exception 'sem acesso'; end if;
  if public.fin_bloqueado('financas') then raise exception 'conta bloqueada'; end if;
  if (select count(*) from public.agregado_mensagens where user_id = auth.uid() and created_at > now() - interval '1 minute') >= 20 then
    raise exception 'Demasiadas mensagens, espere um pouco.';
  end if;
  insert into public.agregado_mensagens(agregado_id, user_id, texto) values (p_agregado, auth.uid(), btrim(p_texto)) returning * into r;
  insert into public.agregado_chat_lido(agregado_id, user_id, lido_em) values (p_agregado, auth.uid(), now())
  on conflict (agregado_id, user_id) do update set lido_em = now();
  return jsonb_build_object('id', r.id, 'created_at', r.created_at);
end $$;

create or replace function public.chat_lido(p_agregado uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if not public.e_membro_agregado(p_agregado) then return; end if;
  insert into public.agregado_chat_lido(agregado_id, user_id, lido_em) values (p_agregado, auth.uid(), now())
  on conflict (agregado_id, user_id) do update set lido_em = now();
end $$;

-- por ler em cada agregado/empresa meu neste site: {"<id>": n}
create or replace function public.chat_por_ler(p_site text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_object_agg(g.id, n), '{}'::jsonb) from (
    select g.id, (select count(*) from public.agregado_mensagens m
                  where m.agregado_id = g.id and m.user_id <> auth.uid()
                    and m.created_at > coalesce((select l.lido_em from public.agregado_chat_lido l where l.agregado_id = g.id and l.user_id = auth.uid()), mb.created_at)) as n
    from public.agregados g join public.agregado_membros mb on mb.agregado_id = g.id and mb.user_id = auth.uid()
    where g.site_id = p_site and g.apagar_em is null) g
  where g.n > 0
$$;

do $$ declare f text; begin
  foreach f in array array['chat_mensagens(uuid,timestamptz)','chat_enviar(uuid,text)','chat_lido(uuid)','chat_por_ler(text)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;

-- RGPD (D110): as minhas mensagens entram na exportação
create or replace function public.financas_exportar()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare uid uuid := auth.uid(); r jsonb;
begin
  if uid is null then raise exception 'sem_sessao'; end if;
  select jsonb_build_object(
    'exportado_em', now(), 'site', 'financas',
    'conta', (select jsonb_build_object('email',u.email,'criada_em',u.created_at) from auth.users u where u.id=uid),
    'financas', (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from public.financas_dados x where x.user_id=uid),
    'preferencias', (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from public.user_site_data x where x.user_id=uid and x.site_id='financas'),
    'agregados', (select coalesce(jsonb_agg(jsonb_build_object('agregado',a.nome,'papel',m.papel,'desde',m.created_at,'dono',a.dono=uid,'dados',(select coalesce(jsonb_agg(d.dados),'[]') from public.agregado_dados d where d.agregado_id=a.id))),'[]')
                  from public.agregado_membros m join public.agregados a on a.id=m.agregado_id where m.user_id=uid and a.site_id='financas'),
    'convites', (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from public.agregado_convites x join public.agregados a on a.id=x.agregado_id where a.site_id='financas' and (x.user_id=uid or x.convidado_por=uid)),
    'mensagens_chat', (select coalesce(jsonb_agg(jsonb_build_object('agregado',a.nome,'texto',x.texto,'em',x.created_at)),'[]') from public.agregado_mensagens x join public.agregados a on a.id=x.agregado_id where x.user_id=uid and a.site_id='financas'),
    'sugestoes', (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from public.sugestoes x where x.user_id=uid and x.site_id='financas'),
    'perguntas_faq', (select coalesce(jsonb_agg(to_jsonb(x)),'[]') from public.faq_perguntas x where x.user_id=uid and x.site_id='financas'),
    'estatisticas_de_uso', (select coalesce(jsonb_agg(jsonb_build_object('tipo',x.tipo,'dados',x.dados,'em',x.created_at)),'[]') from public.site_eventos x where x.user_id=uid and x.site_id='financas')
  ) into r;
  return r;
end $$;
