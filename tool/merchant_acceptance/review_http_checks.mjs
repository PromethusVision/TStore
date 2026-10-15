import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

export async function reviewHttpChecks({db,request,rpc,actor,session,f}){
  const checks=[];
  const check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const customer=await session(f.customer.id),merchant=await session(f.merchant.id),other=await session(f.other.id);
  const service={friendliness:5,communication:4,cleanliness:3};
  const purchase=(await db.query('SELECT id FROM public.verified_transactions WHERE customer_user_id=$1 ORDER BY confirmed_at DESC LIMIT 1',[customer.id])).rows[0];
  assert(purchase);
  let root,revision;
  await check('HTTP C service criteria, initial product submission, exact retry and minimized public read',async()=>{
    const bad=await request('/rest/v1/rpc/submit_purchase_evaluation_v2',customer,{p_purchase_id:purchase.id,p_request_id:randomUUID(),p_products:[]});
    assert.equal(bad.ok,false);assert.match(bad.data.message,/REVIEW_SERVICE_REQUIRED/);
    const args={p_purchase_id:purchase.id,p_request_id:randomUUID(),p_service:service,p_products:[{product_id:f.product,rating:4,comment:'Gerçek HTTP değerlendirmesi'}]};
    const result=await rpc('submit_purchase_evaluation_v2',customer,args);
    assert.deepEqual(await rpc('submit_purchase_evaluation_v2',customer,args),result);
    root=result.reviews[0].review_id;revision=result.reviews[0].revision_id;
    const publicPage=await rpc('get_product_reviews',null,{p_product_id:f.product});
    assert.equal(publicPage.review_count,1);assert.equal(publicPage.reviews[0].rating,4);
    assert.equal(publicPage.reviews[0].user_id,'00000000-0000-0000-0000-000000000000');
    assert.equal(publicPage.reviews[0].can_edit,false);assert.equal(publicPage.reviews[0].is_verified_purchase,true);
    const rights=await rpc('get_product_review_eligibility',customer,{p_product_id:f.product});
    assert.equal(rights.review_version,2);assert.equal(rights.own_review.can_edit,true);assert.equal(rights.can_reopen,false);
    for(const table of ['reviews','review_revisions','review_subject_keys','review_events']){
      assert.equal((await request(`/rest/v1/${table}?select=*`,customer,undefined,'GET')).ok,false);
    }
    const summary=await rpc('read_merchant_reviews_v2',merchant,{p_shop_id:f.shop});
    assert.equal(summary.scores.sample_count,1);assert.equal(summary.scores.average_rating,4);assert.equal(summary.awaiting_reply_count,1);
    const history=await rpc('read_customer_service_evaluations_v2',customer,{p_purchase_ids:[purchase.id,randomUUID()]});
    assert.equal(history.length,1);assert.equal(history[0].friendliness,5);assert.equal(history[0].valid,true);
    assert.equal((await request('/rest/v1/rpc/read_customer_service_evaluations_v2',other,{p_purchase_ids:[purchase.id]})).ok,false);
  });
  await check('HTTP C merchant origin ownership, one reply and reasoned private report',async()=>{
    const args={p_shop_id:f.shop,p_review_id:root,p_revision_id:revision,p_request_id:randomUUID(),p_text:'Teşekkür ederiz.'};
    assert.equal((await request('/rest/v1/rpc/reply_to_review_v2',other,args)).ok,false);
    const reply=await rpc('reply_to_review_v2',merchant,args);assert.deepEqual(await rpc('reply_to_review_v2',merchant,args),reply);
    assert.equal((await request('/rest/v1/rpc/reply_to_review_v2',merchant,{...args,p_request_id:randomUUID()})).ok,false);
    await rpc('review_action_v2',merchant,{p_shop_id:f.shop,p_review_id:root,p_revision_id:revision,p_request_id:randomUUID(),p_action:'report',p_reason:'Yerel rapor testi'});
    const page=await rpc('get_product_reviews',null,{p_product_id:f.product});assert.equal(page.reviews[0].merchant_reply,'Teşekkür ederiz.');
    assert(!JSON.stringify(page).includes('Yerel rapor testi'));
  });
  const admin=await actor();await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[admin.id]);
  await check('HTTP C moderation hides/restores public averages and exposes audit only to admin',async()=>{
    const action=kind=>({p_review_id:root,p_revision_id:revision,p_request_id:randomUUID(),p_action:kind,p_reason:'Yerel moderasyon testi'});
    assert.equal((await request('/rest/v1/rpc/review_action_v2',customer,action('hide'))).ok,false);
    await rpc('review_action_v2',admin,action('hide'));assert.equal((await rpc('get_product_reviews',null,{p_product_id:f.product})).review_count,0);
    await rpc('review_action_v2',admin,action('restore'));assert.equal((await rpc('get_product_reviews',null,{p_product_id:f.product})).review_count,1);
    assert.equal((await request('/rest/v1/rpc/read_review_audit_v2',merchant,{p_review_id:root})).ok,false);
    const audit=await rpc('read_review_audit_v2',admin,{p_review_id:root});assert(audit.events.some(e=>e.event_kind==='hide'));
  });
  await check('HTTP C cross-shop purchase reopens the same root without carrying the old shop reply',async()=>{
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[customer.id]);
    const cart=randomUUID(),listing=(await db.query('SELECT id FROM public.shop_products WHERE shop_id=$1 AND product_id=$2',[f.otherShop,f.product])).rows[0].id;
    assert.equal((await request('/rest/v1/carts',customer,{id:cart,user_id:customer.id,shop_id:f.otherShop})).ok,true);
    assert.equal((await request('/rest/v1/cart_items_v2',customer,{cart_id:cart,shop_product_id:listing,quantity:3})).ok,true);
    const q=await rpc('create_qr_session_v2',customer,{p_cart_id:cart});
    const claim=await rpc('claim_existing_qr_v2',other,{p_shop_id:f.otherShop,p_installation_id:other.installation,p_request_id:randomUUID(),p_manual_code:q.manual_code});assert.equal(claim.status,'claimed');
    const done=await rpc('complete_existing_qr_v2',other,{p_claim_id:claim.claim_id,p_installation_id:other.installation});assert.equal(done.status,'used');
    const eligibility=await rpc('get_product_review_eligibility',customer,{p_product_id:f.product});assert.equal(eligibility.can_reopen,true);assert.equal(eligibility.verified_transaction_id,done.purchase_id);
    const result=await rpc('submit_purchase_evaluation_v2',customer,{p_purchase_id:done.purchase_id,p_request_id:randomUUID(),p_service:service,p_products:[{product_id:f.product,rating:5,comment:'Yeni mağaza'}]});
    assert.equal(result.reviews[0].review_id,root);
    const page=await rpc('get_product_reviews',null,{p_product_id:f.product});assert.equal(page.review_count,1);assert.equal(page.average_rating,5);assert.equal(page.reviews[0].merchant_reply,null);
  });
  await check('HTTP C expired editing cannot bypass old RPCs; withdrawal survives and logout denies writes',async()=>{
    await db.query('UPDATE public.review_lifecycle SET edit_until=clock_timestamp() WHERE review_id=$1',[root]);
    const denied=await request('/rest/v1/rpc/update_product_review',customer,{p_review_id:root,p_rating:1});assert.equal(denied.ok,false);assert.match(denied.data.message,/REVIEW_EDIT_CLOSED/);
    assert.equal((await rpc('delete_product_review',customer,{p_review_id:root})).withdrawn,true);
    assert.equal((await rpc('get_product_reviews',null,{p_product_id:f.product})).review_count,0);
    assert.equal((await request('/auth/v1/logout?scope=local',customer,undefined)).ok,true);
    const stale=await request('/rest/v1/rpc/delete_product_review',customer,{p_review_id:root});assert.equal(stale.ok,false);assert.equal(stale.data.code,'28000');
  });
  await check('HTTP C real Auth account deletion erases decryptable review text and preserves commerce audit',async()=>{
    const fresh=await session(customer.id);
    const subject=(await db.query('SELECT subject_id FROM public.review_subject_keys WHERE user_id=$1',[customer.id])).rows[0].subject_id;
    await rpc('delete_current_customer_account',fresh,{});
    assert.equal((await db.query('SELECT count(*)::int n FROM auth.users WHERE id=$1',[customer.id])).rows[0].n,0);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.review_subject_keys WHERE subject_id=$1',[subject])).rows[0].n,0);
    assert((await db.query('SELECT count(*)::int n FROM public.review_revisions WHERE subject_id=$1',[subject])).rows[0].n>0);
    assert.equal((await db.query('SELECT public._review_decrypt_c(subject_id,encrypted_body) body FROM public.review_revisions WHERE id=$1',[revision])).rows[0].body,null);
    assert.equal((await rpc('read_service_scores_v2',null,{p_shop_id:f.shop})).sample_count,0);
  });
  return checks;
}
