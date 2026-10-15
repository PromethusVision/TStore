import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
export async function checkoutHttpChecks({db,request,rpc,f}) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  let cart,preview,qr,claim;
  await check('Checkout HTTP signed customer preview/approval and exact merchant completion share one QR',async()=>{
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[f.customer.id]);
    await db.query('DELETE FROM public.qr_attempt_limits');
    await db.query('UPDATE public.shop_products SET price=750 WHERE id=$1',[f.listing]);
    cart=randomUUID();
    await db.query('INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,f.customer.id,f.shop]);
    await db.query('INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,f.listing]);
    preview=await rpc('preview_coupon_checkout_v1',f.customer,{p_cart:cart});assert(preview.enabled);
    qr=await rpc('create_coupon_qr_v1',f.customer,{p_cart:cart,p_request:randomUUID(),p_fingerprint:preview.fingerprint,p_coupon_minor:'1000'});
    claim=await rpc('claim_existing_qr_v2',f.merchant,{p_shop_id:f.shop,p_installation_id:f.merchant.installation,p_request_id:randomUUID(),p_session_token:qr.session_token});
    assert.equal(claim.coupon_checkout.payment_minor,'74000');
    const bad=await request('/rest/v1/rpc/complete_coupon_qr_v1',f.merchant,{p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation,p_sale_minor:'75000',p_coupon_minor:null,p_payment_minor:'74000'});assert.equal(bad.ok,false);
    const done=await rpc('complete_coupon_qr_v1',f.merchant,{p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation,p_sale_minor:'75000',p_coupon_minor:'1000',p_payment_minor:'74000'});
    assert.equal(done.status,'used');assert.equal(done.session_id,qr.id);
  });
  await check('Checkout HTTP raw tables, private kernels, wrong principal and unauthenticated preview are denied',async()=>{
    for(const table of ['reward_checkout_approvals','reward_coupon_redemptions','reward_spent_offsets','reward_source_uses','reward_product_classifications']) {
      assert.equal((await request(`/rest/v1/${table}?select=*`,f.customer,undefined,'GET')).ok,false);
    }
    assert.equal((await request('/rest/v1/rpc/preview_coupon_checkout_v1',null,{p_cart:cart})).ok,false);
    assert.equal((await request('/rest/v1/rpc/preview_coupon_checkout_v1',f.other,{p_cart:cart})).ok,false);
    assert.equal((await request('/rest/v1/rpc/attest_reward_product_classification_v1',f.merchant,{p_product:f.product,p_classification:'ordinary',p_policy_ref:'fake',p_reason:'fake'})).ok,false);
  });
  await check('Checkout HTTP below-threshold approval releases capacity before claim and refresh cannot reacquire it',async()=>{
    await db.query('DELETE FROM public.qr_attempt_limits');
    await db.query('UPDATE public.shop_products SET price=500 WHERE id=$1',[f.listing]);
    cart=randomUUID();
    await db.query('INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,f.customer.id,f.shop]);
    await db.query('INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,f.listing]);
    const reserved=await rpc('ensure_reward_reservation_v1',f.customer,{p_cart:cart,p_start_new:false});assert.equal(reserved.status,'reserved');
    preview=await rpc('preview_coupon_checkout_v1',f.customer,{p_cart:cart});
    qr=await rpc('create_coupon_qr_v1',f.customer,{p_cart:cart,p_request:randomUUID(),p_fingerprint:preview.fingerprint,p_coupon_minor:'1000'});
    assert.equal(qr.coupon_checkout.payment_minor,'49000');
    const reservation=async()=>(await db.query('SELECT state FROM public.reward_reservations WHERE attempt_id=$1',[reserved.attempt_id])).rows;
    assert.deepEqual(await reservation(),[{state:'released'}]);
    const refreshed=await rpc('ensure_reward_reservation_v1',f.customer,{p_cart:cart,p_start_new:true});
    assert.equal(refreshed.status,'below_threshold');assert.equal(refreshed.expires_at,reserved.expires_at);
    claim=await rpc('claim_existing_qr_v2',f.merchant,{p_shop_id:f.shop,p_installation_id:f.merchant.installation,p_request_id:randomUUID(),p_session_token:qr.session_token});
    assert.deepEqual(await reservation(),[{state:'released'}]);
    await rpc('cancel_claim_v2',f.merchant,{p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation});
    await db.query("UPDATE public.carts SET status='cancelled' WHERE id=$1",[cart]);
    await db.query('UPDATE public.shop_products SET price=750 WHERE id=$1',[f.listing]);
  });
  await check('Checkout HTTP real Auth logout revokes coupon consent despite still-signed customer JWT',async()=>{
    await db.query('DELETE FROM public.qr_attempt_limits');
    cart=randomUUID();
    await db.query('INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,f.customer.id,f.shop]);
    await db.query('INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,f.listing]);
    preview=await rpc('preview_coupon_checkout_v1',f.customer,{p_cart:cart});
    qr=await rpc('create_coupon_qr_v1',f.customer,{p_cart:cart,p_request:randomUUID(),p_fingerprint:preview.fingerprint,p_coupon_minor:'1000'});
    claim=await rpc('claim_existing_qr_v2',f.merchant,{p_shop_id:f.shop,p_installation_id:f.merchant.installation,p_request_id:randomUUID(),p_session_token:qr.session_token});
    assert.equal((await request('/auth/v1/logout?scope=local',f.customer,{})).ok,true);
    const before=(await db.query('SELECT count(*)::int n FROM public.reward_coupon_redemptions')).rows[0].n;
    assert.equal((await request('/rest/v1/rpc/complete_coupon_qr_v1',f.merchant,{p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation,p_sale_minor:'75000',p_coupon_minor:'1000',p_payment_minor:'74000'})).ok,false);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.reward_coupon_redemptions')).rows[0].n,before);
  });
  return checks;
}
