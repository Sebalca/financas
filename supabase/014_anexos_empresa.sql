-- v0.18 — Anexos da empresa (Storage privado). Caminho: <agregado_id>/<ficheiro>.
-- Só os membros da empresa (aceitaram o convite) leem, enviam e apagam; PDF e imagens até 10 MB; até 200 MB por empresa.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('empresa-anexos', 'empresa-anexos', false, 10485760, array['application/pdf','image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

create or replace function public.anexo_agregado(p_nome text)
returns uuid language plpgsql immutable set search_path = '' as $$
begin
  return split_part(p_nome, '/', 1)::uuid;
exception when others then return null;
end $$;

create or replace function public.anexos_espaco(p_agregado uuid)
returns bigint language sql stable security definer set search_path = '' as $$
  select coalesce(sum((o.metadata->>'size')::bigint), 0) from storage.objects o
  where o.bucket_id = 'empresa-anexos' and public.anexo_agregado(o.name) = p_agregado
$$;
revoke execute on function public.anexos_espaco(uuid) from public, anon;
grant execute on function public.anexos_espaco(uuid) to authenticated;

create policy "empresa-anexos: membros leem" on storage.objects for select to authenticated
  using (bucket_id = 'empresa-anexos' and public.e_membro_agregado(public.anexo_agregado(name)));
create policy "empresa-anexos: membros enviam" on storage.objects for insert to authenticated
  with check (bucket_id = 'empresa-anexos' and public.e_membro_agregado(public.anexo_agregado(name))
              and not public.fin_bloqueado('financas') and public.anexos_espaco(public.anexo_agregado(name)) < 209715200);
create policy "empresa-anexos: membros apagam" on storage.objects for delete to authenticated
  using (bucket_id = 'empresa-anexos' and public.e_membro_agregado(public.anexo_agregado(name)));
