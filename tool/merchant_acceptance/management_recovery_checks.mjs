import assert from 'node:assert/strict';
import {createHash, randomUUID} from 'node:crypto';
import {readFile, writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {rpc} from './fixture.mjs';
import {root} from './local.mjs';

// Called only by the identity-checked local runners, after their populated F/G suite.
export async function managementUpgrade(db, evidenceClass) {
  assert.equal((await db.query("SELECT to_regprocedure('public.read_merchant_campaign_detail_v1(uuid,uuid)') p")).rows[0].p, null);
  const tables = ['merchant_campaigns','campaign_revisions','campaign_requests',
    'merchant_promotion_drafts','merchant_promotion_revisions','merchant_promotion_requests',
    'campaign_protocol_config','merchant_promotion_config'];
  const snapshot = async () => {
    const values = {};
    for (const table of tables) {
      const rows = (await db.query('SELECT to_jsonb(t) v FROM public.'+table+' t ORDER BY to_jsonb(t)::text')).rows;
      values[table] = {rows: rows.length, sha256: createHash('sha256').update(JSON.stringify(rows)).digest('hex')};
    }
    return values;
  };
  const before = await snapshot();
  assert(Object.values(before).every(v => v.rows > 0), 'Populated local F/G baseline required');
  const file = '20261017003100_0031_merchant_management_detail_reads.sql';
  const sql = await readFile(resolve(root,'supabase/migrations',file),'utf8');
  await db.query(sql);
  await db.query('INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES($1,$2,$3)',[file.split('_')[0],file.slice(15,-4),[]]);
  assert.deepEqual(await snapshot(),before);
  const migration = {file,sha256:createHash('sha256').update(sql).digest('hex')};
  await writeFile(resolve(root,`docs/data/merchant_management_${evidenceClass}_upgrade.json`),JSON.stringify({
    result:'PASS',evidence_class:evidenceClass+'-owned-local-populated-postgresql-upgrade',
    captured_at:new Date().toISOString(),tables_unchanged:before,migration,remote_access:'NONE',
  },null,2)+'\n');
  return migration;
}

export async function managementRecoveryChecks(db,config,f) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
  const call=(name,args,actor=f.merchant)=>rpc(config,actor,name,args);
  await db.query('UPDATE public.campaign_protocol_config SET enabled=true; UPDATE public.merchant_promotion_config SET enabled=true');
  const draft={title:'Local recovery draft',description:'Preserved draft',type:'announcement',scope:'all',listing_ids:[],image_ids:[],
    starts_at:new Date(Date.now()-60000).toISOString(),ends_at:new Date(Date.now()+3600000).toISOString(),price_minor:null,percentage_basis_points:null};
  const c=await call('mutate_campaign_v1',[f.shop,null,null,randomUUID(),'save',JSON.stringify(draft)]);
  const selection={family:'store',variant:0,listing_id:null,campaign_id:null,image_id:null};
  const preview=await call('preview_merchant_promotion_v1',[f.shop,JSON.stringify(selection)]);
  const p=await call('mutate_merchant_promotion_v1',[f.shop,null,null,randomUUID(),'save',JSON.stringify(selection),preview.fingerprint]);
  const cases=[['read_merchant_campaign_detail_v1',c.id,'campaign'],['read_merchant_promotion_detail_v1',p.id,'draft']];
  await check('management exact detail returns only owned current F/G projections',async()=>{
    for (const [name,id,field] of cases) {
      const value=await call(name,[f.shop,id]);assert.equal(value.shop_id,f.shop);assert(value.enabled);
      assert.equal(value[field].id,id);assert.equal(value[field].shop_id,f.shop);
      const helper=field==='campaign'?'_campaign_json_f':'_promotion_json_g';
      const expected=(await db.query(`SELECT public.${helper}($1,true) j`,[id])).rows[0].j;
      assert.deepEqual(value[field],expected);
      assert.equal((await call(name,[f.shop,randomUUID()]))[field],null);
      // A foreign record ID behaves exactly like missing; its existence is private.
      assert.equal((await call(name,[f.otherShop,id],f.other))[field],null);
      await assert.rejects(call(name,[f.shop,null]),e=>e.code==='22023');
    }
  });
  await check('management stale editors rebase explicitly using fresh revision; never overwrite silently',async()=>{
    const first=await call('read_merchant_campaign_detail_v1',[f.shop,c.id]);
    const other=await call('mutate_campaign_v1',[f.shop,c.id,c.revision_id,randomUUID(),'save',JSON.stringify({...draft,title:'Other editor'})]);
    await assert.rejects(call('mutate_campaign_v1',[f.shop,c.id,first.campaign.revision_id,randomUUID(),'save',JSON.stringify(draft)]),e=>e.message.includes('CAMPAIGN_CHANGED'));
    const fresh=await call('read_merchant_campaign_detail_v1',[f.shop,c.id]);assert.equal(fresh.campaign.title,'Other editor');
    assert.equal(fresh.campaign.revision_id,other.revision_id);
    const kept=await call('mutate_campaign_v1',[f.shop,c.id,fresh.campaign.revision_id,randomUUID(),'save',JSON.stringify({...draft,title:'Explicit preserved draft'})]);
    assert.equal((await call('read_merchant_campaign_detail_v1',[f.shop,c.id])).campaign.revision_id,kept.revision_id);
    const changed=await call('mutate_merchant_promotion_v1',[f.shop,p.id,p.revision_id,randomUUID(),'archive',null,null]);
    await assert.rejects(call('mutate_merchant_promotion_v1',[f.shop,p.id,p.revision_id,randomUUID(),'save',JSON.stringify(selection),preview.fingerprint]),e=>e.code==='40001');
    const freshPromotion=(await call('read_merchant_promotion_detail_v1',[f.shop,p.id])).draft;
    assert.equal(freshPromotion.status,'archived');assert.equal(freshPromotion.revision_id,changed.revision_id);
  });
  await check('management detail obeys feature gates and authorizes before gate disclosure',async()=>{
    await db.query('UPDATE public.campaign_protocol_config SET enabled=false; UPDATE public.merchant_promotion_config SET enabled=false');
    for (const [name,id,field] of cases) {
      const value=await call(name,[f.shop,id]);assert.equal(value.enabled,false);assert.equal(value[field],null);
      for (const actor of [f.other,f.customer]) await assert.rejects(call(name,[f.shop,id],actor),e=>e.code==='42501');
    }
    await db.query('UPDATE public.campaign_protocol_config SET enabled=true; UPDATE public.merchant_promotion_config SET enabled=true');
  });
  await check('management detail has live session, role and active-shop checks',async()=>{
    for (const [name,id] of cases) {
      const revoked=await f.session(f.merchant.id);
      await db.query('DELETE FROM auth.sessions WHERE id=$1',[revoked.claims.session_id]);
      await assert.rejects(call(name,[f.shop,id],revoked),e=>e.code==='28000');
      await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
      await assert.rejects(call(name,[f.shop,id]),e=>e.code==='42501');
      await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]);
      await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.shop]);
      await assert.rejects(call(name,[f.shop,id]),e=>e.code==='42501');
      await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.shop]);
    }
  });
  await check('management new RPCs grant authenticated execution only; reads have zero data side effects',async()=>{
    for(const [name] of cases) for (const role of ['anon','authenticated','service_role']) {
      assert.equal((await db.query('SELECT has_function_privilege($1,$2,\'EXECUTE\') p',[role,`public.${name}(uuid,uuid)`])).rows[0].p,role==='authenticated');
    }
    // Covers subject allocation as well as commerce, accounting and notifications.
    const tables=['review_subject_keys','merchant_campaigns','campaign_revisions','campaign_requests',
      'merchant_promotion_drafts','merchant_promotion_revisions','merchant_promotion_requests','ledger_journals','notifications'];
    const snapshot=async()=>{const out={};for(const table of tables)out[table]=(await db.query(`SELECT md5(coalesce(jsonb_agg(to_jsonb(t) ORDER BY to_jsonb(t)::text)::text,'[]')) h FROM public.${table} t`)).rows[0].h;return out;};
    const before=await snapshot();
    for(const [name,id] of cases) for(let i=0;i<3;i++)await call(name,[f.shop,id]);
    assert.deepEqual(await snapshot(),before);
  });
  return checks;
}

export async function managementRecoveryHttpChecks({db,request,rpc,session,f}) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
  const args={p_shop_id:f.shop}, selection={family:'store',variant:0,listing_id:null,campaign_id:null,image_id:null};
  let command,receipt;
  await check('management HTTP lost acknowledgement retry creates one promotion and one revision',async()=>{
    const preview=await rpc('preview_merchant_promotion_v1',f.merchant,{...args,p_selection:selection});
    command={...args,p_draft_id:null,p_expected_revision:null,p_request_id:randomUUID(),p_action:'save',p_selection:selection,p_fingerprint:preview.fingerprint};
    const lost=await rpc('mutate_merchant_promotion_v1',f.merchant,command);
    receipt=await rpc('mutate_merchant_promotion_v1',f.merchant,command);assert.deepEqual(receipt,lost);
    const detail=await rpc('read_merchant_promotion_detail_v1',f.merchant,{...args,p_draft_id:receipt.id});
    assert.equal(detail.draft.revision_id,receipt.revision_id);
    const history=await rpc('read_promotion_history_v1',f.merchant,{...args,p_draft_id:receipt.id});assert.equal(history.items.length,1);
  });
  await check('management HTTP conflict recovery requires current revision and a freshly grounded preview',async()=>{
    await rpc('mutate_merchant_promotion_v1',f.merchant,{...args,p_draft_id:receipt.id,p_expected_revision:receipt.revision_id,p_request_id:randomUUID(),p_action:'archive',p_selection:null,p_fingerprint:null});
    const failed=await request('/rest/v1/rpc/mutate_merchant_promotion_v1',f.merchant,{...command,p_draft_id:receipt.id,p_expected_revision:receipt.revision_id,p_request_id:randomUUID()});assert.equal(failed.data.code,'40001');
    const current=(await rpc('read_merchant_promotion_detail_v1',f.merchant,{...args,p_draft_id:receipt.id})).draft;assert.equal(current.status,'archived');
    await db.query("UPDATE public.shops SET name='Recovery updated shop' WHERE id=$1",[f.shop]);
    const stale=await request('/rest/v1/rpc/mutate_merchant_promotion_v1',f.merchant,{...command,p_draft_id:receipt.id,p_expected_revision:current.revision_id,p_request_id:randomUUID()});assert.equal(stale.data.code,'40001');
    const preview=await rpc('preview_merchant_promotion_v1',f.merchant,{...args,p_selection:selection});
    const kept=await rpc('mutate_merchant_promotion_v1',f.merchant,{...command,p_draft_id:receipt.id,p_expected_revision:current.revision_id,p_request_id:randomUUID(),p_fingerprint:preview.fingerprint});
    const restored=(await rpc('read_merchant_promotion_detail_v1',f.merchant,{...args,p_draft_id:receipt.id})).draft;
    assert.equal(restored.revision_id,kept.revision_id);assert.equal(restored.status,'draft');assert.equal(restored.snapshot.title,'Recovery updated shop');
    const history=(await rpc('read_promotion_history_v1',f.merchant,{...args,p_draft_id:receipt.id})).items;
    assert.equal(history.length,3);assert.notEqual(history[0].snapshot.title,history[2].snapshot.title);
  });
  let campaign;
  await check('management HTTP campaign save lost acknowledgement replays and recovers exact current draft',async()=>{
    const draft={title:'HTTP local campaign',description:'Synthetic',type:'announcement',scope:'all',listing_ids:[],image_ids:[],price_minor:null,percentage_basis_points:null,
      starts_at:new Date(Date.now()-60000).toISOString(),ends_at:new Date(Date.now()+3600000).toISOString()};
    const cmd={...args,p_campaign_id:null,p_expected_revision:null,p_request_id:randomUUID(),p_action:'save',p_draft:draft};
    campaign=await rpc('mutate_campaign_v1',f.merchant,cmd);assert.deepEqual(await rpc('mutate_campaign_v1',f.merchant,cmd),campaign);
    const detail=await rpc('read_merchant_campaign_detail_v1',f.merchant,{...args,p_campaign_id:campaign.id});
    assert.equal(detail.campaign.revision_id,campaign.revision_id);assert.equal(detail.campaign.title,draft.title);
    assert.equal(detail.campaign.active,false);
  });
  await check('management HTTP detail denies foreign/anonymous roles and actual logged-out Auth tokens',async()=>{
    const routes=[['read_merchant_campaign_detail_v1',{...args,p_campaign_id:campaign.id}],['read_merchant_promotion_detail_v1',{...args,p_draft_id:receipt.id}]];
    const loggedOut=await session(f.merchant.id);assert((await request('/auth/v1/logout?scope=local',loggedOut,{})).ok);
    for (const [name,params] of routes) {
      for (const actor of [null,f.other,f.customer]) assert.equal((await request('/rest/v1/rpc/'+name,actor,params)).ok,false);
      assert.equal((await request('/rest/v1/rpc/'+name,loggedOut,params)).data.code,'28000');
      const missing=await rpc(name,f.merchant,{...params,...(name.includes('campaign')?{p_campaign_id:randomUUID()}:{p_draft_id:randomUUID()})});
      assert.equal(missing[name.includes('campaign')?'campaign':'draft'],null);
    }
  });
  await check('management HTTP feature stop hides detail but exact committed receipt stays replayable',async()=>{
    await db.query('UPDATE public.campaign_protocol_config SET enabled=false; UPDATE public.merchant_promotion_config SET enabled=false');
    const c=await rpc('read_merchant_campaign_detail_v1',f.merchant,{...args,p_campaign_id:campaign.id});assert.equal(c.enabled,false);assert.equal(c.campaign,null);
    const p=await rpc('read_merchant_promotion_detail_v1',f.merchant,{...args,p_draft_id:receipt.id});assert.equal(p.enabled,false);assert.equal(p.draft,null);
    assert.deepEqual(await rpc('mutate_merchant_promotion_v1',f.merchant,command),receipt);
    await db.query('UPDATE public.campaign_protocol_config SET enabled=true; UPDATE public.merchant_promotion_config SET enabled=true');
  });
  return checks;
}
