-- Finanças Pessoais — tabela própria do site (projeto Supabase da plataforma)
-- Correr uma vez no SQL Editor do Supabase. Usa as contas já existentes (auth.users).

create table if not exists public.financas_dados (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  ferramenta  text not null,                 -- ex.: 'simulador', 'financas'
  chave       text not null default 'estado',-- permite vários registos por ferramenta
  dados       jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, ferramenta, chave)
);

comment on table public.financas_dados is 'Dados do site Finanças Pessoais (financas.frisk.pt), um registo por utilizador/ferramenta/chave.';

-- Atualiza updated_at automaticamente
create or replace function public.financas_set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists financas_dados_updated_at on public.financas_dados;
create trigger financas_dados_updated_at
  before update on public.financas_dados
  for each row execute function public.financas_set_updated_at();

-- Segurança: cada utilizador só vê e altera os seus próprios dados
alter table public.financas_dados enable row level security;

drop policy if exists "financas: ler os meus dados"     on public.financas_dados;
drop policy if exists "financas: criar os meus dados"   on public.financas_dados;
drop policy if exists "financas: alterar os meus dados" on public.financas_dados;
drop policy if exists "financas: apagar os meus dados"  on public.financas_dados;

create policy "financas: ler os meus dados" on public.financas_dados
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "financas: criar os meus dados" on public.financas_dados
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "financas: alterar os meus dados" on public.financas_dados
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "financas: apagar os meus dados" on public.financas_dados
  for delete to authenticated using ((select auth.uid()) = user_id);

revoke all on public.financas_dados from anon;
grant select, insert, update, delete on public.financas_dados to authenticated;
