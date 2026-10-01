-- v0.9g — Eventos de uso por utilizador (plataforma, todos os sites) e estatísticas para a página de admin.
-- Aplicado no projeto Sites via migração "eventos_admin".
-- Nunca guardar valores, descrições de movimentos ou outros dados financeiros em `dados`: só contagens/nomes técnicos.

create table if not exists public.site_eventos (
  id bigint generated always as identity primary key,
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  sessao text not null check (char_length(sessao) between 4 and 40),
  tipo text not null check (char_length(tipo) between 1 and 40),
  dados jsonb not null default '{}'::jsonb check (pg_column_size(dados) <= 2000),
  created_at timestamptz not null default now()
);
create index if not exists site_eventos_site_data on public.site_eventos(site_id, created_at);
create index if not exists site_eventos_user on public.site_eventos(user_id, created_at);
create index if not exists site_eventos_sessao on public.site_eventos(sessao);

alter table public.site_eventos enable row level security;
-- cada utilizador só grava eventos seus; ninguém lê diretamente (o admin vê totais pela função abaixo)
create policy "site_eventos: grava os seus" on public.site_eventos for insert to authenticated
  with check (user_id = (select auth.uid()));

create or replace function public.e_admin_plataforma()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists(select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_admin)
$$;

-- estatísticas (aplicado em partes: o editor SQL não aceitava a função inteira de uma vez)
--   adm_ok(site)            → erro se não for admin da plataforma (profiles.is_admin) nem do site
--   adm_ev(site,dias)       → eventos do período;  adm_ses(site,dias) → sessões (min/máx, minutos = duração + 1)
--   adm_kpis / adm_series / adm_users → blocos do resultado;  adm_limpa() → apaga eventos com mais de 12 meses
--   admin_stats(site,dias)  → junta tudo (único com execute para authenticated; os adm_* não têm execute para anon/authenticated)
-- Ver o código atual no Supabase: select pg_get_functiondef('public.admin_stats(text,int)'::regprocedure);
