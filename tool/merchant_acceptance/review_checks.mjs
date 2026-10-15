import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { rpc, sqlAs, connect } from './fixture.mjs';
import { contended } from './postgres_checks.mjs';

export async function reviewChecks(db, config, f) {
  const checks=[];
  const check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const call=(actor,name,args=[],options)=>rpc(config,actor,name,args,options);
  const service={friendliness:5,communication:4,cleanliness:3};
  const products=[f.product,randomUUID(),randomUUID()];
  for(const [i,id] of products.entries()) if(i) await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,8,$3)',[id,`Review product ${i}`,f.category]);
  const listings=new Map();
  for(const [shop,owner] of [[f.shop,f.merchant],[f.otherShop,f.other]]) for(const product of products) {
    const existing=(await db.query('SELECT id FROM public.shop_products WHERE shop_id=$1 AND product_id=$2',[shop,product])).rows[0];
    if(existing){listings.set(`${shop}:${product}`,existing.id);continue;}
    const id=randomUUID(); listings.set(`${shop}:${product}`,id);
    await sqlAs(config,owner,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12)',[id,shop,product]);
  }
  async function purchase({actor=f.customer,shop=f.shop,owner=f.merchant,items=[{product:products[0],quantity:3}],v2=false}={}) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[actor.id]);
    const cart=randomUUID();
    await sqlAs(config,actor,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,actor.id,shop]);
    for(const i of items) await sqlAs(config,actor,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,$3)',[cart,listings.get(`${shop}:${i.product}`),i.quantity]);
    const qr=await call(actor,v2?'create_qr_session_v2':'create_qr_session',[cart]);
    if(v2) {
      const claim=await call(owner,'claim_existing_qr_v2',[shop,owner.installation,randomUUID(),qr.session_token,null]);
      assert.equal(claim.status,'claimed');
      assert.equal((await call(owner,'complete_existing_qr_v2',[claim.claim_id,owner.installation])).status,'used');
    } else await call(owner,'confirm_qr_session',[qr.session_token]);
    return (await db.query('SELECT * FROM public.verified_transactions WHERE source_qr_session_id=$1',[qr.id])).rows[0];
  }
  const submit=(p,rows,criteria=service,id=randomUUID(),actor=f.customer,options)=>call(actor,'submit_purchase_evaluation_v2',
    [p.id,id,criteria,JSON.stringify(rows)],options);
  const row=(product=products[0],rating=5,comment='İyi bir alışveriş')=>({product_id:product,rating,comment});
  const state=id=>db.query('SELECT * FROM public.review_lifecycle WHERE review_id=$1',[id]).then(r=>r.rows[0]);
  const page=product=>call(f.customer,'get_product_reviews',[product,20,0]);
  const stats=()=>call(f.customer,'read_service_scores_v2',[f.shop]);
  let legacy, legacyRoot, first, root, firstRevision, second, third;
  const unsupportedRoot=randomUUID();
  await check('default OFF keeps legacy service and review APIs usable',async()=>{
    assert.equal((await call(f.customer,'review_capabilities_v2')).enabled,false);
    legacy=await purchase({items:[{product:products[2],quantity:1}]});
    await call(f.customer,'submit_verified_shop_rating',[legacy.source_qr_session_id,4]);
    legacyRoot=(await call(f.customer,'submit_product_review',[products[2],4,'Eski','Korunacak içerik'])).review.id;
    await db.query("UPDATE public.reviews SET created_at=clock_timestamp()-interval '3 days' WHERE id=$1",[legacyRoot]);
    await assert.rejects(submit(legacy,[]),/REVIEW_DISABLED/);
    // Synthetic pre-0009 fixture, never a runtime bypass or a hosted operation.
    await db.query('BEGIN');
    try {
      await db.query('ALTER TABLE public.reviews DISABLE TRIGGER enforce_product_review_evidence');
      await db.query("INSERT INTO public.reviews(id,user_id,product_id,rating,comment,created_at) VALUES($1,$2,$3,1,'Unsupported historical content',clock_timestamp()-interval '5 days')",[unsupportedRoot,f.customer.id,products[1]]);
      await db.query('ALTER TABLE public.reviews ENABLE TRIGGER enforce_product_review_evidence');await db.query('COMMIT');
    } catch(e){await db.query('ROLLBACK');throw e;}
    assert.equal((await db.query('SELECT public._review_import_legacy_c(10) n')).rows[0].n,2);
    assert.equal((await state(legacyRoot)).edit_until.getTime()<Date.now()-86400000,true);
  });
  await db.query('UPDATE public.review_protocol_config SET enabled=true');
  await assert.rejects(call(f.customer,'update_product_review',[legacyRoot,5,null,'Eski pencere']),/REVIEW_EDIT_CLOSED/);
  await check('unsupported legacy content stays private and withdrawal does not fabricate evidence',async()=>{
    assert.equal((await page(products[1])).reviews.length,0);
    assert.equal((await state(unsupportedRoot)).purchase_id,null);
    assert.equal((await call(f.customer,'delete_product_review',[unsupportedRoot])).withdrawn,true);
    await assert.rejects(call(f.customer,'update_product_review',[unsupportedRoot,5,null,null]),/REVIEW_EDIT_CLOSED/);
  });
  await check('quantity three gives one entitlement; a claim alone gives none',async()=>{
    first=await purchase();
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_entitlements WHERE purchase_id=$1',[first.id])).rows[0].n,1);
    const cart=randomUUID(); await sqlAs(config,f.customer,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,f.customer.id,f.shop]);
    await sqlAs(config,f.customer,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,listings.get(`${f.shop}:${products[0]}`)]);
    const qr=await call(f.customer,'create_qr_session',[cart]);
    await assert.rejects(call(f.customer,'read_purchase_evaluation_v2',[qr.id]),/REVIEW_NOT_VERIFIED/);
  });
  await check('initial service requires exactly three bounded criteria and is atomic with products',async()=>{
    for(const invalid of [null,{}, {friendliness:5}, {...service,cleanliness:null}, {...service,communication:6}, {...service,extra:1}])
      await assert.rejects(submit(first,[row()],invalid),/REVIEW_SERVICE_REQUIRED/);
    await assert.rejects(submit(first,[row(products[1])]),/REVIEW_NOT_VERIFIED/);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.service_evaluations WHERE purchase_id=$1',[first.id])).rows[0].n,0);
    await assert.rejects(call(f.customer,'submit_product_review',[products[0],5,null,null]),/REVIEW_USE_PURCHASE_EVALUATION/);
    await assert.rejects(call(f.customer,'submit_verified_shop_rating',[first.source_qr_session_id,5]),/REVIEW_USE_PURCHASE_EVALUATION/);
    await assert.rejects(submit(first,[row()],service,randomUUID(),f.other),/REVIEW_CUSTOMER_REQUIRED/);
  });
  await check('concurrent identical submissions yield one root, revision, service and fixed deadline',async()=>{
    const request=randomUUID();
    const results=await contended(db,options=>submit(first,[row()],service,request,f.customer,options),options=>submit(first,[row()],service,request,f.customer,options));
    assert(results.every(r=>r.status==='fulfilled')); assert.deepEqual(results[0].value,results[1].value);
    root=results[0].value.reviews[0].review_id; firstRevision=results[0].value.reviews[0].revision_id;
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_revisions WHERE review_id=$1',[root])).rows[0].n,1);
    assert.equal((await page(products[0])).review_count,1);
    await assert.rejects(submit(first,[row(products[0],1)],service,request),/REVIEW_REQUEST_CONFLICT/);
    await assert.rejects(submit(first,[row()]),/REVIEW_ENTITLEMENT_USED/);
    assert.equal((await stats()).sample_count,1); assert.equal((await stats()).average_rating,4);
    assert.equal((await db.query('SELECT rating_count FROM public.shops WHERE id=$1',[f.shop])).rows[0].rating_count,1);
  });
  await check('server ownership, direct-table privacy and immutable evidence are enforced',async()=>{
    await assert.rejects(call(f.other,'read_purchase_evaluation_v2',[first.id]));
    for(const table of ['reviews','review_lifecycle','review_revisions','review_subject_keys','service_evaluations','review_entitlements'])
      await assert.rejects(sqlAs(config,f.customer,`SELECT * FROM public.${table}`),e=>e.code==='42501');
    for(const name of ['_review_subject_c','_review_decrypt_c','_update_product_review_legacy_c']) {
      const privileges=(await db.query("SELECT has_function_privilege('authenticated',p.oid,'EXECUTE') granted FROM pg_proc p WHERE p.proname=$1",[name])).rows;
      assert(privileges.length && privileges.every(p=>!p.granted));
    }
    await assert.rejects(db.query('UPDATE public.review_revisions SET rating=1 WHERE id=$1',[firstRevision]),/append-only/);
    await assert.rejects(db.query('DELETE FROM public.service_evaluations WHERE purchase_id=$1',[first.id]),/append-only/);
    const publicRow=(await page(products[0])).reviews[0];
    assert.equal(publicRow.user_id,f.customer.id);
    const foreignPage=await call(f.other,'get_product_reviews',[products[0],20,0]);
    assert.equal(foreignPage.reviews[0].user_id,'00000000-0000-0000-0000-000000000000');
  });
  await check('edits append revisions without extending the deadline; identical edit retries are no-ops',async()=>{
    const before=await state(root);
    await call(f.customer,'update_product_review',[root,4,'Yeni','Düzenlenmiş']);
    await call(f.customer,'update_product_review',[root,4,'Yeni','Düzenlenmiş']);
    const after=await state(root); assert.equal(after.edit_until.toISOString(),before.edit_until.toISOString());
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_revisions WHERE review_id=$1',[root])).rows[0].n,2);
    assert.equal((await page(products[0])).average_rating,4);
  });
  await check('current revision and own source shop govern one merchant reply and report',async()=>{
    const revision=(await state(root)).current_revision_id;
    await assert.rejects(call(f.other,'reply_to_review_v2',[f.otherShop,root,revision,randomUUID(),'Yanıt']),/REVIEW_SHOP_FORBIDDEN/);
    await assert.rejects(call(f.merchant,'reply_to_review_v2',[f.shop,root,firstRevision,randomUUID(),'Yanıt']),/REVIEW_CHANGED/);
    const request=randomUUID(),args=[f.shop,root,revision,request,'Teşekkür ederiz.'];
    const results=await contended(db,options=>call(f.merchant,'reply_to_review_v2',args,options),options=>call(f.merchant,'reply_to_review_v2',args,options));
    assert(results.every(r=>r.status==='fulfilled'));assert.deepEqual(results[0].value,results[1].value);
    await assert.rejects(call(f.merchant,'reply_to_review_v2',[f.shop,root,revision,randomUUID(),'İkinci yanıt']),/REVIEW_ALREADY_REPLIED/);
    assert.equal((await page(products[0])).reviews[0].merchant_reply,'Teşekkür ederiz.');
    await call(f.merchant,'review_action_v2',[root,revision,randomUUID(),'report','İnceleme isteği',f.shop]);
    assert.equal((await call(f.merchant,'read_merchant_reviews_v2',[f.shop,'reported',20,0])).total,1);
    await assert.rejects(call(f.merchant,'review_action_v2',[root,revision,randomUUID(),'hide','Yetkisiz',f.shop]),/REVIEW_ADMIN_REQUIRED/);
  });
  await check('24-hour boundary is checked after contended locks; withdrawal remains available',async()=>{
    const results=await contended(db,async options=>{
      const c=await connect(config);try{await c.query('BEGIN');await c.query('SELECT id FROM public.products WHERE id=$1 FOR UPDATE',[products[0]]);
        await c.query('UPDATE public.review_lifecycle SET edit_until=clock_timestamp() WHERE review_id=$1',[root]);await options.hold(c);await c.query('COMMIT');return true;
      }finally{await c.end();}},options=>call(f.customer,'update_product_review',[root,1,null,'Geç'],options));
    assert.equal(results[1].status,'rejected');assert.match(results[1].reason.message,/REVIEW_EDIT_CLOSED/);
    assert.equal((await call(f.customer,'delete_product_review',[root])).withdrawn,true);
    assert.equal((await page(products[0])).review_count,0);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.reviews WHERE id=$1',[root])).rows[0].n,1);
    assert.equal((await call(f.customer,'delete_product_review',[root])).withdrawn,true);
    assert.equal((await db.query("SELECT count(*)::int n FROM public.review_events WHERE review_id=$1 AND event_kind='withdraw'",[root])).rows[0].n,1);
  });
  await check('newer purchase reopens the same root; legacy evidence FK and single public count survive',async()=>{
    second=await purchase({shop:f.otherShop,owner:f.other});
    const original=(await db.query('SELECT verified_transaction_item_id FROM public.reviews WHERE id=$1',[root])).rows[0].verified_transaction_item_id;
    const receipt=await submit(second,[row(products[0],2)],{friendliness:2,communication:2,cleanliness:2});
    assert.equal(receipt.reviews[0].review_id,root);assert.equal(receipt.reviews[0].kind,'reopen');
    assert.equal((await page(products[0])).review_count,1);assert.equal((await page(products[0])).average_rating,2);
    assert.equal((await page(products[0])).reviews[0].merchant_reply,null);
    assert.equal((await db.query('SELECT verified_transaction_item_id FROM public.reviews WHERE id=$1',[root])).rows[0].verified_transaction_item_id,original);
    const revision=(await state(root)).current_revision_id;
    await assert.rejects(call(f.merchant,'reply_to_review_v2',[f.shop,root,revision,randomUUID(),'Eski mağaza']),/REVIEW_SHOP_FORBIDDEN/);
    await assert.rejects(call(f.other,'reply_to_review_v2',[f.otherShop,root,revision,randomUUID(),'Yeni mağaza']),/REVIEW_ALREADY_REPLIED/);
    assert((await call(f.merchant,'read_merchant_reviews_v2',[f.shop,'all',20,0])).reviews.every(r=>r.review_id!==root));
  });
  await check('three distinct products allow three roots and one immutable service evaluation',async()=>{
    third=await purchase({items:products.map(product=>({product,quantity:3}))});
    const input=await call(f.customer,'read_purchase_evaluation_v2',[third.id]);assert.equal(input.products.length,3);assert.equal(input.service,null);
    await submit(third,[row(products[0],5)],{friendliness:3,communication:3,cleanliness:3});
    await submit(third,[row(products[1],4),row(products[2],3)],null);
    const result=await call(f.customer,'read_purchase_evaluation_v2',[third.id]);assert(result.products.every(p=>!p.can_submit));
    assert.equal((await db.query('SELECT count(*)::int n FROM public.service_evaluations WHERE purchase_id=$1',[third.id])).rows[0].n,1);
    assert.equal((await stats()).sample_count,1);assert.equal((await stats()).average_rating,3);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.shop_ratings WHERE customer_user_id=$1',[f.customer.id])).rows[0].n,1);
    const upgraded=(await page(products[1])).reviews[0];assert.equal(upgraded.id,unsupportedRoot);assert.equal(upgraded.is_verified_purchase,true);
    assert.equal((await db.query('SELECT verified_transaction_item_id FROM public.reviews WHERE id=$1',[unsupportedRoot])).rows[0].verified_transaction_item_id,null);
  });
  let admin;
  await check('reasoned admin moderation hides and restores projections without rewriting history',async()=>{
    admin=await f.session();await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[admin.id]);
    const revision=(await state(root)).current_revision_id;
    const action=(kind,reason='Yerel inceleme')=>call(admin,'review_action_v2',[root,revision,randomUUID(),kind,reason,null]);
    await assert.rejects(action('hide',''),/REVIEW_INVALID_ARGUMENT/);
    await action('under_review');assert.equal((await page(products[0])).review_count,0);
    await action('hide');assert.equal((await page(products[0])).reviews.length,0);
    assert.equal((await db.query('SELECT rating FROM public.products WHERE id=$1',[products[0]])).rows[0].rating,'0.0');
    await action('flag_abuse');assert.equal((await state(root)).abuse_flagged,true);
    await action('restore');assert.equal((await page(products[0])).review_count,1);
    assert.equal((await stats()).sample_count,1);
    await action('hide_reply');assert.equal((await page(products[0])).reviews[0].merchant_reply,null);
    assert.equal((await state(root)).current_revision_id,revision);
    const audit=await call(admin,'read_review_audit_v2',[root,50,0]);
    assert(audit.events.some(e=>e.event_kind==='hide' && e.reason.reason==='Yerel inceleme'));
    assert(audit.revisions.some(r=>r.body.comment==='İyi bir alışveriş'));
    await assert.rejects(call(f.merchant,'read_review_audit_v2',[root,50,0]),/REVIEW_ADMIN_REQUIRED/);
  });
  await check('fraud invalidation removes current evidence and falls back to earlier valid service evaluation',async()=>{
    await call(admin,'invalidate_purchase_v2',[third.id,randomUUID(),'Yerel sahte işlem testi']);
    assert.equal((await page(products[0])).review_count,0);
    assert.equal((await stats()).sample_count,1);assert.equal((await stats()).average_rating,4);
    assert.equal((await call(f.customer,'read_purchase_evaluation_v2',[third.id])).valid,false);
    await assert.rejects(call(f.customer,'update_product_review',[root,1,null,null]),/REVIEW_EDIT_CLOSED/);
  });
  await check('a genuine full return preserves service and product experience evidence',async()=>{
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
    const bought=await purchase({v2:true});await submit(bought,[row()],service);
    const item=(await db.query('SELECT id,quantity FROM public.verified_transaction_items WHERE verified_transaction_id=$1',[bought.id])).rows[0];
    await call(f.merchant,'record_purchase_return_v2',[bought.id,randomUUID(),[{purchase_item_id:item.id,quantity:item.quantity}],'Gerçek iade',f.merchant.installation,null]);
    assert.equal((await call(f.customer,'read_purchase_evaluation_v2',[bought.id])).valid,true);
    assert.equal((await page(products[0])).review_count,1);assert.equal((await stats()).average_rating,4);
    await db.query('UPDATE public.qr_protocol_config SET enabled=false');
  });
  await check('independent customers contend safely and each contributes once to cached public scores',async()=>{
    const customer=await f.session(),bought=await purchase({actor:customer});
    const before=await state(root);
    const results=await contended(db,
      options=>call(f.customer,'update_product_review',[root,4,null,'Güncel'],options),
      options=>submit(bought,[row(products[0],2)],{friendliness:2,communication:2,cleanliness:2},randomUUID(),customer,options));
    assert(results.every(r=>r.status==='fulfilled'));
    assert.equal((await page(products[0])).review_count,2);assert.equal((await page(products[0])).average_rating,3);
    assert.equal((await stats()).sample_count,2);assert.equal((await stats()).average_rating,3);
    assert.equal((await db.query('SELECT rating,reviews_count FROM public.products WHERE id=$1',[products[0]])).rows[0].reviews_count,2);
    assert.equal((await state(root)).edit_until.toISOString(),before.edit_until.toISOString());
    await call(customer,'delete_current_customer_account');
    assert.equal((await stats()).sample_count,1);
  });
  await check('legacy adoption preserves old deadline and never invents three service criteria',async()=>{
    // Product 2 now uses a newer root revision; the original imported revision remains old.
    const imported=(await db.query("SELECT source_created_at FROM public.review_revisions WHERE review_id=$1 AND revision_kind='legacy_import'",[legacyRoot])).rows[0];
    assert(imported && imported.source_created_at.getTime()<Date.now()-2*86400000);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.service_evaluations WHERE purchase_id=$1',[legacy.id])).rows[0].n,0);
    const next=await purchase();await submit(next,[row()],service);
    await db.query('UPDATE public.review_protocol_config SET enabled=false');
    await assert.rejects(call(f.customer,'submit_product_review',[products[0],1,null,null]),/REVIEW_USE_PURCHASE_EVALUATION/);
    await db.query('UPDATE public.review_lifecycle SET edit_until=clock_timestamp() WHERE review_id=$1',[root]);
    await assert.rejects(call(f.customer,'update_product_review',[root,1,null,null]),/REVIEW_EDIT_CLOSED/);
    assert.equal((await call(f.customer,'delete_product_review',[root])).withdrawn,true);
    await db.query('UPDATE public.review_protocol_config SET enabled=true');
  });
  await check('authorized self-delete erases public text and subject key without losing immutable commerce facts',async()=>{
    const subject=(await db.query('SELECT subject_id FROM public.review_subject_keys WHERE user_id=$1',[f.customer.id])).rows[0].subject_id;
    const countBefore=(await db.query('SELECT count(*)::int n FROM public.review_revisions WHERE subject_id=$1',[subject])).rows[0].n;
    const purchasesBefore=(await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE customer_user_id=$1',[f.customer.id])).rows[0].n;
    await call(f.customer,'delete_current_customer_account');
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_subject_keys WHERE subject_id=$1',[subject])).rows[0].n,0);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.reviews WHERE user_id=$1',[f.customer.id])).rows[0].n,0);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_revisions WHERE subject_id=$1',[subject])).rows[0].n,countBefore);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE customer_user_id=$1',[f.customer.id])).rows[0].n,purchasesBefore);
    assert.equal((await db.query('SELECT public._review_decrypt_c(subject_id,encrypted_body) body FROM public.review_revisions WHERE id=$1',[firstRevision])).rows[0].body,null);
    assert.equal((await call(f.merchant,'read_service_scores_v2',[f.shop])).sample_count,0);
    await assert.rejects(call(f.customer,'read_purchase_evaluation_v2',[first.id]),e=>e.code==='28000');
  });
  return checks;
}
