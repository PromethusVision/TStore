import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {connect,rpc,sqlAs} from './fixture.mjs';
import {writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {root} from './local.mjs';

export async function statementChecks(db,config,f) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const scalar=async(sql,args=[],client=db)=>Object.values((await client.query(sql,args)).rows[0])[0];
  const read=(actor=f.merchant,shop=f.shop,limit=20,before=null,revision=null)=>rpc(config,actor,'read_merchant_statement_v1',[shop,limit,before,revision]);
  const codes=['merchant_coupon_available','merchant_coupon_pending','merchant_reserve','merchant_unused_available','merchant_unused_pending'];
  await check('H1 default OFF and disabled replies contain no invented zero balances or settlement authority',async()=>{
    assert.equal(await scalar('SELECT enabled FROM public.merchant_statement_config'),false);
    const off=await read();
    assert.equal(off.enabled,false);assert.deepEqual(off.accounts,[]);assert.deepEqual(off.entries,[]);
    assert.equal(off.revision,null);assert.equal(off.reserve_cap_minor,null);
    assert.equal(off.settlement_enabled,false);assert.equal(off.settlement_status,'policy_pending');
    await assert.rejects(read(f.other),e=>e.code==='42501');
    await assert.rejects(read(f.customer),e=>e.code==='42501');
  });
  await db.query('UPDATE public.merchant_statement_config SET enabled=true');
  await db.query('UPDATE public.commerce_ledger_config SET enabled=true');
  await check('H1 enabled empty merchant has five exact zero buckets and no fabricated history',async()=>{
    const empty=await read();assert(empty.enabled);assert.equal(empty.revision,'0');
    assert.deepEqual(empty.accounts.map(x=>x.code),codes);
    assert(empty.accounts.every(x=>x.amount_minor==='0'));assert.deepEqual(empty.entries,[]);
    assert.equal(empty.next_before,null);
  });
  const merchant=await scalar("SELECT public.ensure_ledger_party_v1('merchant',$1)",[f.shop]);
  const platform=await scalar("SELECT public.ensure_ledger_party_v1('platform')");
  const ids={};
  for(const code of codes) ids[code]=await scalar('SELECT public.ensure_ledger_account_v1($1,$2)',[merchant,code]);
  ids.platform_clearing=await scalar("SELECT public.ensure_ledger_account_v1($1,'platform_clearing')",[platform]);
  ids.platform_service=await scalar("SELECT public.ensure_ledger_account_v1($1,'platform_service')",[platform]);
  const policy=await scalar('SELECT policy_id FROM public.commerce_ledger_config');
  async function source(kind,amount) {
    return scalar('SELECT public.record_commerce_source_v1($1,$2,$3,$4,$5,$6,NULL,NULL,$7)',
      [kind,randomUUID(),merchant,amount,policy,randomUUID(),'PRIVATE OPERATOR REASON']);
  }
  const lines=values=>Object.entries(values).map(([code,value])=>({account_id:ids[code],amount_minor:String(value)}));
  const post=async(kind,amount,values)=>scalar('SELECT public.post_balanced_journal_v1($1,$2)',[await source(kind,amount),JSON.stringify(lines(values))]);
  let original,reversal;
  await check('H1 source buckets reflect coupon cap, pending release, reserve-first services and coupon refill',async()=>{
    await post('coupon_redemption','150000',{platform_clearing:-150000,merchant_reserve:100000,merchant_coupon_pending:50000});
    await post('unused_package_fund','50000',{platform_clearing:-50000,merchant_unused_pending:50000});
    await post('receivable_release','50000',{merchant_coupon_pending:-50000,merchant_coupon_available:50000});
    await post('receivable_release','25000',{merchant_unused_pending:-25000,merchant_unused_available:25000});
    await post('platform_service','150000',{merchant_reserve:-100000,merchant_coupon_available:-50000,platform_service:150000});
    await post('coupon_redemption','50000',{platform_clearing:-50000,merchant_reserve:50000});
    const value=await read();
    assert.deepEqual(value.accounts.map(x=>x.amount_minor),['0','0','50000','25000','25000']);
    assert.equal(value.reserve_cap_minor,'100000');assert.equal(value.settlement_enabled,false);
    assert.equal(value.entries.filter(x=>x.net_minor==='0').length,2);
    assert.equal(value.entries.find(x=>x.kind==='platform_service').net_minor,'-150000');
  });
  await check('H1 compensating reversal keeps original and signed owned movements with exact original reference',async()=>{
    original=await post('unused_package_fund','1000',{platform_clearing:-1000,merchant_unused_pending:1000});
    reversal=await scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[original,randomUUID(),'PRIVATE REVERSAL REASON']);
    const value=await read(),undo=value.entries.find(e=>e.id===reversal);
    assert.equal(undo.reverses,original);assert.equal(undo.net_minor,'-1000');
    assert(value.entries.some(e=>e.id===original && e.net_minor==='1000'));
    assert.equal(value.accounts.find(x=>x.code==='merchant_unused_pending').amount_minor,'25000');
  });
  await check('H1 exact large integer amounts survive projection without floating-point conversion',async()=>{
    const amount='9007199254740993';
    const journal=await post('unused_package_fund',amount,{platform_clearing:'-'+amount,merchant_unused_pending:amount});
    const value=await read();assert.equal(value.entries[0].net_minor,amount);
    assert.equal(value.accounts.find(x=>x.code==='merchant_unused_pending').amount_minor,'9007199254765993');
    await scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[journal,randomUUID(),'Local exactness cleanup']);
  });
  await check('H1 complete keyset pagination reconciles every owned bucket without duplicates or private counterparty fields',async()=>{
    const entries=[];let page=await read(f.merchant,f.shop,2),revision=page.revision;const summary=page.accounts;
    while(true) {
      assert.equal(page.revision,revision);assert.deepEqual(page.accounts,summary);entries.push(...page.entries);
      if(!page.next_before) break;
      page=await read(f.merchant,f.shop,2,page.next_before,revision);
    }
    assert.equal(new Set(entries.map(e=>e.id)).size,entries.length);assert.equal(String(entries.length),revision);
    for(const code of codes) {
      const sum=entries.flatMap(e=>e.movements).filter(m=>m.code===code).reduce((n,m)=>n+BigInt(m.amount_minor),0n);
      assert.equal(sum.toString(),summary.find(a=>a.code===code).amount_minor);
    }
    for(const entry of entries) {
      assert.deepEqual(Object.keys(entry).sort(),['id','kind','movements','net_minor','recorded_at','reverses']);
      assert(entry.movements.every(x=>codes.includes(x.code)));
      assert.equal(entry.movements.reduce((n,m)=>n+BigInt(m.amount_minor),0n).toString(),entry.net_minor);
    }
    const wire=JSON.stringify(entries);
    for(const secret of [f.customer.id,f.other.id,merchant,platform,'PRIVATE','evidence_ref','source_id','platform_clearing']) assert(!wire.includes(secret));
    const oracle=await db.query(`SELECT a.code,sum(p.amount_minor)::text amount_minor FROM public.ledger_accounts a
      JOIN public.ledger_postings p ON p.account_id=a.id WHERE party_id=$1 GROUP BY a.code ORDER BY a.code`,[merchant]);
    assert.deepEqual(oracle.rows,summary);
  });
  await check('H1 wrong owner, customer, null shop, foreign cursor and malformed pagination are rejected',async()=>{
    await assert.rejects(read(f.other),e=>e.code==='42501');
    await assert.rejects(read(f.customer),e=>e.code==='42501');
    await assert.rejects(read(f.merchant,null),e=>e.code==='42501');
    for(const limit of [null,0,-1,51]) await assert.rejects(read(f.merchant,f.shop,limit),e=>e.code==='22023');
    const page=await read(f.merchant,f.shop,2);
    for(const revision of [null,'','01','-1','1.0','1e2','1'.repeat(21)]) {
      await assert.rejects(read(f.merchant,f.shop,2,page.next_before,revision),e=>e.code==='22023');
    }
    await assert.rejects(read(f.merchant,f.shop,2,null,'0'),e=>e.code==='22023');
    await assert.rejects(read(f.merchant,f.shop,2,randomUUID(),page.revision),e=>e.code==='22023');
    const other=await read(f.other,f.otherShop);
    await assert.rejects(read(f.other,f.otherShop,2,original,other.revision),e=>e.code==='22023');
  });
  await check('H1 late commit invalidates old pagination even when its journal predates the first page read',async()=>{
    const id=await source('unused_package_fund','1'),writer=await connect(config);
    try {
      await writer.query('BEGIN');
      await writer.query('SELECT public.post_balanced_journal_v1($1,$2)',[id,JSON.stringify(lines({platform_clearing:-1,merchant_unused_pending:1}))]);
      const before=await read(f.merchant,f.shop,2);
      await writer.query('COMMIT');
      await assert.rejects(read(f.merchant,f.shop,2,before.next_before,before.revision),e=>e.code==='40001');
      const after=await read();assert.equal(BigInt(after.revision),BigInt(before.revision)+1n);
    } finally {await writer.query('ROLLBACK');await writer.end();}
  });
  await check('H1 concurrent journal commits cannot mix summary balances and history inside a response',async()=>{
    const writer=await connect(config);
    try {
      const idsToPost=[];
      for(let i=0;i<10;i++) idsToPost.push(await source('unused_package_fund','1'));
      await Promise.all([
        (async()=>{for(const id of idsToPost) await writer.query('SELECT public.post_balanced_journal_v1($1,$2)',[id,JSON.stringify(lines({platform_clearing:-1,merchant_unused_pending:1}))]);})(),
        (async()=>{for(let i=0;i<12;i++) {
          const value=await read(f.merchant,f.shop,50);
          assert.equal(value.next_before,null);assert.equal(value.revision,String(value.entries.length));
          for(const account of value.accounts) {
            const sum=value.entries.flatMap(e=>e.movements).filter(m=>m.code===account.code).reduce((n,m)=>n+BigInt(m.amount_minor),0n);
            assert.equal(sum.toString(),account.amount_minor);
          }
        }})(),
      ]);
    } finally {await writer.end();}
  });
  await check('H1 read RPC has no ledger effects; raw tables, config and RPC grants remain private',async()=>{
    const fingerprint=()=>scalar(`SELECT jsonb_build_array(
      (SELECT count(*) FROM public.ledger_sources),(SELECT count(*) FROM public.ledger_postings),
      (SELECT count(*) FROM public.ledger_journals),(SELECT count(*) FROM public.ledger_parties))::text`);
    const before=await fingerprint();await read();await read();assert.equal(await fingerprint(),before);
    for(const role of ['anon','service_role']) {
      assert.equal(await scalar("SELECT has_function_privilege($1,'public.read_merchant_statement_v1(uuid,integer,uuid,text)','EXECUTE')",[role]),false);
    }
    for(const role of ['anon','authenticated','service_role']) {
      for(const permission of ['SELECT','INSERT','UPDATE','DELETE']) assert.equal(
        await scalar("SELECT has_table_privilege($1,'public.merchant_statement_config',$2)",[role,permission]),false);
    }
    await assert.rejects(sqlAs(config,f.merchant,'SELECT * FROM public.ledger_postings'),e=>e.code==='42501');
    await assert.rejects(sqlAs(config,f.merchant,'UPDATE public.merchant_statement_config SET enabled=true'),e=>e.code==='42501');
  });
  await check('H1 live role, suspension and revoked Auth session block reads including stale cursors',async()=>{
    const page=await read(f.merchant,f.shop,2);
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.shop]);
    await assert.rejects(read(),e=>e.code==='42501');
    await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.shop]);
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
    await assert.rejects(read(),e=>e.code==='42501');
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]);
    const revoked=await f.session(f.merchant.id);
    await db.query('DELETE FROM auth.sessions WHERE id=$1',[revoked.claims.session_id]);
    await assert.rejects(read(revoked,f.shop,2,page.next_before,page.revision),e=>e.code==='28000');
  });
  await check('H1 either feature gate OFF removes balances and pagination without mutation',async()=>{
    const before=await read(f.merchant,f.shop,2);
    for(const table of ['merchant_statement_config','commerce_ledger_config']) {
      await db.query(`UPDATE public.${table} SET enabled=false`);
      const disabled=await read(f.merchant,f.shop,2,before.next_before,before.revision);
      assert.equal(disabled.enabled,false);assert.deepEqual(disabled.entries,[]);assert.deepEqual(disabled.accounts,[]);
      await db.query(`UPDATE public.${table} SET enabled=true`);
    }
    assert.equal((await read()).revision,before.revision);
  });
  return checks;
}

export async function statementHttpChecks({db,request,rpc,session,f,capture=true}) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const args={p_shop_id:f.shop,p_limit:2};
  await check('H1 HTTP owner projection and revision-bound pagination use real Auth/PostgREST',async()=>{
    const first=await rpc('read_merchant_statement_v1',f.merchant,args);
    assert(first.enabled);assert.equal(first.entries.length,2);assert.equal(first.settlement_enabled,false);
    const next=await rpc('read_merchant_statement_v1',f.merchant,{...args,p_before:first.next_before,p_revision:first.revision});
    assert.equal(next.revision,first.revision);assert.deepEqual(next.accounts,first.accounts);
    assert(!next.entries.some(e=>first.entries.some(old=>old.id===e.id)));
    // Only synthetic own-account projections, never Auth tokens or raw sources.
    if(capture) await writeFile(resolve(root,'docs/data/merchant_statement_h1_contract.json'),
      JSON.stringify({evidence_class:'synthetic-local-postgrest-read-projection',limit:2,first,next},null,2)+'\n');
    const bad=await request('/rest/v1/rpc/read_merchant_statement_v1',f.merchant,{...args,p_before:first.next_before,p_revision:'0'});
    assert.equal(bad.ok,false);assert.equal(bad.data.code,'40001');
  });
  await check('H1 HTTP guests, customers, other owners and raw ledger/config access are denied',async()=>{
    for(const actor of [null,f.customer,f.other]) assert.equal(
      (await request('/rest/v1/rpc/read_merchant_statement_v1',actor,args)).ok,false);
    for(const table of ['merchant_statement_config','ledger_sources','ledger_accounts','ledger_postings','ledger_journals']) {
      assert.equal((await request(`/rest/v1/${table}?select=*`,f.merchant,undefined,'GET')).ok,false);
    }
  });
  await check('H1 HTTP logout invalidates a still-signed token and default stop hides statement data',async()=>{
    const fresh=await session(f.merchant.id);
    assert.equal((await rpc('read_merchant_statement_v1',fresh,args)).enabled,true);
    assert.equal((await request('/auth/v1/logout?scope=local',fresh,{})).ok,true);
    const denied=await request('/rest/v1/rpc/read_merchant_statement_v1',fresh,args);
    assert.equal(denied.ok,false);assert.equal(denied.data.code,'28000');
    await db.query('UPDATE public.merchant_statement_config SET enabled=false');
    const off=await rpc('read_merchant_statement_v1',f.merchant,args);
    assert.equal(off.enabled,false);assert.deepEqual(off.accounts,[]);assert.deepEqual(off.entries,[]);
  });
  return checks;
}
