/* Finanças Pessoais — service worker (v0.25, D155)
   Rede primeiro: com internet vai sempre buscar a versão publicada (as atualizações continuam como antes — D143/D153).
   Sem internet usa a última cópia guardada do site (só ficheiros do site e bibliotecas; NUNCA dados — os pedidos ao Supabase não passam por aqui). */
const CACHE='financas-app-v1';
const BASE=['./','index.html','financas.html','manifest.webmanifest','img/logo-32.png','img/logo-64.png','img/apple-touch-icon.png','img/app-192.png','img/app-512.png',
  'lib/xlsx.full.min.js','lib/pdf.min.js','lib/pdf.worker.min.js'];
const CDN=['https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2','https://cdn.jsdelivr.net/gh/sebalca/plataforma-core@main/auth.js'];
/* uma resposta que veio de um redirecionamento (/index.html → /) não pode servir uma navegação — guarda-se uma cópia limpa */
const limpa=async r=>r.redirected?new Response(await r.blob(),{status:r.status,statusText:r.statusText,headers:r.headers}):r;
const chave=req=>{const u=new URL(req.url);return u.origin===location.origin?u.origin+u.pathname:u.href};
self.addEventListener('install',e=>{e.waitUntil((async()=>{const c=await caches.open(CACHE);
  await Promise.all(BASE.map(p=>fetch(p,{cache:'no-store'}).then(async r=>r.ok&&c.put(new URL(p,location.href).href,await limpa(r))).catch(()=>{})));
  await Promise.all(CDN.map(u=>fetch(u,{mode:'no-cors'}).then(r=>c.put(u,r)).catch(()=>{})));
  self.skipWaiting()})())});
self.addEventListener('activate',e=>{e.waitUntil((async()=>{for(const k of await caches.keys())if(k!==CACHE)await caches.delete(k);await self.clients.claim()})())});
self.addEventListener('fetch',e=>{const req=e.request;if(req.method!=='GET')return;const u=new URL(req.url);
  const meu=u.origin===location.origin,cdn=u.origin==='https://cdn.jsdelivr.net';if(!meu&&!cdn)return; // Supabase e outros: nunca passam pelo service worker
  if(meu&&/^\/(admin|privacidade)\.html$/.test(u.pathname))return;
  e.respondWith((async()=>{const c=await caches.open(CACHE);
    try{const r=await fetch(req);if(r&&(r.ok||r.type==='opaque'))limpa(r.clone()).then(x=>c.put(chave(req),x)).catch(()=>{});return r}
    catch(err){const k=chave(req);const m=await c.match(k)||(meu&&!/\.[a-z0-9]+$/i.test(u.pathname)?await c.match(location.origin+(u.pathname==='/'?'/index.html':u.pathname+'.html')):null)||(req.mode==='navigate'?await c.match(location.origin+'/'):null);
      if(m)return m;throw err}})())});
