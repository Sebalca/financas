-- v0.8h — cópia das sugestões no Supabase (para o sinal "por ler" do admin). Aplicado via migração "sugestoes_por_site".
create table if not exists public.sugestoes (
  id uuid primary key default gen_random_uuid(),
  site_id text not null references public.sites(id) on delete cascade,
  user_id uuid default auth.uid() references auth.users(id) on delete set null,
  tipo text not null default 'Ideia' check (char_length(tipo) <= 30),
  texto text not null check (char_length(texto) between 3 and 4000),
  email text check (email is null or char_length(email) <= 200),
  separador text check (separador is null or char_length(separador) <= 60),
  versao text check (versao is null or char_length(versao) <= 20),
  por_ler boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.sugestoes enable row level security;
-- qualquer pessoa envia (sempre por_ler = true); só os admins do site (site_admins) leem, marcam como lidas e apagam
create policy "sugestoes: enviar" on public.sugestoes for insert to anon, authenticated with check (por_ler and (user_id is null or user_id = (select auth.uid())));
create policy "sugestoes: admin lê" on public.sugestoes for select to authenticated using (public.e_admin_site(site_id));
create policy "sugestoes: admin marca" on public.sugestoes for update to authenticated using (public.e_admin_site(site_id)) with check (public.e_admin_site(site_id));
create policy "sugestoes: admin apaga" on public.sugestoes for delete to authenticated using (public.e_admin_site(site_id));
-- trigger sugestoes_antes(): máx. 60 sugestões por hora por site
