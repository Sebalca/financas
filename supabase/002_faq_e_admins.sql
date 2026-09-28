-- v0.8g — FAQs e admins por site (aplicado no projeto Sites via migração "faq_e_admins_por_site")
-- Tabelas de plataforma, reutilizáveis por outros sites através de site_id.

create table if not exists public.site_admins (
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (site_id, user_id)
);
alter table public.site_admins enable row level security;
create policy "site_admins: ver o próprio" on public.site_admins for select to authenticated using (user_id = (select auth.uid()));
-- sem insert/update/delete: gerir admins só pelo painel do Supabase

create or replace function public.e_admin_site(s text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.site_admins a where a.site_id = s and a.user_id = (select auth.uid()))
$$;

create table if not exists public.faq_perguntas (
  id uuid primary key default gen_random_uuid(),
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid default auth.uid() references auth.users(id) on delete set null,
  pergunta text not null check (char_length(pergunta) between 3 and 2000),
  resposta text check (resposta is null or char_length(resposta) <= 8000),
  labels text[] not null default '{}',
  estado text not null default 'nova' check (estado in ('nova','respondida','ignorada')),
  publica boolean not null default false,
  ordem int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  respondida_em timestamptz
);
alter table public.faq_perguntas enable row level security;
-- ler: públicas (todos), as minhas, ou admin do site
create policy "faq: ler públicas, as minhas ou admin" on public.faq_perguntas for select to anon, authenticated
  using (publica or user_id = (select auth.uid()) or public.e_admin_site(site_id));
-- perguntar: só com sessão, sempre como "nova" e privada
create policy "faq: utilizador pergunta" on public.faq_perguntas for insert to authenticated
  with check (user_id = (select auth.uid()) and estado = 'nova' and not publica and resposta is null and labels = '{}');
create policy "faq: admin cria" on public.faq_perguntas for insert to authenticated with check (public.e_admin_site(site_id));
create policy "faq: admin altera" on public.faq_perguntas for update to authenticated using (public.e_admin_site(site_id)) with check (public.e_admin_site(site_id));
create policy "faq: admin apaga" on public.faq_perguntas for delete to authenticated using (public.e_admin_site(site_id));
-- trigger faq_antes(): updated_at, respondida_em e limite de 10 perguntas por utilizador em 24 h (execute revogado a anon/authenticated)
-- admin do site financas: sebalca5@gmail.com (inserido em site_admins)
