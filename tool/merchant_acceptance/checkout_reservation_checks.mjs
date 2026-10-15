import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {contended} from './postgres_checks.mjs';

// Observe capacity BEFORE claim/completion; terminal reward counts cannot detect
// a below-threshold checkout unnecessarily occupying the last available slot.
export async function checkoutReservationChecks({db,f,check,call,cart,claim}) {
  const scalar=async(sql,args=[])=>Object.values((await db.query(sql,args)).rows[0])[0];
  const pack=await scalar('SELECT id FROM public.referral_packages WHERE shop_id=$1 ORDER BY activated_at DESC LIMIT 1',[f.shop]);
  const capacity=()=>scalar('SELECT public._reward_capacity_e($1)',[pack]);
  const funds=async()=>Object.fromEntries((await db.query(`SELECT a.code,public._ledger_balance_h0(a.id)::text balance
    FROM public.ledger_accounts a JOIN public.referral_packages p ON p.party_id=a.party_id
    WHERE p.id=$1 AND a.code IN ('package_free','package_held')`,[pack])).rows.map(r=>[r.code,BigInt(r.balance)]));
  const live=id=>scalar(`SELECT count(*)::int FROM public.reward_reservations r JOIN public.reward_attempts a ON a.id=r.attempt_id
    WHERE a.cart_ref=$1 AND r.state IN ('reserved','checkout_hold')`,[id]);
  const journals=()=>scalar('SELECT count(*)::int FROM public.ledger_journals');
  async function cleanup(ids) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE id=ANY($1::uuid[])",[ids]);
    await scalar('SELECT public._reward_reconcile_e(1000)');
  }
  async function approve(id,amount=25000) {
    const p=await call(f.customer,'preview_coupon_checkout_v1',[id]),args=[id,randomUUID(),p.fingerprint,String(amount)];
    return {q:await call(f.customer,'create_coupon_qr_v1',args),args};
  }
  await check('Checkout net threshold releases the existing reservation and its fund at customer approval',async()=>{
    const id=await cart(500),reserved=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    assert.equal(reserved.status,'reserved');
    const before=await capacity(),beforeFunds=await funds(),{q,args}=await approve(id);
    assert.equal(q.coupon_checkout.payment_minor,'25000');
    assert.equal(await scalar('SELECT state FROM public.reward_reservations WHERE attempt_id=$1',[reserved.attempt_id]),'released',
      '500 TL sale - 250 TL coupon must release capacity before merchant claim');
    assert.equal(await live(id),0);
    assert.deepEqual(await capacity(),{...before,free:before.free+1,held:before.held-1});
    const afterFunds=await funds();assert.equal(afterFunds.package_free,beforeFunds.package_free+5000n);
    assert.equal(afterFunds.package_held,beforeFunds.package_held-5000n);
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id]),0);
    const count=await journals();assert.equal((await call(f.customer,'create_coupon_qr_v1',args)).id,q.id);
    assert.equal(await journals(),count,'Exact approval retry must not release twice');
    const c=await claim(q);await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);
    assert.equal(await journals(),count,'Claim/cancel must not release the same funds twice');await cleanup([id]);
  });
  await check('Checkout recovery and concurrent reservation retries cannot reacquire below-threshold consent or renew its deadline',async()=>{
    const id=await cart(),r=await call(f.customer,'ensure_reward_reservation_v1',[id,false]),{q}=await approve(id);
    const count=await journals();
    const outcomes=await contended(db,o=>call(f.customer,'ensure_reward_reservation_v1',[id,false],o),
      o=>call(f.customer,'ensure_reward_reservation_v1',[id,true],o));
    for(const outcome of outcomes) {
      assert.equal(outcome.status,'fulfilled');assert.equal(outcome.value.status,'below_threshold');
      assert.equal(outcome.value.attempt_id,r.attempt_id);assert.equal(outcome.value.expires_at,r.expires_at);
    }
    assert.equal((await call(f.customer,'preview_coupon_checkout_v1',[id])).existing_qr.id,q.id);
    assert.equal((await call(f.customer,'create_reward_qr_v1',[id])).id,q.id);
    const c=await claim(q);assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,false])).status,'below_threshold');
    assert.equal(await live(id),0);assert.equal(await journals(),count);
    await db.query('UPDATE public.reward_checkout_config SET enabled=false');
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,true])).status,'below_threshold');
    await db.query('UPDATE public.reward_checkout_config SET enabled=true');
    // A later listing change cannot replace the customer's still-live frozen terms.
    await db.query('UPDATE public.shop_products SET price=750 WHERE id=$1',[f.listing]);
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,true])).status,'below_threshold');
    await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);
    const again=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    assert.equal(again.status,'reserved');assert.equal(again.attempt_id,r.attempt_id);assert.equal(again.expires_at,r.expires_at);
    await cleanup([id]);
  });
  await check('Checkout capacity uses exact net minor units before and after claim at the 500 TL boundary',async()=>{
    for(const [price,coupon,payment,eligible] of [[749.99,25000,'49999',false],[750,25000,'50000',true],
      [750.01,25000,'50001',true],[500,1,'49999',false],[250,25000,'0',false]]) {
      const id=await cart(price),before=await capacity(),{q}=await approve(id,coupon);
      assert.equal(q.coupon_checkout.payment_minor,payment);assert.equal(await live(id),eligible?1:0);
      assert.deepEqual(await capacity(),{...before,free:before.free-(eligible?1:0),held:before.held+(eligible?1:0)});
      const c=await claim(q);assert.equal(await live(id),eligible?1:0);
      assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,false])).status,eligible?'checkout_hold':'below_threshold');
      await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);await cleanup([id]);
      assert.deepEqual(await capacity(),before);
    }
  });
  await check('Checkout failed consent rolls slot release and fund movement back with its QR and approval',async()=>{
    const id=await cart(),r=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    const before=await capacity(),beforeFunds=await funds(),count=await journals();
    const p=await call(f.customer,'preview_coupon_checkout_v1',[id]),args=[id,randomUUID(),p.fingerprint,'25000'];
    await db.query(`CREATE FUNCTION public.test_checkout_reject() RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN RAISE EXCEPTION 'TEST_CHECKOUT_ATOMIC_ROLLBACK'; END $$;
      CREATE CONSTRAINT TRIGGER zz_test_checkout_reject AFTER INSERT ON public.reward_checkout_approvals
      DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.test_checkout_reject()`);
    try { await assert.rejects(call(f.customer,'create_coupon_qr_v1',args),/TEST_CHECKOUT_ATOMIC_ROLLBACK/); }
    finally {await db.query('DROP TRIGGER zz_test_checkout_reject ON public.reward_checkout_approvals; DROP FUNCTION public.test_checkout_reject()');}
    assert.deepEqual(await capacity(),before);assert.deepEqual(await funds(),beforeFunds);assert.equal(await journals(),count);
    assert.equal(await scalar('SELECT state FROM public.reward_reservations WHERE attempt_id=$1',[r.attempt_id]),'reserved');
    assert.equal(await scalar('SELECT count(*)::int FROM public.qr_sessions WHERE cart_id=$1',[id]),0);
    const q=await call(f.customer,'create_coupon_qr_v1',args);assert.equal(await live(id),0);
    const c=await claim(q);await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);await cleanup([id]);
  });
  await check('Checkout last-slot release is immediately available to an independent waiting customer',async()=>{
    const original=await capacity(),heldCarts=[],id=await cart();heldCarts.push(id);
    await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    try {
      for(let i=0;i<original.free-1;i++) {
        const actor=await f.actor(),otherCart=await cart(500,1,actor);heldCarts.push(otherCart);
        assert.equal((await call(actor,'ensure_reward_reservation_v1',[otherCart,false])).status,'reserved');
      }
      assert.equal((await capacity()).free,0);
      const waiting=await f.actor(),waitingCart=await cart(500,1,waiting);heldCarts.push(waitingCart);
      assert.equal((await call(waiting,'ensure_reward_reservation_v1',[waitingCart,false])).status,'no_capacity');
      const p=await call(f.customer,'preview_coupon_checkout_v1',[id]);
      const result=await contended(db,o=>call(f.customer,'create_coupon_qr_v1',[id,randomUUID(),p.fingerprint,'25000'],o),
        o=>call(waiting,'ensure_reward_reservation_v1',[waitingCart,false],o));
      assert(result.every(r=>r.status==='fulfilled'),JSON.stringify(result));assert.equal(result[1].value.status,'reserved');
      assert.equal(await live(id),0);assert.equal((await capacity()).free,0);
      assert.equal((await capacity()).held,original.held+original.free);
    } finally {await cleanup(heldCarts);}
    assert.deepEqual(await capacity(),original);
  });
  await check('Checkout legacy bad holds repair once; private repair and gross reservation bypass remain inaccessible',async()=>{
    const id=await cart(),before=await capacity();
    // Synthetic prior-0026 state only: the approved QR still has a gross-price hold.
    await db.query('ALTER TABLE public.reward_checkout_approvals DISABLE TRIGGER checkout_approval_capacity');
    let q;
    try {({q}=await approve(id));}
    finally {await db.query('ALTER TABLE public.reward_checkout_approvals ENABLE TRIGGER checkout_approval_capacity');}
    assert.equal(await live(id),1);
    assert.equal(await scalar('SELECT public._checkout_release_below_threshold_e($1)',[q.id]),true);
    assert.equal(await live(id),0);assert.deepEqual(await capacity(),before);
    const count=await journals();await scalar('SELECT public._checkout_release_below_threshold_e($1)',[q.id]);assert.equal(await journals(),count);
    for(const name of ['_checkout_release_below_threshold_e','_checkout_approval_capacity_e','_ensure_reward_reservation_before_coupon_threshold']) {
      for(const role of ['anon','authenticated','service_role'])
        assert.equal(await scalar("SELECT has_function_privilege($1,p.oid,'EXECUTE') FROM pg_proc p WHERE p.pronamespace='public'::regnamespace AND p.proname=$2",[role,name]),false);
    }
    await assert.rejects(call(f.other,'ensure_reward_reservation_v1',[id,false]),e=>e.code==='42501');
    await assert.rejects(call(f.customer,'ensure_reward_reservation_v1',[id,null]),/REWARD_INVALID_ARGUMENT/);
    await assert.rejects(call(f.customer,'_ensure_reward_reservation_before_coupon_threshold',[id,false]),e=>e.code==='42501');
    const c=await claim(q);await call(f.merchant,'cancel_claim_v2',[c.claim_id,f.merchant.installation]);await cleanup([id]);
  });
  await check('Checkout below-threshold consent releases an expired package hold to unused-fund receivable',async()=>{
    const listing=randomUUID(),id=randomUUID();
    await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,500)',[listing,f.otherShop,f.product]);
    const oldPack=await scalar('SELECT public.activate_referral_package_v1($1,$2,$3,$4,$5)',[f.otherShop,randomUUID(),randomUUID(),randomUUID(),'575000']);
    await db.query('INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[id,f.customer.id,f.otherShop]);
    await db.query('INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[id,listing]);
    const r=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);assert.equal(r.status,'reserved');
    await db.query('BEGIN');
    try {
      await db.query('ALTER TABLE public.referral_packages DISABLE TRIGGER reward_immutable');
      await db.query("UPDATE public.referral_packages SET activated_at=activated_at-interval '91 days',expires_at=expires_at-interval '91 days' WHERE id=$1",[oldPack]);
      await db.query('ALTER TABLE public.referral_packages ENABLE TRIGGER reward_immutable');await db.query('COMMIT');
    } catch(e) {await db.query('ROLLBACK');throw e;}
    const {q}=await approve(id);assert.equal(await live(id),0);
    assert.deepEqual(await scalar('SELECT public._reward_capacity_e($1)',[oldPack]),{free:0,held:0,consumed:0,expired:100});
    assert.equal(await scalar("SELECT public._ledger_balance_h0(a.id)::text FROM public.ledger_accounts a JOIN public.ledger_parties p ON p.id=a.party_id WHERE p.shop_id=$1 AND a.code='merchant_unused_pending'",[f.otherShop]),'500000');
    assert.equal((await call(f.other,'read_merchant_reward_v1',[f.otherShop])).forced_acceptance,false);
    const c=await call(f.other,'claim_existing_qr_v2',[f.otherShop,f.other.installation,randomUUID(),q.session_token,null]);
    await call(f.other,'cancel_claim_v2',[c.claim_id,f.other.installation]);await cleanup([id]);
  });
}
