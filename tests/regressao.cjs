/* Testes de regressão — confirmam que as decisões do PATCH NOTES.md (secção "Decisões fixas") continuam a valer.
   Correr antes de cada push:  NODE_PATH=$(npm root -g) node tests/regressao.cjs
   Precisa do Playwright (global). Usa só dados fictícios (tests/fixtures) — nunca pôr extratos/recibos reais no repositório. */
const {chromium}=require('playwright');
const http=require('http'),fs=require('fs'),path=require('path');
const PUB=path.join(__dirname,'..','public'),FX=path.join(__dirname,'fixtures');
const MIME={'.html':'text/html; charset=utf-8','.js':'text/javascript','.css':'text/css','.json':'application/json'};
const srv=http.createServer((q,r)=>{const f=path.join(PUB,decodeURIComponent(q.url.split('?')[0]).replace(/^\/$/,'/index.html'));
  fs.readFile(f,(e,d)=>{if(e){r.writeHead(404);r.end();return}r.writeHead(200,{'content-type':MIME[path.extname(f)]||'application/octet-stream'});r.end(d)})});
let ok=0,falhas=[];
const t=(id,nome,cond,info)=>{if(cond){ok++;console.log(`  ✓ ${id} ${nome}`)}else{falhas.push(`${id} ${nome}`);console.log(`  ✗ ${id} ${nome}${info!==undefined?' → '+JSON.stringify(info):''}`)}};
(async()=>{
  await new Promise(r=>srv.listen(0,r));const U=`http://localhost:${srv.address().port}`;
  const b=await chromium.launch();const p=await b.newPage({viewport:{width:1500,height:900}});const erros=[];
  p.on('pageerror',e=>erros.push(e.message));p.on('dialog',d=>d.accept('Cartão refeição'));
  await p.route(/cdn\.jsdelivr\.net/,r=>r.abort()); // sem login nos testes
  await p.goto(U+'/financas.html');await p.evaluate(()=>localStorage.clear());await p.reload();
  const ev=f=>p.evaluate(f);const go=async tab=>{await ev(`document.querySelector('[data-tab="${tab}"]').click()`)};

  console.log('Extratos');
  await go('ext');
  await p.setInputFiles('#fExt',path.join(FX,'cgd_teste.csv'));await p.waitForTimeout(400);
  await p.selectOption('#bankSel','__cartao');await p.setInputFiles('#fExt',path.join(FX,'cartao_teste.csv'));await p.waitForTimeout(400);await p.selectOption('#bankSel','');
  const M=await ev(()=>DB.mov.map(m=>({d:m.desc,det:m.det,c:m.cat,r:m.ref,b:m.banco,v:m.valor,src:m.catSrc})));
  t('D01','importa CGD + cartão (6+3 movimentos)',M.length===9,M.length);
  t('D02','"Compra" sai da descrição e vai para Detalhes',!M.some(m=>/^compra\b/i.test(m.d))&&M.filter(m=>/Compra/.test(m.det)).length>=3,M.map(m=>m.d));
  t('D03','regras aplicadas ao importar (CONTINENTE → Supermercado)',M.find(m=>m.d.startsWith('CONTINENTE')).r==='Supermercado');
  await p.setInputFiles('#fExt',path.join(FX,'cgd_teste.csv'));await p.waitForTimeout(300);
  t('D04','reimportar não duplica',await ev(()=>DB.mov.length)===9);
  t('D05','"Por categorizar" = sem categoria OU sem referência',await ev(()=>{const m=DB.mov.find(x=>x.desc.startsWith('LOJA SEM'));m.cat='Outros';m.ref='';return isUnc(m)}));
  t('D06','trocas entre contas / levantamentos / Poupanças não contam como entrada/saída',await ev(()=>isInterna({cat:'Banco',ref:'Troca entre contas'})&&isInterna({cat:'Banco',ref:'Levantamentos'})&&isInterna({cat:'Poupanças',ref:'Férias'})));
  await go('ext');
  t('D08','dropdowns Categoria/Referência com largura fixa + "Limpar filtros"',await ev(()=>{const a=document.querySelector('#fCat').offsetWidth,b=document.querySelector('#fRef').offsetWidth;document.querySelector('#fCat').value='Alimentação';render();return a===document.querySelector('#fCat').offsetWidth&&b===document.querySelector('#fRef').offsetWidth&&!!document.querySelector('#btLimpaF')}));
  await ev(()=>{document.querySelector('#btLimpaF').click()});
  t('D09','"Limpar filtros" limpa pesquisa e filtros',await ev(()=>['#fQ','#fCat','#fRef','#fBanco'].every(q=>!document.querySelector(q).value)));
  t('D07','filtros e títulos da tabela de movimentos existem (fQ, fCat, fRef)',await ev(()=>!!(document.querySelector('#extBar #fQ')&&document.querySelector('#extBar #fRef')&&document.querySelector('#extTable thead'))));

  console.log('Despesas');
  t('D10','categorias fora das contas incluem Banco, Por tratar, Investimentos, Empresas, Rendimentos, Poupanças',await ev(()=>['Banco','Por tratar','Investimentos','Empresas','Rendimentos','Poupanças'].every(eFora)));
  t('D11','categoria Poupanças e Rendimentos existem',await ev(()=>['Poupanças','Rendimentos'].every(n=>DB.cats.some(c=>c.nome===n))));
  await ev(()=>{DB.refSo['Lazer›Jogos']=true;aplicaRegras();render()});
  t('D12','referência "Só este movimento" não é usada pelas regras',await ev(()=>!DB.mov.some(m=>m.ref==='Jogos'&&m.catSrc==='regra')));
  await go('des');await p.click('#perMode [data-m="ano"]');await p.waitForTimeout(200);
  t('D13','vista Ano tem Média/mês e duas tabelas',await ev(()=>document.querySelectorAll('#desCats table.des-ano').length===2&&/Média\/mês/.test(document.querySelector('#desCats').innerText)));
  t('D14','vista Ano: fora das contas numa linha por categoria (entradas − saídas), sem coluna "Entradas ano"',await ev(()=>!/Entradas ano/.test(document.querySelector('#desCats').innerText)&&/entradas − saídas/.test(document.querySelector('#desCats').innerText)));
  await p.click('#perMode [data-m="mes"]');

  console.log('Rendimentos');
  await ev(()=>{P.d=new Date(2026,8,1);perLabel()});await go('ren');
  await p.click('[data-radd2]');await p.click('#rdTipo [data-t="pon"]');await p.fill('#rdEnt','DEMO EMPRESA');await p.fill('#rdDesc','Teste');await p.fill('#rdData','2026-09-14');await p.fill('#rdBruto','850');await p.click('#rdOk');await p.waitForTimeout(200);
  const lig=await ev(()=>{const m=DB.mov.find(x=>x.desc.startsWith('TRF DEMO'));return [m.cat,m.catSrc]});
  t('D20','rendimento liga-se sozinho ao movimento com o mesmo valor → categoria Rendimentos',lig[0]==='Rendimentos'&&lig[1]==='rend',lig);
  t('D21','um só botão "Adicionar rendimento"',await ev(()=>document.querySelectorAll('[data-radd2]').length===1));
  await go('ext');await p.fill('#fQ','TRANSFER');await p.waitForTimeout(150);
  t('D22','subsídio no cartão é procurado só na conta Cartão refeição',await ev(()=>{const r={tipo:'rec',data:'2026-09-01',mes:'2026-09',liquido:150,vale:150,lk:{},lkMan:{}};return candidatos(r,'v').every(m=>m.banco===CARTAO)&&candidatos(r,'t').every(m=>m.banco!==CARTAO)}));
  await p.fill('#fQ','');

  console.log('Reembolsos');
  await ev(()=>{DB.mov.push({id:'mRb',k:'rbteste',man:true,banco:'Dinheiro',conta:'',dm:'2026-09-21',dv:'2026-09-21',desc:'DEVOLUCAO AMIGO',valor:20,saldo:null,cat:'',ref:'',catSrc:'',det:'',obs:'',quem:'',ord:0});P.m='mes';P.d=new Date(2026,8,1);perLabel();render()});
  await go('ext');await p.fill('#fQ','DEVOLUCAO');await p.waitForTimeout(150);
  await p.click('#extTable [data-reemb="mRb"]');await p.waitForTimeout(150);
  const cont=await ev(()=>DB.mov.find(x=>x.desc.startsWith('CONTINENTE')).id);
  await p.click(`#rbList [data-rbsel="${cont}"]`);await p.waitForTimeout(150);await p.fill('#fQ','');
  const rb=await ev(()=>{const m=DB.mov.find(x=>x.id==='mRb');return [m.cat,m.ref,!!m.reemb]});
  t('D16','atalho ↩ dá ao reembolso a categoria/referência da despesa original',rb[0]==='Alimentação'&&rb[1]==='Supermercado'&&rb[2],rb);
  t('D15','entrada em categoria de despesa = reembolso: abate às saídas e não conta como entrada',await ev(()=>eReemb(DB.mov.find(x=>x.id==='mRb'))&&!eReemb({valor:50,cat:'Rendimentos'})&&!eReemb({valor:50,cat:''})));
  await go('des');
  const d17=await ev(()=>{const [a,b]=range(),sa=-DB.mov.filter(m=>m.dm>=a&&m.dm<=b&&m.cat==='Alimentação'&&m.valor<0).reduce((s,m)=>s+m.valor,0),esp=E(sa-20),txt=document.querySelector('#desCats details[data-c="Alimentação"] summary').textContent;return {ok:txt.includes('Real '+esp)&&/reemb/.test(txt),esp,txt}});
  t('D17','Despesas: real = saídas − reembolsos',d17.ok,d17);

  console.log('Início');
  await go('home');
  t('D34','Início não conta categorias fora das contas, exceto entradas de Rendimentos',await ev(()=>!contaInicio({valor:-10,cat:'Por tratar',ref:'x'})&&!contaInicio({valor:10,cat:'Por tratar'})&&!contaInicio({valor:10,cat:'Banco',ref:'x'})&&!contaInicio({valor:-10,cat:'Investimentos'})&&contaInicio({valor:-10,cat:'Alimentação'})&&contaInicio({valor:10,cat:'Rendimentos'})&&!contaInicio({valor:-10,cat:'Rendimentos'})&&contaInicio({valor:-10,cat:''})));
  t('D35','donut de despesas do Início sem categorias fora das contas',await ev(()=>{const m=DB.mov.find(x=>x.valor<0);m.cat='Por tratar';m.ref='Transferência pag';render();return ![...document.querySelectorAll('#homeDonut li')].some(li=>/Por tratar/.test(li.textContent))}));
  t('D30','caixa de rendimentos existe e despesas são clicáveis',await ev(()=>!!document.querySelector('#homeRend')&&!!document.querySelector('#homeDonut li.clk')));
  t('D31','"Por categorizar" mostra só as mais frequentes (com ⚡)',await ev(()=>!document.querySelector('#uncVista')&&UNCV==='freq'));
  t('D32','caixa "Despesas por referência" e gráfico com opção Detalhado',await ev(()=>!!document.querySelector('#homeDonutRef')&&document.querySelectorAll('#barsVista button').length===2));
  t('D33','gráfico de entradas/saídas mostra sempre os 12 meses do ano',await ev(()=>mesesGraf().length===12));

  console.log('Página principal');
  await p.goto(U+'/index.html');await p.waitForTimeout(300);
  const tabs=await ev(()=>[...document.querySelectorAll('nav a')].map(a=>a.textContent));
  t('D40','Finanças é o primeiro separador',tabs[0]==='Finanças',tabs);
  t('D41','separadores externos nunca recebem sessão/tema (data-ext)',await ev(()=>{location.hash='#biblia';return new Promise(r=>setTimeout(()=>r(!!document.querySelector('iframe[data-ext]')&&/:not\(\[data-ext\]\)/.test(document.body.innerHTML)),300))}));
  t('D42','menu (avatar ▾) com Definições, Plano, Onboarding e modo escuro',await ev(()=>!!document.querySelector('#btMenu')&&['[data-set="tema"]','#miPlano','#miOnb','#miTema'].every(q=>document.querySelector(q))));
  t('D43','onboarding abre e tem vários passos',await ev(()=>{FPOnb.abre();const ok=!document.querySelector('#mOnb').hidden&&document.querySelectorAll('#onbDots i').length>=5;document.querySelector('#mOnb').hidden=true;return ok}));

  t('D99','sem erros de JavaScript',erros.length===0,erros);
  await b.close();srv.close();
  console.log(`\n${ok} ok · ${falhas.length} falha(s)`);if(falhas.length){console.log('FALHAS:\n - '+falhas.join('\n - '));process.exit(1)}
})().catch(e=>{console.error(e);srv.close();process.exit(2)});
