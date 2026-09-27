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
  const ev=(f,a)=>p.evaluate(f,a);const go=async tab=>{await ev(`document.querySelector('[data-tab="${tab}"]').click()`)};

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
  t('D07','filtros e títulos da tabela de movimentos existem (fQ, fCat, fRef)',await ev(()=>!!(document.querySelector('#extBar #fQ')&&document.querySelector('#extBar #fRef')&&document.querySelector('#extHead thead'))));

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

  console.log('Dividir');
  await go('ext');await p.fill('#fQ','NETFLIX');await p.waitForTimeout(150);
  const nid=await ev(()=>DB.mov.find(x=>x.desc.startsWith('NETFLIX')).id);
  await p.click(`#extTable [data-split="${nid}"]`);await p.waitForTimeout(150);
  await p.selectOption('#spRows tr:nth-child(1) [data-spc]','Lazer');await p.selectOption('#spRows tr:nth-child(1) [data-spr]','Jogos');
  await p.fill('#spRows tr:nth-child(2) [data-spv]','20');
  t('D18a','dividir só guarda quando a soma bate com o valor original',await ev(()=>document.querySelector('#spOk').disabled));
  await p.fill('#spRows tr:nth-child(2) [data-spv]','3,99');
  t('D48','ao dividir, a 1.ª linha é fechada e vale o original − as outras linhas',await ev(()=>{const i=document.querySelector('#spRows tr:nth-child(1) [data-spv]');return i.readOnly&&i.value==='10,00'&&!document.querySelector('#spOk').disabled}));await p.selectOption('#spRows tr:nth-child(2) [data-spc]','Casa');await p.selectOption('#spRows tr:nth-child(2) [data-spr]','Internet');
  await p.click('#spOk');await p.waitForTimeout(150);
  const sp=await ev(()=>{const m=DB.mov.find(x=>x.desc.startsWith('NETFLIX'));const x=expande([m]);return {n:m.partes.length,soma:r2(x.reduce((s,y)=>s+y.valor,0)),cats:x.map(y=>y.cat),sub:document.querySelectorAll('#extTable tr.parte').length}});
  t('D49','linhas divididas minimizadas por defeito',sp.sub===0,sp);
  await p.click(`#extTable [data-sptog="${nid}"]`);await p.waitForTimeout(100);
  sp.sub=await ev(()=>document.querySelectorAll('#extTable tr.parte').length);
  t('D18','movimento dividido: partes somam o original, contam nas categorias e aparecem como sub-linhas',sp.n===2&&sp.soma===-13.99&&sp.cats.join()==='Lazer,Casa'&&sp.sub===2,sp);
  await ev(()=>{DB.mov.push({id:'mRb2',k:'rbteste2',man:true,banco:'Dinheiro',conta:'',dm:'2026-09-22',dv:'2026-09-22',desc:'DEVOLVE INTERNET',valor:2,saldo:null,cat:'',ref:'',catSrc:'',det:'',obs:'',quem:'',ord:0});render()});
  await p.fill('#fQ','DEVOLVE INTERNET');await p.waitForTimeout(150);
  await p.click('#extTable [data-reemb="mRb2"]');await p.waitForTimeout(150);await p.click('#rbTodas');await p.waitForTimeout(100);
  await p.click(`#rbList [data-rbsel="${nid}#1"]`);await p.waitForTimeout(150);
  const rp=await ev(n=>{const m=DB.mov.find(x=>x.id==='mRb2'),o=DB.mov.find(x=>x.id===n);return {ok:m.reemb===chaveParte(o,1)&&m.cat==='Casa'&&m.ref==='Internet'&&/Reembolso de NETFLIX/.test(document.querySelector('#extTable tr[data-id="mRb2"]').children[8].textContent),cat:m.cat,r:m.reemb}},nid);
  t('D50','reembolso pode ligar a uma linha de um movimento dividido',rp.ok,rp);
  await ev(()=>{DB.mov.push({id:'mRb3',k:'rbteste3',man:true,banco:'Dinheiro',conta:'',dm:'2026-09-23',dv:'2026-09-23',desc:'TRF RECEBIDA GRUPO',valor:30,saldo:null,cat:'',ref:'',catSrc:'',det:'',obs:'',quem:'',ord:0});render()});
  await p.fill('#fQ','TRF RECEBIDA GRUPO');await p.waitForTimeout(150);
  await p.click('#extTable [data-split="mRb3"]');await p.waitForTimeout(150);
  await p.fill('#spRows tr:nth-child(2) [data-spv]','10');
  const d53=await ev(()=>({txt:document.querySelector('#spSoma').textContent,foot:!!document.querySelector('#spFoot #spAdd'),info:!!document.querySelector('#spInfo')&&!/Divida/.test(document.querySelector('#spDesc').textContent)}));
  t('D53','Dividir: sem texto "bate certo", ＋ Linha por baixo do valor e ajuda no ⓘ',d53.txt===''&&d53.foot&&d53.info,d53);
  await p.click('#spRows tr:nth-child(2) [data-spreemb]');await p.waitForTimeout(150);await p.click('#rbTodas');await p.waitForTimeout(100);
  await p.click(`#rbList [data-rbsel="${cont}"]`);await p.waitForTimeout(150);
  await p.click('#spOk');await p.waitForTimeout(150);
  const d54a=await ev(()=>{const m=DB.mov.find(x=>x.id==='mRb3');return {ok:m.partes.length===2&&!!m.partes[1].reemb&&m.partes[1].cat==='Alimentação'&&eReemb(expande([m])[1]),p:m.partes}});
  await p.click('#extTable [data-sptog="mRb3"]');await p.waitForTimeout(100);
  await p.click('#extTable [data-reembp="mRb3#0"]');await p.waitForTimeout(150);await p.click('#rbTodas');await p.waitForTimeout(100);
  await p.click(`#rbList [data-rbsel="${cont}"]`);await p.waitForTimeout(150);
  const d54b=await ev(()=>{const m=DB.mov.find(x=>x.id==='mRb3');return !!m.partes[0].reemb&&document.querySelectorAll('#extTable tr.parte [data-golk]').length===2});
  t('D54','entrada dividida: cada linha pode ser reembolso (↩ na janela Dividir e nas sub-linhas)',d54a.ok&&d54b,{d54a,d54b});
  const d55=await ev(()=>{const rs=[...document.querySelectorAll('#extTable tbody tr[data-id]')];const all=[...DB.mov];document.querySelector('#fQ').value='';render();const rows=[...document.querySelectorAll('#extTable tbody tr[data-id]')];const pos=rows.map(tr=>[...tr.querySelectorAll('td.acts .sl')].map(s=>Math.round(s.getBoundingClientRect().left-tr.getBoundingClientRect().left)).join(','));return {ok:rows.length>1&&new Set(pos).size===1&&pos[0].split(',').length===4,pos:[...new Set(pos)]}});
  t('D55','botões do fim da linha em posições fixas (4 lugares)',d55.ok,d55);
  await p.fill('#fQ','');
  t('D19','reembolso mostra só a ligação nos Detalhes',await ev(()=>{render();const tr=document.querySelector('#extTable tr[data-id="mRb"]');return !tr||(/Reembolso de/.test(tr.children[8].textContent)&&!/Diversos|COMPRAS/.test(tr.children[8].textContent))}));

  console.log('Pesquisa por data / calendário / pessoas');
  const dq=await ev(()=>{const m=DB.mov.find(x=>!x.man),d=m.dm.split('-');const q1=`${d[2]}/${d[1]}/${d[0]}`,q2=`${d[1]}/${d[0]}`;
    const f=q=>{document.querySelector('#fQ').value=q;render();return [...document.querySelectorAll('#extTable tbody tr[data-id]')].map(tr=>DB.mov.find(x=>x.id===tr.dataset.id))};
    const r1=f(q1),r2=f(q2),r3=f(`${d[2]}/${d[1]}`);document.querySelector('#fQ').value='';render();
    return {ok:r1.length>0&&r1.every(x=>x.dm===m.dm||x.dv===m.dm)&&r2.length>=r1.length&&r2.every(x=>x.dm.slice(0,7)===m.dm.slice(0,7)||x.dv.slice(0,7)===m.dm.slice(0,7))&&r3.length>=r1.length,n:[r1.length,r2.length,r3.length]}});
  t('D47','pesquisa dos Extratos aceita datas (dd/mm, dd/mm/aaaa, mm/aaaa)',dq.ok,dq);
  const cal=await ev(()=>{P.m='mes';P.d=new Date(2026,8,1);perLabel();document.querySelector('#perLbl').click();const pop=document.querySelector('#calPop');const vis=!pop.hidden&&pop.querySelectorAll('[data-cmes]').length===12;
    pop.querySelector('[data-cy="-1"]').click();pop.querySelector('[data-cmes="2"]').click();const a=P.m==='mes'&&P.d.getFullYear()===2025&&P.d.getMonth()===2&&pop.hidden;
    document.querySelector('#perLbl').click();pop.querySelector('[data-cano]').click();const b=P.m==='ano'&&P.d.getFullYear()===2025;
    P.m='mes';P.d=new Date(2026,8,1);document.querySelectorAll('#perMode button').forEach(x=>x.classList.toggle('on',x.dataset.m==='mes'));perLabel();render();return {ok:vis&&a&&b,vis,a,b}});
  t('D52','clicar na data abre calendário (ano + 12 meses) para escolher mês ou ano',cal.ok,cal);
  t('D51','janela Pessoas com pesquisa fixa que filtra as listas',await ev(()=>{document.querySelector('#btRegras').click();document.querySelector('#mRegras [data-mtab="mPessoas"]').click();const q=document.querySelector('#pesQ');const st=getComputedStyle(document.querySelector('#pesQw')).position;q.value='zzzqqq';q.dispatchEvent(new Event('input'));const n=document.querySelectorAll('#pesPend tbody tr,#pesList tbody tr').length;q.value='';q.dispatchEvent(new Event('input'));document.querySelector('#mPessoas').hidden=true;return st==='sticky'&&n===0}));

  console.log('Janelas e botões (v0.7r)');
  t('D55b','botões da linha pela ordem ↩ ✂ ✏ 🗑, encostados à direita',await ev(()=>{const tr=[...document.querySelectorAll('#extTable tbody tr[data-id]')].find(r=>r.querySelector('[data-edit]'))||document.querySelector('#extTable tbody tr[data-id]');const sl=[...tr.querySelectorAll('td.acts .sl')];const td=tr.querySelector('td.acts');return sl.length===4&&(!sl[1].firstChild||sl[1].querySelector('[data-split]'))&&sl[3].querySelector('[data-del]')&&getComputedStyle(td).textAlign==='right'}));
  t('D56','filtros: tipo (entradas/saídas) logo a seguir à pesquisa e banco no fim',await ev(()=>{const ids=[...document.querySelectorAll('#extBar .filt select')].map(x=>x.id);return ids[0]==='fTipo'&&ids[ids.length-1]==='fBanco'}));
  t('D57a','um só botão "Regras e pessoas" com duas abas',await ev(()=>{if(document.querySelector('#btPessoas'))return false;document.querySelector('#btRegras').click();const a=!document.querySelector('#mRegras').hidden;document.querySelector('#mRegras [data-mtab="mPessoas"]').click();const b=document.querySelector('#mRegras').hidden&&!document.querySelector('#mPessoas').hidden;document.querySelector('#mPessoas [data-mtab="mRegras"]').click();const c=!document.querySelector('#mRegras').hidden;document.querySelector('#mRegras').hidden=true;return a&&b&&c}));
  t('D57b','um só botão Importar/Exportar que abre a janela de escolha',await ev(()=>{if(document.querySelector('#btExp')||document.querySelector('#btImps'))return false;document.querySelector('#btIE').click();const a=!document.querySelector('#mIE').hidden;document.querySelector('#ieImps').click();const b=document.querySelector('#mIE').hidden&&!document.querySelector('#mImps').hidden;document.querySelector('#mImps').hidden=true;return a&&b}));
  await ev(()=>{document.querySelector('#fQ').value='';render()});
  const d60=await ev(()=>{const m=DB.mov.find(x=>x.desc.startsWith('CONTINENTE')),k=chave(m),n=DB.mov.length;apaga([m]);render();
    document.querySelector('#btMov').click();document.querySelector('#mMov [data-mtab="mElim"]').click();const lst=!document.querySelector('#mElim').hidden&&!!document.querySelector(`#elimList [data-repor]`);
    return {lst,k,n,gone:DB.mov.length===n-1,bloq:DB.del.includes(k)}});
  await p.setInputFiles('#fExt',path.join(FX,'cgd_teste.csv'));await p.waitForTimeout(300);
  const d60b=await ev(k=>{const naoVolta=!DB.mov.some(x=>chave(x)===k);document.querySelector('#elimList [data-repor]').click();const volta=DB.mov.some(x=>chave(x)===k)&&!(DB.delM||[]).some(x=>chave(x.m)===k);document.querySelector('#mElim').hidden=true;
    const j=junta(JSON.parse(JSON.stringify(DB)),{...JSON.parse(JSON.stringify(DB)),del:[...DB.del,k],rep:{}});return {naoVolta,volta,sync:j.d.mov.some(x=>chave(x)===k)}},d60.k);
  t('D58','movimentos eliminados: não voltam ao reimportar, aparecem em ＋ Movimento › Eliminados e podem ser repostos',d60.lst&&d60.gone&&d60.bloq&&d60b.naoVolta&&d60b.volta&&d60b.sync,{d60,d60b});
  const d61=await ev(()=>{const m=document.querySelector('#mRegras');m.hidden=false;const sh=m.querySelector('.sheet');sh.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true}));m.dispatchEvent(new MouseEvent('click',{bubbles:true}));const a=!m.hidden;m.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true}));m.dispatchEvent(new MouseEvent('click',{bubbles:true}));return {a,b:m.hidden}});
  t('D59','janelas fecham ao clicar fora, mas não ao carregar dentro e largar fora',d61.a&&d61.b,d61);
  t('D60','Dividir: ⓘ mostra a explicação numa etiqueta (não na caixa)',await ev(()=>{abreSplit(DB.mov.find(x=>x.valor<0));const b=document.querySelector('#spAjuda');const h0=b.hidden;document.querySelector('#spInfo').click();const ok=h0&&!b.hidden&&!!b.closest('.mh')&&document.querySelector('#spInfo').title==='Como funciona';document.querySelector('#mSplit').hidden=true;SP=null;return ok}));

  console.log('Início');
  await go('home');
  t('D34','Início não conta categorias fora das contas, exceto entradas de Rendimentos',await ev(()=>!contaInicio({valor:-10,cat:'Por tratar',ref:'x'})&&!contaInicio({valor:10,cat:'Por tratar'})&&!contaInicio({valor:10,cat:'Banco',ref:'x'})&&!contaInicio({valor:-10,cat:'Investimentos'})&&contaInicio({valor:-10,cat:'Alimentação'})&&contaInicio({valor:10,cat:'Rendimentos'})&&!contaInicio({valor:-10,cat:'Rendimentos'})&&contaInicio({valor:-10,cat:''})));
  t('D35','donut de despesas do Início sem categorias fora das contas',await ev(()=>{const m=DB.mov.find(x=>x.valor<0);m.cat='Por tratar';m.ref='Transferência pag';render();return ![...document.querySelectorAll('#homeDonut li')].some(li=>/Por tratar/.test(li.textContent))}));
  t('D30','caixa de rendimentos existe e despesas são clicáveis',await ev(()=>!!document.querySelector('#homeRend')&&!!document.querySelector('#homeDonut li.clk')));
  t('D36','"Por categorizar" mostra todas as descrições (sem limite)',await ev(()=>{const n=new Set(DB.mov.filter(x=>{const [a,b]=range();return x.dm>=a&&x.dm<=b&&isUnc(x)}).map(x=>norm(x.desc))).size;return document.querySelectorAll('#homeUnc tbody tr').length===n}));
  t('D37','caixas do Início sem texto (só ao passar o rato) e Entradas/Saídas clicáveis',await ev(()=>!document.querySelector('#homeKpis .kpi .s')&&document.querySelector('#homeKpis .kpi').title.length>0&&!!document.querySelector('#homeKpis [data-gotipo="e"]')));
  await ev(()=>document.querySelector('#homeKpis [data-gotipo="s"]').click());
  t('D38','clicar em Saídas abre os Extratos com o filtro "Só saídas"',await ev(()=>document.querySelector('#tab-ext').classList.contains('on')&&document.querySelector('#fTipo').value==='s'));
  t('D46','milhares sempre com espaço (1 234,56 €)',await ev(()=>/^1\s234,56\s€$/.test(E(1234.56))&&/^-4\s038,06\s€$/.test(E(-4038.06))));
  await ev(()=>{document.querySelector('[data-tab="ext"]').click()});
  const d08=await ev(()=>{const h=[...document.querySelectorAll('#extHead th')],tr=document.querySelector('#extTable tbody tr:not(.parte)'),c=[...tr.children];return {n:[h.length,c.length],L:h.map((x,i)=>Math.round(x.getBoundingClientRect().left)+'/'+Math.round(c[i].getBoundingClientRect().left)).join(' '),sl:[document.querySelector('#extHead').scrollLeft,document.querySelector('#extTable').scrollLeft,document.querySelector('#extHead').clientWidth,document.querySelector('#extTable').clientWidth],ok:h.length===c.length&&h.every((x,i)=>Math.abs(x.getBoundingClientRect().left-c[i].getBoundingClientRect().left)<1.5),ov:getComputedStyle(document.documentElement).overflowY}});
  t('D08c','títulos da tabela na barra fixa, alinhados com as colunas, e barra de scroll reservada',d08.ok&&d08.ov==='scroll',d08);
  t('D08b','tabela de movimentos com larguras de coluna fixas',await ev(()=>!!document.querySelector('#extTable table.tfix colgroup')));
  await ev(()=>document.querySelector('[data-tab="home"]').click());
  t('D31','"Por categorizar" mostra só as mais frequentes (com ⚡)',await ev(()=>!document.querySelector('#uncVista')&&UNCV==='freq'));
  t('D32','caixa "Despesas por referência" e gráfico com opção Detalhado',await ev(()=>!!document.querySelector('#homeDonutRef')&&document.querySelectorAll('#barsVista button').length===2));
  t('D33','gráfico de entradas/saídas mostra sempre os 12 meses do ano',await ev(()=>mesesGraf().length===12));

  console.log('Estado');
  await go('ext');await p.fill('#fQ','NETFLIX');await p.selectOption('#fTipo','s');await p.waitForTimeout(100);
  await p.reload();await p.waitForTimeout(500);
  t('D45','ao atualizar mantém aba, pesquisa e filtros',await ev(()=>document.querySelector('#tab-ext').classList.contains('on')&&document.querySelector('#fQ').value==='NETFLIX'&&document.querySelector('#fTipo').value==='s'));

  console.log('Página principal');
  await p.goto(U+'/index.html');await p.waitForTimeout(300);
  const tabs=await ev(()=>[...document.querySelectorAll('nav a')].map(a=>a.textContent));
  t('D40','Finanças é o primeiro separador',tabs[0]==='Finanças',tabs);
  t('D41','separadores externos nunca recebem sessão/tema (data-ext)',await ev(()=>{location.hash='#biblia';return new Promise(r=>setTimeout(()=>r(!!document.querySelector('iframe[data-ext]')&&/:not\(\[data-ext\]\)/.test(document.body.innerHTML)),300))}));
  t('D42','menu (avatar ▾) com Definições, Plano, Onboarding e modo escuro',await ev(()=>!!document.querySelector('#btMenu')&&['[data-set="tema"]','#miPlano','#miOnb','#miTema'].every(q=>document.querySelector(q))));
  t('D44','versão no canto do menu da conta (sem subtítulo nas Finanças)',await ev(()=>{document.querySelector('#btMenu').click();const v=document.querySelector('#mVer').textContent;document.querySelector('#btMenu').click();const f=document.querySelector('iframe[data-id="financas"]').contentDocument;return /^v0\./.test(v)&&!f.querySelector('.top p')}));
  t('D43','onboarding abre e tem vários passos',await ev(()=>{FPOnb.abre();const ok=!document.querySelector('#mOnb').hidden&&document.querySelectorAll('#onbDots i').length>=5;document.querySelector('#mOnb').hidden=true;return ok}));

  t('D99','sem erros de JavaScript',erros.length===0,erros);
  await b.close();srv.close();
  console.log(`\n${ok} ok · ${falhas.length} falha(s)`);if(falhas.length){console.log('FALHAS:\n - '+falhas.join('\n - '));process.exit(1)}
})().catch(e=>{console.error(e);srv.close();process.exit(2)});
