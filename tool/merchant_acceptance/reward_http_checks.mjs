import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';

export async function rewardHttpChecks({db,request,rpc,session,f}) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
  const path=name=>'/rest/v1/rpc/'+name;
  await db.query('UPDATE public.reward_program_config SET enabled=true; UPDATE public.commerce_ledger_config SET enabled=true; UPDATE public.qr_protocol_config SET enabled=true');
  f.listing=randomUUID();
  await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,500)',[f.listing,f.shop,f.product]);
  await db.query('SELECT public.activate_referral_package_v1($1,$2,$3,$4,$5)',[f.shop,randomUUID(),randomUUID(),randomUUID(),'575000']);
  let cart,claim,purchase;
  await check('E HTTP role/ownership and raw-table boundaries hold with real signed Auth sessions',async()=>{
    assert.equal((await request(path('read_merchant_reward_v1'),f.other,{p_shop:f.shop})).ok,false);
    assert.equal((await request(path('read_reward_state_v1'),f.merchant,{})).ok,false);
    for(const table of ['referral_packages','reward_funding_attestations','reward_contributions','reward_coupons','reward_capacity_events']) {
      assert.equal((await request('/rest/v1/'+table+'?select=*',f.customer,undefined,'GET')).ok,false);
    }
    assert.equal((await request(path('activate_referral_package_v1'),f.merchant,
      {p_shop:f.shop,p_request:randomUUID(),p_consent:randomUUID(),p_external_ref:randomUUID(),p_external_paid_minor:'575000'})).ok,false);
    const caps=await rpc('reward_capabilities_v1',f.customer,{});
    assert.equal(caps.enabled,true);assert.equal(caps.redemption_enabled,false);
  });
  await check('E HTTP reserve, QR attestation and duplicate completion yield one earning and one capacity consumption',async()=>{
    cart=randomUUID();
    assert.equal((await request('/rest/v1/carts',f.customer,{id:cart,user_id:f.customer.id,shop_id:f.shop})).ok,true);
    assert.equal((await request('/rest/v1/cart_items_v2',f.customer,{cart_id:cart,shop_product_id:f.listing,quantity:1})).ok,true);
    assert.equal((await rpc('ensure_reward_reservation_v1',f.customer,{p_cart:cart,p_start_new:false})).status,'reserved');
    const q=await rpc('create_reward_qr_v1',f.customer,{p_cart:cart});
    claim=await rpc('claim_existing_qr_v2',f.merchant,{p_shop_id:f.shop,p_installation_id:f.merchant.installation,p_request_id:randomUUID(),p_session_token:q.session_token});
    assert.equal(claim.reward_sale_minor,'50000');assert.equal(claim.reward_confirmation_required,true);
    const args={p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation};
    assert.equal((await request(path('complete_existing_qr_v2'),f.merchant,args)).ok,false);
    for(const amount of [null,'','0','49999','50001','50000.0','5e4']) {
      assert.equal((await request(path('complete_reward_qr_v1'),f.merchant,{...args,p_actual_sale_minor:amount})).ok,false);
    }
    const results=await Promise.all([1,2].map(()=>rpc('complete_reward_qr_v1',f.merchant,{...args,p_actual_sale_minor:'50000'})));
    purchase=results[0];assert.equal(purchase.status,'used');assert.equal(results[1].purchase_id,purchase.purchase_id);
    const customer=await rpc('read_reward_state_v1',await session(f.customer.id),{});
    assert.equal(customer.pending_count,1);assert.equal(customer.pending_minor,'5000');assert.equal(customer.coupon_minor,'0');
    const merchant=await rpc('read_merchant_reward_v1',await session(f.merchant.id),{p_shop:f.shop});
    assert.deepEqual(merchant.packages[0].capacity,{free:99,held:0,consumed:1,expired:0});
    assert.equal((await rpc('read_reward_state_v1',await session(f.customer.id),{})).history[0].purchase_id,purchase.purchase_id);
  });
  await check('E HTTP real logout denies replay and reads even while the signed token remains unexpired',async()=>{
    const stale=await session(f.merchant.id);
    await rpc('read_merchant_reward_v1',stale,{p_shop:f.shop});
    assert.equal((await request('/auth/v1/logout?scope=local',stale,undefined)).ok,true);
    for(const [name,args] of [
      ['read_merchant_reward_v1',{p_shop:f.shop}],
      ['set_merchant_reward_preference_v1',{p_shop:f.shop,p_preferred:true,p_expected_revision:0}],
      ['complete_reward_qr_v1',{p_claim_id:claim.claim_id,p_installation_id:f.merchant.installation,p_actual_sale_minor:'50000'}],
    ]) assert.equal((await request(path(name),stale,args)).ok,false);
    const customer=await session(f.customer.id);
    assert.equal((await request('/auth/v1/logout?scope=local',customer,undefined)).ok,true);
    assert.equal((await request(path('read_reward_state_v1'),customer,{})).ok,false);
    assert.equal((await request(path('ensure_reward_reservation_v1'),customer,{p_cart:cart,p_start_new:true})).ok,false);
  });
  await check('E HTTP gate-off retains truthful history and prevents a new reservation',async()=>{
    await db.query('UPDATE public.reward_program_config SET enabled=false');
    const customer=await session(f.customer.id);
    const s=await rpc('read_reward_state_v1',customer,{});
    assert.equal(s.enabled,false);assert.equal(s.pending_count,1);assert.equal(s.pending_minor,'5000');
    const next=randomUUID();
    assert.equal((await request('/rest/v1/carts',customer,{id:next,user_id:customer.id,shop_id:f.shop})).ok,true);
    assert.equal((await rpc('ensure_reward_reservation_v1',customer,{p_cart:next,p_start_new:false})).status,'disabled');
    assert.equal((await rpc('reward_capabilities_v1',customer,{})).enabled,false);
  });
  return checks;
}
