-- v0.11d — Estado das sugestões para o admin: Recebidas (sem resposta ou última mensagem da pessoa),
-- Em aberto (última mensagem do admin) e Concluídas (fechada). O admin pode mudar a classificação (tipo)
-- pela política de update já existente ("sugestoes: admin marca").
alter table public.sugestoes add column if not exists ultima_de_admin boolean not null default false;
update public.sugestoes s set ultima_de_admin = coalesce((select m.de_admin from public.sugestao_mensagens m where m.sugestao_id = s.id order by m.created_at desc limit 1), false);
-- sugestao_responder: igual à 008, mas marca ultima_de_admin (true quando responde o admin, false quando responde a pessoa)
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
  if adm then update public.sugestoes set por_ler_user = true, ultima_em = now(), ultima_de_admin = true where id = p_sugestao;
  else update public.sugestoes set por_ler = true, ultima_em = now(), ultima_de_admin = false where id = p_sugestao; end if;
  return m;
end $$;
