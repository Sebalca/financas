-- v0.11b — Sugestões em forma de conversa: o admin responde, a pessoa vê a resposta e pode responder de volta;
-- o admin pode terminar (só de leitura) e reabrir. Notificações só no site (por_ler = admin tem mensagens por abrir;
-- por_ler_user = a pessoa tem respostas por abrir).

alter table public.sugestoes add column if not exists fechada boolean not null default false;
alter table public.sugestoes add column if not exists por_ler_user boolean not null default false;
alter table public.sugestoes add column if not exists ultima_em timestamptz not null default now();

-- quem enviou vê as suas sugestões (o resto continua só para os admins do site)

create policy "sugestoes: autor lê" on public.sugestoes for select to authenticated using (user_id = (select auth.uid()));

create table if not exists public.sugestao_mensagens (
  id uuid primary key default gen_random_uuid(),
  sugestao_id uuid not null references public.sugestoes(id) on delete cascade,
  autor uuid default auth.uid() references auth.users(id) on delete set null,
  de_admin boolean not null default false,
  texto text not null check (char_length(texto) between 1 and 4000),
  created_at timestamptz not null default now()
);
create index if not exists sugestao_mensagens_sug on public.sugestao_mensagens(sugestao_id, created_at);
alter table public.sugestao_mensagens enable row level security;

create policy "sugestao_mensagens: autor e admin leem" on public.sugestao_mensagens for select to authenticated
  using (exists(select 1 from public.sugestoes s where s.id = sugestao_id and (s.user_id = (select auth.uid()) or public.e_admin_site(s.site_id))));
-- sem insert/update/delete diretos: só pelas funções abaixo

-- escrever na conversa (admin do site ou quem enviou; quem enviou não escreve se estiver terminada)
create or replace function public.sugestao_responder(p_sugestao uuid, p_texto text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); s record; adm boolean; t text := btrim(coalesce(p_texto,'')); m uuid;
begin
  if u is null then raise exception 'sem sessão'; end if;
  if char_length(t) < 1 or char_length(t) > 4000 then raise exception 'mensagem vazia ou demasiado longa'; end if;
  select * into s from public.sugestoes where id = p_sugestao;
  if s.id is null then raise exception 'sugestão inexistente'; end if;
  adm := public.e_admin_site(s.site_id);
  if not adm and s.user_id is distinct from u then raise exception 'sem acesso'; end if;
  if not adm and s.fechada then raise exception 'conversa terminada'; end if;
  if (select count(*) from public.sugestao_mensagens where autor = u and created_at > now() - interval '1 hour') >= 60 then
    raise exception 'limite de mensagens por hora atingido';
  end if;
  insert into public.sugestao_mensagens(sugestao_id, autor, de_admin, texto) values (p_sugestao, u, adm, t) returning id into m;
  if adm then update public.sugestoes set por_ler_user = true, ultima_em = now() where id = p_sugestao;
  else update public.sugestoes set por_ler = true, ultima_em = now() where id = p_sugestao; end if;
  return m;
end $$;

-- terminar / reabrir (só admin)
create or replace function public.sugestao_fechar(p_sugestao uuid, p_fechar boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare s record;
begin
  select * into s from public.sugestoes where id = p_sugestao;
  if s.id is null or not public.e_admin_site(s.site_id) then raise exception 'só o admin'; end if;
  update public.sugestoes set fechada = p_fechar where id = p_sugestao;
end $$;

-- marcar como lida (quem enviou: respostas; admin: mensagens novas)
create or replace function public.sugestao_lida(p_sugestao uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare u uuid := auth.uid(); s record;
begin
  select * into s from public.sugestoes where id = p_sugestao;
  if s.id is null then return; end if;
  if s.user_id = u then update public.sugestoes set por_ler_user = false where id = p_sugestao; end if;
  if public.e_admin_site(s.site_id) then update public.sugestoes set por_ler = false where id = p_sugestao; end if;
end $$;

do $$ declare f text; begin
  foreach f in array array['sugestao_responder(uuid,text)','sugestao_fechar(uuid,boolean)','sugestao_lida(uuid)'] loop
    execute format('revoke execute on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop; end $$;
