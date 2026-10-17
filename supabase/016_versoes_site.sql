-- v0.23 — Aviso de versão nova em tempo real: depois de cada publicação insere-se uma linha aqui
-- (ver CLAUDE.md, passo 7) e os sites abertos recebem-na pelo Supabase Realtime e mostram "Atualizar".
create table if not exists public.site_versoes (
  id bigint generated always as identity primary key,
  site_id text not null references public.sites(id) on delete cascade,
  versao text not null check (char_length(versao) <= 20),
  created_at timestamptz not null default now()
);
alter table public.site_versoes enable row level security;
create policy "site_versoes: todos leem" on public.site_versoes for select to anon, authenticated using (true);
-- sem políticas de escrita (só pelo painel/SQL do dono)
do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'site_versoes') then
    alter publication supabase_realtime add table public.site_versoes;
  end if;
end $$;
