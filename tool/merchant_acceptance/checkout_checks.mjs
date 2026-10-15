import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {rpc,sqlAs} from './fixture.mjs';
import {contended} from './postgres_checks.mjs';

export async function checkoutChecks(db,config,f) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const scalar=async(sql,args=[])=>Object.values((await db.query(sql,args)).rows[0])[0];
  const call=(actor,name,args=[],options)=>rpc(config,actor,name,args,options);
  const state=(customer=f.customer)=>call(customer,'read_reward_state_v1');
  const classify=value=>scalar('SELECT public.attest_reward_product_classification_v1($1,$2,$3,$4)',[f.product,value,'local-fixture-only','Synthetic test classification']);
  const count=table=>scalar(`SELECT count(*)::int FROM public.${table}`);
  f.listing=randomUUID();
  await sqlAs(config,f.merchant,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,500)',[f.listing,f.shop,f.product]);
  async function cart(price=500,qty=1,customer=f.customer) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[customer.id]);
    await db.query('DELETE FROM public.qr_attempt_limits');
    await db.query('UPDATE public.shop_products SET price=$2 WHERE id=$1',[f.listing,price]);
    const id=randomUUID();
    await sqlAs(config,customer,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[id,customer.id,f.shop]);
    await sqlAs(config,customer,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,$3)',[id,f.listing,qty]);
    return id;
  }
  const claim=q=>call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
  async function earn(customer=f.customer) {
    const q=await call(customer,'create_reward_qr_v1',[await cart(500,1,customer)]),c=await claim(q);
    assert.equal(c.status,'claimed',JSON.stringify(c));
    const done=await call(f.merchant,'complete_reward_qr_v1',[c.claim_id,f.merchant.installation,'50000']);
    assert.equal(done.status,'used');return done.purchase_id;
  }
  async function mature() {
    await db.query(`BEGIN; ALTER TABLE public.reward_contributions DISABLE TRIGGER reward_immutable;
      UPDATE public.reward_contributions SET earned_at=earned_at-interval '2 days',matures_at=matures_at-interval '2 days';
      ALTER TABLE public.reward_contributions ENABLE TRIGGER reward_immutable; COMMIT`);
  }
  async function approve(amount,price=500,qty=1,customer=f.customer) {
    const id=await cart(price,qty,customer),p=await call(customer,'preview_coupon_checkout_v1',[id]);
    const args=[id,randomUUID(),p.fingerprint,String(amount)];
    const q=await call(customer,'create_coupon_qr_v1',args);return {q,p,args};
  }
  const complete=c=>call(f.merchant,'complete_coupon_qr_v1',[c.claim_id,f.merchant.installation,c.coupon_checkout.sale_minor,c.coupon_checkout.coupon_minor,c.coupon_checkout.payment_minor]);
  async function invalidate(purchase) {
    await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[f.other.id]);
    const args=[purchase,randomUUID(),'Synthetic audited invalidation'];
    await call(f.other,'invalidate_purchase_v2',args);await call(f.other,'invalidate_purchase_v2',args);
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.other.id]);
  }
  await check('Checkout default OFF, unknown classification and all private data/functions deny client access',async()=>{
    assert.equal((await call(f.customer,'coupon_checkout_capabilities_v1')).enabled,false);
    for(const role of ['anon','authenticated','service_role']) {
      for(const table of ['reward_checkout_config','reward_product_classifications','reward_checkout_approvals','reward_coupon_redemptions','reward_source_uses','reward_spent_offsets']) {
        assert.equal(await scalar("SELECT has_table_privilege($1,'public.'||$2,'SELECT,INSERT,UPDATE,DELETE')",[role,table]),false);
      }
      for(const name of ['attest_reward_product_classification_v1','_checkout_purchase_terms_e','_checkout_recover_mature_e','_complete_reward_qr_before_checkout','_reward_compensate_before_checkout']) {
        assert.equal(await scalar("SELECT has_function_privilege($1,p.oid,'EXECUTE') FROM pg_proc p WHERE p.pronamespace='public'::regnamespace AND p.proname=$2",[role,name]),false);
      }
    }
    await db.query('UPDATE public.reward_program_config SET enabled=true; UPDATE public.commerce_ledger_config SET enabled=true; UPDATE public.qr_protocol_config SET enabled=true');
    await scalar('SELECT public.activate_referral_package_v1($1,$2,$3,$4,$5)',[f.shop,randomUUID(),randomUUID(),randomUUID(),'575000']);
  });
  const sources=[];
  for(let i=0;i<5;i++) sources.push(await earn());
  await mature();assert.equal((await state()).coupon_minor,'25000');
  await check('Checkout eligibility is explicit, unknown/cash-equivalent fails closed and gate-off cannot authorize',async()=>{
    const id=await cart();let p=await call(f.customer,'preview_coupon_checkout_v1',[id]);
    assert.equal(p.maximum_coupon_minor,'0');assert.equal(p.eligibility,'classification_unavailable');
    await assert.rejects(call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),p.fingerprint,'25000']),/CHECKOUT_DISABLED/);
    await db.query('UPDATE public.reward_checkout_config SET enabled=true');
    await classify('cash_equivalent');p=await call(f.customer,'preview_coupon_checkout_v1',[id]);assert.equal(p.maximum_coupon_minor,'0');
    await classify('ordinary');p=await call(f.customer,'preview_coupon_checkout_v1',[id]);assert.equal(p.maximum_coupon_minor,'25000');
    await assert.rejects(call(f.other,'preview_coupon_checkout_v1',[id]),e=>e.code==='42501');
    await assert.rejects(call(f.merchant,'preview_coupon_checkout_v1',[id]),e=>e.code==='42501');
  });
  await check('Checkout stale price/quantity/classification fingerprint and malformed/over-limit approvals leave no QR consent',async()=>{
    const id=await cart(),p=await call(f.customer,'preview_coupon_checkout_v1',[id]),before=await count('reward_checkout_approvals');
    for(const value of [null,'','0','-1','1.5','01','25001','99999999999999999999']) {
      await assert.rejects(call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),p.fingerprint,value]));
    }
    await classify('ordinary');await assert.rejects(call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),p.fingerprint,'25000']),/CHECKOUT_QUOTE_CHANGED/);
    const fresh=await call(f.customer,'preview_coupon_checkout_v1',[id]);
    await db.query('UPDATE public.shop_products SET price=501 WHERE id=$1',[f.listing]);
    await assert.rejects(call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),fresh.fingerprint,'25000']),/CHECKOUT_QUOTE_CHANGED/);
    assert.equal(await count('reward_checkout_approvals'),before);
  });
  let checkout,claimed,purchase;
  await check('Checkout concurrent exact approval creates one immutable QR; request change and post-exposure retrofit fail',async()=>{
    const id=await cart(750),p=await call(f.customer,'preview_coupon_checkout_v1',[id]),args=[id,randomUUID(),p.fingerprint,'25000'];
    const results=await contended(db,o=>call(f.customer,'create_coupon_qr_v1',args,o),o=>call(f.customer,'create_coupon_qr_v1',args,o));
    assert(results.every(r=>r.status==='fulfilled'),JSON.stringify(results));checkout=results[0].value;
    assert.equal(checkout.id,results[1].value.id);assert.equal(checkout.coupon_checkout.payment_minor,'50000');
    const recovered=await call(f.customer,'preview_coupon_checkout_v1',[id]);assert.equal(recovered.existing_qr.id,checkout.id);
    assert.equal(recovered.maximum_coupon_minor,'0');
    await assert.rejects(call(f.customer,'create_coupon_qr_v1',[...args.slice(0,3),'24999']),/CHECKOUT_REPLAY_CONFLICT/);
    await assert.rejects(call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),p.fingerprint,'25000']),/CHECKOUT_EXISTING_QR/);
    await assert.rejects(db.query('UPDATE public.reward_checkout_approvals SET coupon_minor=1 WHERE qr_ref=$1',[checkout.id]),/append-only/);
    claimed=await claim(checkout);assert.equal(claimed.status,'claimed',JSON.stringify(claimed));
  });
  await check('Checkout requires all three exact merchant attestations and rejects old completion endpoints',async()=>{
    await assert.rejects(call(f.merchant,'complete_existing_qr_v2',[claimed.claim_id,f.merchant.installation]),/REWARD_CONFIRMATION_REQUIRED/);
    await assert.rejects(call(f.merchant,'complete_reward_qr_v1',[claimed.claim_id,f.merchant.installation,'75000']),/CHECKOUT_CONFIRMATION_REQUIRED/);
    const correct=['75000','25000','50000'];
    for(let position=0;position<3;position++)for(const value of [null,'','0','1','75000.0','075000']) {
      const values=[...correct];values[position]=value;
      await assert.rejects(call(f.merchant,'complete_coupon_qr_v1',[claimed.claim_id,f.merchant.installation,...values]),/CHECKOUT_ATTESTATION_MISMATCH/);
    }
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[checkout.id]),0);
  });
  await check('Checkout ledger failure rolls back purchase, coupon debit, receivable and earning; 750 minus 250 earns atomically',async()=>{
    await db.query('UPDATE public.commerce_ledger_config SET enabled=false');await assert.rejects(complete(claimed),/LEDGER_DISABLED/);
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[checkout.id]),0);
    await db.query('UPDATE public.commerce_ledger_config SET enabled=true');
    const results=await contended(db,o=>call(f.merchant,'complete_coupon_qr_v1',[claimed.claim_id,f.merchant.installation,'75000','25000','50000'],o),
      o=>call(f.merchant,'complete_coupon_qr_v1',[claimed.claim_id,f.merchant.installation,'75000','25000','50000'],o));
    assert(results.every(r=>r.status==='fulfilled'),JSON.stringify(results));purchase=results[0].value.purchase_id;
    assert.equal(results[1].value.purchase_id,purchase);assert.equal((await state()).coupon_minor,'0');assert.equal((await state()).pending_count,1);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_coupon_redemptions WHERE purchase_id=$1',[purchase]),1);
    assert.equal(await scalar("SELECT public._ledger_balance_h0(a.id)::text FROM public.ledger_accounts a JOIN public.ledger_parties p ON p.id=a.party_id WHERE p.shop_id=$1 AND a.code='merchant_reserve'",[f.shop]),'25000');
    const e=await call(f.merchant,'read_purchase_evidence_v2',[purchase]);
    assert.deepEqual([e.terms_classification,e.final_sale_minor,e.ev_coupon_minor,e.customer_payment_minor],['coupon_checkout_e_v1','75000','25000','50000']);
    assert.equal(e.coupon_restoration_executed,false);
    const recovered=await call(f.customer,'preview_coupon_checkout_v1',[checkout.cart_id]);assert.equal(recovered.existing_qr.status,'used');assert.equal(recovered.existing_qr.purchase_id,purchase);
  });
  await check('Checkout spent-source fraud creates one non-cash future offset, restores original fund and retains five source links',async()=>{
    await invalidate(sources[0]);const s=await state();assert.equal(s.coupon_minor,'0');assert.equal(s.future_offset_minor,'5000');
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_spent_offsets WHERE source_purchase=$1',[sources[0]]),1);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_coupon_sources WHERE coupon_id=$1',[s.coupons[0].id]),5);
  });
  await check('Checkout next mature cycle recovers offset once before issuance; original chronology stays immutable',async()=>{
    for(let i=0;i<4;i++)await earn();await mature();
    const s=await state();assert.equal(s.future_offset_minor,'0');assert.equal(s.coupon_minor,'20000');assert.equal(s.pending_minor,'0');
    assert.equal(s.coupons[0].face_minor,'25000');assert.equal(s.coupons[0].remaining_minor,'20000');
    assert.equal((await state()).coupon_minor,'20000');
  });
  let partialPurchase;
  await check('Checkout 500 minus 25 is below threshold; partial-source fraud splits unspent reversal and spent offset',async()=>{
    const {q}=await approve(2500);partialPurchase=(await complete(await claim(q))).purchase_id;
    assert.equal((await state()).pending_count,0);assert.equal((await state()).coupon_minor,'17500');
    const source=await scalar('SELECT source_purchase FROM public.reward_source_uses WHERE redemption_purchase=$1',[partialPurchase]);
    await invalidate(source);const s=await state();assert.equal(s.coupon_minor,'15000');assert.equal(s.future_offset_minor,'2500');
  });
  await check('Checkout return evidence allocates coupon precisely and never executes or fabricates refund/restoration',async()=>{
    const evidence=await call(f.merchant,'read_purchase_evidence_v2',[partialPurchase]);const before=await state();
    const returned=await call(f.merchant,'record_purchase_return_v2',[partialPurchase,randomUUID(),[{purchase_item_id:evidence.items[0].id,quantity:1}],
      'Synthetic physical return',f.merchant.installation,null]);
    assert.equal(returned.returns[0].refund_executed,false);assert.equal(returned.returns[0].items[0].ev_coupon_return_minor,'2500');
    assert.equal((await state()).coupon_minor,before.coupon_minor);assert.equal((await state()).future_offset_minor,before.future_offset_minor);
  });
  await check('Checkout gate-off blocks new approvals while exact completed receipts remain readable without another debit',async()=>{
    const before=await count('ledger_journals');await db.query('UPDATE public.reward_checkout_config SET enabled=false');
    assert.equal((await complete(claimed)).purchase_id,purchase);assert.equal(await count('ledger_journals'),before);
    await db.query('UPDATE public.reward_checkout_config SET enabled=true');
  });
  await check('Checkout revoked classification rejects finalization without half purchase or balance mutation',async()=>{
    const {q}=await approve(1000),c=await claim(q),before=(await state()).coupon_minor;
    await classify('unknown');await assert.rejects(complete(c),/CHECKOUT_CLASSIFICATION_CHANGED/);
    assert.equal((await state()).coupon_minor,before);assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id]),0);
    await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);await classify('ordinary');
  });
  await check('Checkout customer logout after approval invalidates spending authority even with valid merchant claim',async()=>{
    const {q}=await approve(1000),c=await claim(q),sid=f.customer.claims.session_id;
    await db.query("UPDATE auth.sessions SET not_after=clock_timestamp()-interval '1 second' WHERE id=$1",[sid]);
    await assert.rejects(complete(c),/CHECKOUT_CUSTOMER_SESSION_ENDED/);
    await db.query('UPDATE auth.sessions SET not_after=NULL WHERE id=$1',[sid]);
    await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);
  });
  await check('Checkout proportional integer allocation uses largest remainder with stable UUID ties',async()=>{
    const ids=['00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003'];
    const items=ids.map(listing_id=>({listing_id,quantity:1,sale_minor:'1'}));
    const result=await scalar('SELECT public._checkout_allocate_e($1::jsonb,2)',[JSON.stringify(items.reverse())]);
    assert.deepEqual(result.map(x=>[x.listing_id,x.coupon_minor]),[[ids[0],'1'],[ids[1],'1'],[ids[2],'0']]);
  });
  const deep=await f.actor(),deepSources=[];
  for(let i=0;i<10;i++)deepSources.push(await earn(deep));await mature();assert.equal((await state(deep)).coupon_minor,'50000');
  await check('Checkout 500 minus 500 creates valid purchase with zero payment and no reward; reserve caps at 1000 TL',async()=>{
    const {q}=await approve(50000,500,1,deep),done=await complete(await claim(q));
    assert.equal(done.status,'used');assert.equal((await state(deep)).pending_count,0);assert.equal((await state(deep)).coupon_minor,'0');
    assert.equal(await scalar('SELECT customer_payment_minor::text FROM public.purchase_terms WHERE purchase_id=$1',[done.purchase_id]),'0');
    const first=await call(f.customer,'read_customer_checkout_terms_v1',[[done.purchase_id]]);assert.deepEqual(first,[]);
    const own=await call(deep,'read_customer_checkout_terms_v1',[[done.purchase_id]]);assert.equal(own[0].coupon_checkout.payment_minor,'0');
    for(const source of deepSources)await invalidate(source);
    assert.equal((await state(deep)).future_offset_minor,'50000');
  });
  await check('Checkout fully offset mature cycles issue immutable zero-remaining coupons without zero or unbalanced journals',async()=>{
    for(let i=0;i<5;i++)await earn(deep);await mature();let s=await state(deep);
    assert.equal(s.coupon_minor,'0');assert.equal(s.future_offset_minor,'25000');assert.equal(s.coupons[0].face_minor,'25000');assert.equal(s.coupons[0].remaining_minor,'0');
    for(let i=0;i<5;i++)await earn(deep);await mature();s=await state(deep);
    assert.equal(s.coupon_minor,'0');assert.equal(s.future_offset_minor,'0');
    for(let i=0;i<5;i++)await earn(deep);await mature();assert.equal((await state(deep)).coupon_minor,'25000');
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_postings WHERE amount_minor=0'),0);
  });
  await check('Checkout 500 minus 250 does not earn; only the overflow above the reserve cap becomes pending receivable',async()=>{
    const {q}=await approve(25000,500,1,deep),done=await complete(await claim(q));assert.equal(done.status,'used');
    assert.equal((await state(deep)).pending_count,0);
    const reserve=await scalar("SELECT public._ledger_balance_h0(a.id)::text FROM public.ledger_accounts a JOIN public.ledger_parties p ON p.id=a.party_id WHERE p.shop_id=$1 AND a.code='merchant_reserve'",[f.shop]);
    assert.equal(reserve,'100000');
    assert(BigInt(await scalar("SELECT public._ledger_balance_h0(a.id)::text FROM public.ledger_accounts a JOIN public.ledger_parties p ON p.id=a.party_id WHERE p.shop_id=$1 AND a.code='merchant_coupon_pending'",[f.shop]))>0n);
  });
  await check('Checkout return rounding survives out-of-order correction without restoring or over-allocating coupon value',async()=>{
    const {q}=await approve(1,399.99,3),done=await complete(await claim(q));
    const e=await call(f.merchant,'read_purchase_evidence_v2',[done.purchase_id]),items=[{purchase_item_id:e.items[0].id,quantity:1}];
    let first;
    for(let i=0;i<3;i++){
      const r=await call(f.merchant,'record_purchase_return_v2',[done.purchase_id,randomUUID(),items,'Rounding return',f.merchant.installation,null]);
      first??=r.returns[0].id;
    }
    await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[f.other.id]);
    await call(f.other,'record_purchase_return_v2',[done.purchase_id,randomUUID(),items,'Out of order correction',f.other.installation,first]);
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.other.id]);
    await call(f.merchant,'record_purchase_return_v2',[done.purchase_id,randomUUID(),items,'Final remaining unit',f.merchant.installation,null]);
    const sums=(await db.query(`SELECT sum(CASE WHEN r.return_kind='genuine' THEN i.sale_return_minor ELSE -i.sale_return_minor END)::text sale,
      sum(CASE WHEN r.return_kind='genuine' THEN i.ev_coupon_return_minor ELSE -i.ev_coupon_return_minor END)::text coupon
      FROM public.purchase_returns r JOIN public.purchase_return_items i ON i.return_id=r.id WHERE r.purchase_id=$1`,[done.purchase_id])).rows[0];
    assert.deepEqual(sums,{sale:'119997',coupon:'1'});
  });
  await check('Checkout balance changed after consent rejects the entire completion without silently lowering customer authorization',async()=>{
    const available=(await state()).coupon_minor,{q}=await approve(available),c=await claim(q);
    const source=await scalar(`SELECT r.purchase_id FROM public.reward_contributions r JOIN public.reward_coupon_sources s ON s.purchase_id=r.purchase_id
      JOIN public.ledger_parties p ON p.id=r.customer_party WHERE p.user_id=$1 AND public._checkout_source_remaining_e(r.purchase_id)>0 LIMIT 1`,[f.customer.id]);
    await invalidate(source);const before=(await state()).coupon_minor;
    await assert.rejects(complete(c),/LEDGER_OVERDRAFT/);
    assert.equal((await state()).coupon_minor,before);
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id]),0);
    await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);
  });
  return checks;
}
