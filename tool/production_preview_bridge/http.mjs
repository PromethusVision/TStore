import { randomBytes, createHmac } from 'node:crypto';
import { run, container, sha256, stableJson } from './local.mjs';
import { check } from '../production_taxonomy/execution/common.mjs';

export class HttpChecks {
  constructor(db) { this.db=db; this.key=randomBytes(32).toString('hex'); }
  async start() {
    const config={
      'db-uri':['host=/tmp',`dbname=${this.db.name}`,'user=authenticator'].join(' '),
      'db-schemas':'public','db-anon-role':'anon','db-extra-search-path':'public,extensions',
      'server-host':'127.0.0.1','server-port':3000,'jwt-secret':this.key,'log-level':'crit',
    };
    // Ephemeral test signing key stays in memory / private disposable container.
    // It is never a Production credential and is never printed or put in git.
    run(['exec','-i',container,'sh','-c','umask 077; cat > /tmp/w52jb-postgrest.conf'],Object.entries(config).map(([k,v])=>`${k} = ${JSON.stringify(v)}`).join('\n')+'\n');
    run(['exec','-d',container,'sh','-c','echo $$ > /tmp/w52jb-postgrest.pid; exec /tmp/postgrest /tmp/w52jb-postgrest.conf > /tmp/w52jb-postgrest.log 2>&1']);
    let ready=false;
    for(let i=0;i<15;i++) {
      try { this.request('anon','/',{});ready=true;break; } catch { await new Promise(r=>setTimeout(r,300)); }
    }
    check(ready,'LOCAL_POSTGREST_READY');
  }
  request(role,path,params,single=false) {
    const url=new URL(path,'http://127.0.0.1:3000');
    for(const [key,value] of Object.entries(params)) url.searchParams.set(key,value);
    let config=`url = ${JSON.stringify(url.href)}\n`;
    if(single) config+='header = "Accept: application/vnd.pgrst.object+json"\n';
    if(role==='authenticated') {
      const encode = value=>Buffer.from(JSON.stringify(value)).toString('base64url');
      const body=encode({alg:'HS256',typ:'JWT'})+'.'+encode({role:'authenticated',sub:'00000000-0000-4000-8000-000000005252',exp:Math.floor(Date.now()/1000)+3600});
      const token=body+'.'+createHmac('sha256',this.key).update(body).digest('base64url');
      config+=`header = ${JSON.stringify('Authorization: Bearer '+token)}\n`;
    }
    const output=run(['exec','-i',container,'curl','--silent','--show-error','--fail-with-body','--max-time','15','--config','-'],config);
    return JSON.parse(output);
  }
  async legacy() {
    const p=(await this.db.query('SELECT id::text,category_id::text FROM public.products ORDER BY id LIMIT 1')).rows[0];
    const s=(await this.db.query('SELECT id::text FROM public.shops WHERE is_active ORDER BY id LIMIT 1')).rows[0];
    const productSelect='*,categories(name),brands(name)';
    const listingSelect='*,products(*,categories(name),brands(name)),shops(*)';
    const queries={
      home_categories:['/categories',{select:'*',is_active:'eq.true',parent_id:'is.null',order:'sort_order.asc'}],
      product_listing:['/products',{select:productSelect,is_active:'eq.true',order:'created_at.asc',limit:'20',offset:'0'}],
      category_product_listing:['/products',{select:productSelect,is_active:'eq.true',category_id:`eq.${p.category_id}`,order:'created_at.desc'}],
      product_details:['/products',{select:productSelect,id:`eq.${p.id}`},true],
      seller_comparison:['/shop_products',{select:listingSelect,is_active:'eq.true',is_available:'eq.true',product_id:`eq.${p.id}`,order:'created_at.desc'}],
      shop_details:['/shops',{select:'*',id:`eq.${s.id}`,is_active:'eq.true'},true],
      shop_listings:['/shop_products',{select:listingSelect,is_active:'eq.true',is_available:'eq.true',shop_id:`eq.${s.id}`,order:'created_at.desc'}],
      search:['/products',{select:productSelect,is_active:'eq.true',or:'(name.ilike.%Kalem%,description.ilike.%Kalem%)',limit:'50'}],
    };
    const result={};
    for(const role of ['anon','authenticated']) {
      result[role]={};
      for(const [name,args] of Object.entries(queries)) {
        const data=this.request(role,...args);
        const rows=Array.isArray(data)?data:[data];
        check(rows.length>0,'HTTP_EMPTY:'+name.toUpperCase());
        if(name==='home_categories') check(rows.length===4,'HTTP_HOME_COUNT');
        if(name==='product_listing') check(rows.length===20 && rows.every(r=>r.categories && Object.hasOwn(r,'brands')),'HTTP_PRODUCT_DTO');
        if(['seller_comparison','shop_listings'].includes(name)) check(rows.every(r=>r.products?.categories && r.shops?.id),'HTTP_LISTING_EMBEDS');
        const canonical=[...rows].sort((a,b)=>String(a.id).localeCompare(String(b.id)));
        result[role][name]={transport:'PASS_CURL_EXIT_0_AND_EXPECTED_JSON',rows:rows.length,result_sha256:sha256(stableJson(canonical)),object_response:!Array.isArray(data)};
      }
    }
    return result;
  }
  stop() {
    run(['exec',container,'sh','-c','if test -f /tmp/w52jb-postgrest.pid; then kill "$(cat /tmp/w52jb-postgrest.pid)"; fi']);
    this.key=null;
  }
}
