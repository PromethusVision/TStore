import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { rpc, sqlAs, connect } from './fixture.mjs';
import { contended } from './postgres_checks.mjs';

export async function trustCampaignChecks(db, config, f) {
  const checks=[];
  const check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const call=(actor,name,args=[],options)=>rpc(config,actor,name,args,options);
  const existing=async(shop)=>(await db.query('SELECT id FROM public.shop_products WHERE shop_id=$1 AND product_id=$2',[shop,f.product])).rows[0]?.id;
  const listing=await existing(f.shop)??randomUUID(), otherListing=await existing(f.otherShop)??randomUUID();
  await sqlAs(config,f.merchant,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12) ON CONFLICT(id) DO NOTHING',[listing,f.shop,f.product]);
  await sqlAs(config,f.other,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12) ON CONFLICT(id) DO NOTHING',[otherListing,f.otherShop,f.product]);
  async function purchase(actor, shop=f.shop, owner=f.merchant, selected=listing) {
    const cart=randomUUID();
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[actor.id]);
    await sqlAs(config,actor,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,actor.id,shop]);
    await sqlAs(config,actor,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,selected]);
    const qr=await call(actor,'create_qr_session',[cart]); await call(owner,'confirm_qr_session',[qr.session_token]);
    return (await db.query('SELECT * FROM public.verified_transactions WHERE source_qr_session_id=$1',[qr.id])).rows[0];
  }
  const trust=(actor=f.merchant,shop=f.shop,limit=30,before=null)=>call(actor,'read_my_trust_v1',[shop,limit,before]);
  const badge=(result,code)=>result.badges.find(b=>b.code===code);
  const refresh=()=>db.query('SELECT public.process_badge_refresh_v1(100) result').then(r=>r.rows[0].result);
  const admin=await f.session(); await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[admin.id]);
  await check('D default OFF and private evidence/worker grants',async()=>{
    assert.equal((await call(f.merchant,'badge_capabilities_v1')).enabled,false);
    assert.equal((await trust()).enabled,false);
    for(const table of ['badge_subjects','badge_current_state','badge_award_events','badge_refresh_events','badge_area_assignments','badge_rule_versions'])
      await assert.rejects(sqlAs(config,f.merchant,`SELECT * FROM public.${table}`),e=>e.code==='42501');
    await assert.rejects(call(f.merchant,'process_badge_refresh_v1',[10]),e=>e.code==='42501');
    await assert.rejects(trust(f.other),/REVIEW_SHOP/);
    await assert.rejects(db.query("UPDATE public.badge_rule_versions SET rules='{}'"),/append-only/);
  });
  await db.query('UPDATE public.badge_protocol_config SET enabled=true');
  await db.query('UPDATE public.review_protocol_config SET enabled=true');
  const customers=[], purchases=[], roots=[];
  await check('D twenty DISTINCT customers and exact unrounded thresholds',async()=>{
    for(let i=0;i<20;i++) {
      const actor=await f.session();customers.push(actor);
      const p=await purchase(actor);purchases.push(p);
      const result=await call(actor,'submit_purchase_evaluation_v2',[p.id,randomUUID(),
        {friendliness:i<6?4:5,communication:i<4?4:5,cleanliness:i<5?4:5},
        JSON.stringify([{product_id:f.product,rating:i<4?4:5,comment:'Yerel rozet kanıtı'}])]);
      roots.push(result.reviews[0].review_id);
      if(i===18) assert.equal(badge(await trust(),'friendliness').eligible,false);
    }
    const result=await trust();
    assert.equal(badge(result,'friendliness').value,4.7); assert.equal(badge(result,'friendliness').eligible,true);
    assert.equal(badge(result,'communication').eligible,true); assert.equal(badge(result,'products').eligible,true);
    assert.equal(badge(result,'cleanliness').value,4.75);assert.equal(badge(result,'cleanliness').eligible,false);
    assert.equal(badge(result,'neighborhood').pending,true);
    const again=await trust();assert.equal(again.history.length,result.history.length);
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[customers[0].id]);
    assert.equal(badge(await trust(),'products').eligible,true);
    assert.equal(badge(await trust(),'friendliness').eligible,true);
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[customers[0].id]);
    const shared=await call(f.other,'read_badges_v1',[[f.shop]]);
    assert.equal(JSON.stringify(shared).includes(customers[0].id),false);
    assert.equal(JSON.stringify(shared).includes('purchase_id'),false);
  });
  await check('D visibility-only withdrawal preserves milestones; abuse invalidates evidence',async()=>{
    await call(customers[0],'delete_product_review',[roots[0]]);
    assert.equal(badge(await trust(),'products').eligible,true);
    const revision=(await db.query('SELECT current_revision_id FROM public.review_lifecycle WHERE review_id=$1',[roots[0]])).rows[0].current_revision_id;
    await call(admin,'review_action_v2',[roots[0],revision,randomUUID(),'flag_abuse','Yerel kanıt incelemesi',null]);
    assert.equal(badge(await trust(),'products').eligible,false);
  });
  await check('D invalidation revokes immediately and correction history is append-only',async()=>{
    await call(admin,'invalidate_purchase_v2',[purchases[19].id,randomUUID(),'Yerel geçersiz alışveriş kanıtı']);
    const result=await trust();assert.equal(badge(result,'friendliness').eligible,false);
    assert(result.history.some(h=>h.code==='friendliness' && h.event==='revoked'));
    await assert.rejects(db.query('DELETE FROM public.badge_award_events'),/append-only/);
    const next=await trust(f.merchant,f.shop,1);assert(next.next_before);
    const older=await trust(f.merchant,f.shop,1,next.next_before);assert(older.history[0].id<next.history[0].id);
  });
  const version=randomUUID(),area=randomUUID();
  const polygon={type:'Polygon',coordinates:[[[28,40],[30,40],[30,42],[28,42],[28,40]]]};
  await check('D geometry fails closed, holes and boundary semantics; reviewed assignment only',async()=>{
    const covers=async(g,x,y)=>(await db.query('SELECT public._badge_area_covers_d($1,$2,$3) yes',[g,x,y])).rows[0].yes;
    assert.equal(await covers(polygon,29,41),true);assert.equal(await covers(polygon,28,41),true);
    assert.equal(await covers(polygon,31,41),false);
    const hole={...polygon,coordinates:[...polygon.coordinates,[[28.5,40.5],[29.5,40.5],[29.5,41.5],[28.5,41.5],[28.5,40.5]]]};
    assert.equal(await covers(hole,29,41),false);assert.equal(await covers(hole,28.5,41),false);
    assert.equal(await covers({...polygon,coordinates:[...polygon.coordinates,[[0,0],[1,1]]]},28,41),false);
    assert.equal(await covers({type:'MultiPolygon',coordinates:[polygon.coordinates]},29,41),true);
    await db.query('INSERT INTO public.badge_area_versions(id,dataset_name,source_reference,dataset_sha256) VALUES($1,$2,$3,$4)',[version,'SYNTHETIC TEST ONLY','fixture:local', 'a'.repeat(64)]);
    await db.query('INSERT INTO public.badge_local_areas(id,version_id,official_code,label,geometry) VALUES($1,$2,$3,$4,$5)',[area,version,'TEST','Yerel test alanı',polygon]);
    await db.query('UPDATE public.shops SET latitude=41,longitude=29 WHERE id=ANY($1::uuid[])',[[f.shop,f.otherShop]]);
    await assert.rejects(call(admin,'review_shop_area_assignment_v1',[f.shop,area,'Yerel',randomUUID()]),/BADGE_AREA_UNVERIFIED/);
    await db.query('UPDATE public.badge_area_versions SET approved=true WHERE id=$1',[version]);
    const request=randomUUID();
    const results=await contended(db,options=>call(admin,'review_shop_area_assignment_v1',[f.shop,area,'Yerel',request],options),options=>call(admin,'review_shop_area_assignment_v1',[f.shop,area,'Yerel',request],options));
    assert(results.every(r=>r.status==='fulfilled'));assert.equal(results[0].value,results[1].value);
    await call(admin,'review_shop_area_assignment_v1',[f.otherShop,area,'Yerel',randomUUID()]);
    assert.equal(badge(await trust(),'neighborhood').eligible,true);
    await db.query('UPDATE public.shops SET longitude=29.1 WHERE id=$1',[f.shop]);
    assert.equal(badge(await trust(),'neighborhood').pending,true);
    await call(admin,'review_shop_area_assignment_v1',[f.shop,area,'Yeni konum incelemesi',randomUUID()]);
  });
  await check('D rolling expiry revokes without a new purchase; dataset withdrawal is queued',async()=>{
    while((await refresh()).pending_events>0) { /* Drain existing events before clock-only proof. */ }
    // Fixture-only clock placement: immutable commerce rows are never changed by the runtime.
    await db.query('BEGIN');
    try {
      await db.query('ALTER TABLE public.verified_transactions DISABLE TRIGGER USER');
      await db.query("UPDATE public.verified_transactions SET confirmed_at=clock_timestamp()-interval '90 days'+interval '300 milliseconds' WHERE shop_id=$1",[f.shop]);
      await db.query('ALTER TABLE public.verified_transactions ENABLE TRIGGER USER');await db.query('COMMIT');
    }catch(e){await db.query('ROLLBACK');throw e;}
    await trust();
    await new Promise(r=>setTimeout(r,400));
    await refresh();
    assert.equal((await db.query("SELECT eligible FROM public.badge_current_state st JOIN public.badge_subjects s ON s.id=st.subject_id WHERE s.shop_id=$1 AND st.badge_code='neighborhood'",[f.shop])).rows[0].eligible,false);
    assert.equal(badge(await trust(),'neighborhood').eligible,false);
    const history=(await trust()).history;
    assert(history.some(h=>h.code==='neighborhood' && h.event==='revoked'));
    await db.query('UPDATE public.badge_area_versions SET approved=false WHERE id=$1',[version]);
    assert.equal(badge(await trust(),'neighborhood').pending,true);
    assert((await refresh()).processed>0);
  });
  await check('D purchase milestones count IDs once and survive repeated reads; self-delete unlinks history',async()=>{
    let firstReview;
    for(let i=0;i<10;i++) {
      const product=i===0?f.product:randomUUID(),selected=i===0?listing:randomUUID();
      if(i>0){
        await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,12,$3)',[product,`Milestone test ${i}`,f.category]);
        await sqlAs(config,f.merchant,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12)',[selected,f.shop,product]);
      }
      const p=await purchase(f.customer,f.shop,f.merchant,selected);
      const response=await call(f.customer,'submit_purchase_evaluation_v2',[p.id,randomUUID(),{friendliness:5,communication:5,cleanliness:5},JSON.stringify([{product_id:product,rating:5,comment:'Milestone test'}])]);
      if(i===0) firstReview=response.reviews[0].review_id;
    }
    const result=await trust(f.customer,null);assert.equal(badge(result,'purchases_10').eligible,true);
    assert.equal(badge(result,'purchases_50').eligible,false);
    assert.equal(badge(result,'reviews_10').eligible,true);assert.equal(badge(result,'reviews_50').eligible,false);
    await call(f.customer,'update_product_review',[firstReview,4,null,'Düzenleme yeni yorum değildir']);
    assert.equal(badge(await trust(f.customer,null),'reviews_10').count,10);
    await call(f.customer,'delete_product_review',[firstReview]);
    assert.equal(badge(await trust(f.customer,null),'reviews_10').count,10);
    const repeated=await contended(db,options=>call(f.customer,'read_my_trust_v1',[null,30,null],options),options=>call(f.customer,'read_my_trust_v1',[null,30,null],options));
    assert(repeated.every(r=>r.status==='fulfilled'));
    assert.equal(repeated[0].value.history.length,result.history.length);
    const sid=(await db.query('SELECT id FROM public.badge_subjects WHERE user_id=$1',[f.customer.id])).rows[0].id;
    await call(f.customer,'delete_current_customer_account');
    assert.equal((await db.query('SELECT user_id FROM public.badge_subjects WHERE id=$1',[sid])).rows[0].user_id,null);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.badge_current_state WHERE subject_id=$1 AND eligible',[sid])).rows[0].n,0);
    assert.equal((await db.query("SELECT count(*)::int n FROM public.badge_refresh_events WHERE subject_kind='customer' AND target_id=$1",[f.customer.id])).rows[0].n,0);
    assert((await db.query('SELECT count(*)::int n FROM public.badge_award_events WHERE subject_id=$1',[sid])).rows[0].n>=2);
  });
  await check('D first worker projection racing Auth deletion has no queue/Auth deadlock or orphan identity',async()=>{
    const victim=await f.session();await purchase(victim);
    const results=await contended(db,async options=>{
      const connection=await connect(config);
      try {
        await connection.query('BEGIN');
        await connection.query('SELECT id FROM auth.users WHERE id=$1 FOR UPDATE',[victim.id]);
        await options.hold();
        await connection.query('DELETE FROM auth.users WHERE id=$1',[victim.id]);
        await connection.query('COMMIT');
      }catch(e){await connection.query('ROLLBACK');throw e;}finally{await connection.end();}
    },async options=>{
      const connection=await connect(config);
      try {
        await connection.query('BEGIN');await options.before(connection);
        await connection.query('SELECT public.process_badge_refresh_v1(100)');
        await connection.query('COMMIT');
      }catch(e){await connection.query('ROLLBACK');throw e;}finally{await connection.end();}
    });
    assert(results.every(r=>r.status==='fulfilled'));
    assert.equal((await db.query('SELECT count(*)::int n FROM public.badge_subjects WHERE user_id=$1',[victim.id])).rows[0].n,0);
    assert.equal((await db.query("SELECT count(*)::int n FROM public.badge_refresh_events WHERE subject_kind='customer' AND target_id=$1",[victim.id])).rows[0].n,0);
  });
  await check('D small-cohort tie uses stable shop UUID and repeat purchases count one customer',async()=>{
    await db.query('UPDATE public.badge_area_versions SET approved=true WHERE id=$1',[version]);
    await purchase(customers[0]);await purchase(customers[0]);
    await purchase(customers[0],f.otherShop,f.other,otherListing);
    const a=(await db.query('SELECT public._badge_neighborhood_d($1,clock_timestamp()) value',[f.shop])).rows[0].value;
    const b=(await db.query('SELECT public._badge_neighborhood_d($1,clock_timestamp()) value',[f.otherShop])).rows[0].value;
    assert.equal(a.customers,1);assert.equal(b.customers,1);assert.equal(a.cohort,2);
    assert.equal(a.eligible,f.shop<f.otherShop);assert.equal(b.eligible,f.otherShop<f.shop);
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.otherShop]);
    assert.equal(badge(await trust(),'neighborhood').eligible,true);
    await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.otherShop]);
  });
  await check('D depends on C lifecycle readiness and retains legacy compatibility refresh events',async()=>{
    await db.query('UPDATE public.review_protocol_config SET enabled=false');
    assert.equal((await call(f.merchant,'badge_capabilities_v1')).enabled,false);
    assert.equal((await trust()).enabled,false);
    const legacy=await f.session();await purchase(legacy,f.otherShop,f.other,otherListing);
    const before=(await db.query('SELECT max(id) id FROM public.badge_refresh_events')).rows[0].id;
    await call(legacy,'submit_product_review',[f.product,4,'Yerel eski istemci','Uyumluluk']);
    assert((await db.query("SELECT count(*)::int n FROM public.badge_refresh_events WHERE id>$1 AND subject_kind='customer' AND target_id=$2",[before,legacy.id])).rows[0].n>0);
    await db.query('UPDATE public.review_protocol_config SET enabled=true');
    assert.equal((await call(f.merchant,'badge_capabilities_v1')).enabled,true);
  });
  const publicOffers=()=>call(f.other,'read_shop_campaigns_v1',[f.shop,null]);
  const owned=()=>call(f.merchant,'read_merchant_campaigns_v1',[f.shop,30,0]);
  const draft=(extra={})=>({title:'Mağazada bu hafta',description:'Geçerli ürünleri mağazada inceleyin.',type:'announcement',scope:'single',
    listing_ids:[listing],image_ids:[],starts_at:new Date(Date.now()-60000).toISOString(),ends_at:new Date(Date.now()+86400000).toISOString(),...extra});
  const mutate=(id,revision,action,data=null,request=randomUUID(),actor=f.merchant,options)=>call(actor,'mutate_campaign_v1',[f.shop,id,revision,request,action,data],options);
  let offer, originalDraft;
  await check('F default OFF, owned writes, strict draft validation and no direct history access',async()=>{
    assert.equal((await call(f.merchant,'campaign_capabilities_v1')).enabled,false);
    await assert.rejects(mutate(null,null,'save',draft()),/CAMPAIGN_DISABLED/);
    await db.query('UPDATE public.campaign_protocol_config SET enabled=true');
    await assert.rejects(mutate(null,null,'save',draft(),randomUUID(),f.other),/CAMPAIGN_SHOP_FORBIDDEN/);
    await assert.rejects(mutate(null,null,'save',draft({listing_ids:[otherListing]})),/CAMPAIGN_LISTING_FORBIDDEN/);
    await assert.rejects(mutate(null,null,'save',draft({coupon:'forbidden'})),/CAMPAIGN_INVALID_ARGUMENT/);
    await assert.rejects(mutate(null,null,'save',draft({ends_at:'infinity'})),/CAMPAIGN_INVALID_ARGUMENT/);
    await assert.rejects(mutate(null,null,'save',draft({scope:'multiple',listing_ids:[listing,listing]})),/CAMPAIGN_INVALID_ARGUMENT/);
    await assert.rejects(mutate(null,null,'save',draft({type:'price',price_minor:1.1})),/CAMPAIGN_INVALID_ARGUMENT/);
    await assert.rejects(mutate(null,null,'save',draft({type:'price',price_minor:'1000'})),/CAMPAIGN_INVALID_ARGUMENT/);
    await assert.rejects(mutate(null,null,'save',draft({title:42})),/CAMPAIGN_INVALID_ARGUMENT/);
    for(const table of ['campaign_requests','campaign_revisions','merchant_campaigns'])
      await assert.rejects(sqlAs(config,f.merchant,`SELECT * FROM public.${table}`),e=>e.code==='42501');
  });
  await check('F concurrent exact retry creates one draft; changed payload and stale revision rejected',async()=>{
    originalDraft=draft();const request=randomUUID();
    const results=await contended(db,options=>mutate(null,null,'save',originalDraft,request,f.merchant,options),options=>mutate(null,null,'save',originalDraft,request,f.merchant,options));
    assert(results.every(r=>r.status==='fulfilled'));assert.deepEqual(results[0].value,results[1].value);offer=results[0].value;
    assert.equal((await owned()).total,1);assert.equal((await publicOffers()).campaigns.length,0);
    await assert.rejects(mutate(null,null,'save',{...originalDraft,title:'Farklı'},request),/CAMPAIGN_REQUEST_CONFLICT/);
    await assert.rejects(mutate(offer.id,randomUUID(),'activate'),/CAMPAIGN_CHANGED/);
    const competing=await contended(db,options=>mutate(offer.id,offer.revision_id,'activate',null,randomUUID(),f.merchant,options),options=>mutate(offer.id,offer.revision_id,'save',originalDraft,randomUUID(),f.merchant,options));
    assert.equal(competing.filter(r=>r.status==='fulfilled').length,1);assert.match(competing.find(r=>r.status==='rejected').reason.message,/CAMPAIGN_CHANGED/);
    offer=competing.find(r=>r.status==='fulfilled').value;
  });
  await check('F current public projection respects pause, dates, listing eligibility and source ownership',async()=>{
    assert.equal((await publicOffers()).campaigns.length,1);
    await db.query('UPDATE public.shop_products SET is_available=false WHERE id=$1',[listing]);
    assert.equal((await publicOffers()).campaigns.length,0);assert.equal((await owned()).campaigns[0].status,'blocked');
    await db.query('UPDATE public.shop_products SET is_available=true WHERE id=$1',[listing]);
    assert.equal((await publicOffers()).campaigns.length,1);
    offer=await mutate(offer.id,offer.revision_id,'pause');assert.equal((await publicOffers()).campaigns.length,0);
    offer=await mutate(offer.id,offer.revision_id,'save',draft({starts_at:new Date(Date.now()+60000).toISOString()}));
    offer=await mutate(offer.id,offer.revision_id,'activate');assert.equal((await owned()).campaigns[0].status,'scheduled');
    assert.equal((await publicOffers()).campaigns.length,0);
    offer=await mutate(offer.id,offer.revision_id,'save',draft({ends_at:new Date(Date.now()-1000).toISOString()}));
    await assert.rejects(mutate(offer.id,offer.revision_id,'activate'),/CAMPAIGN_ENDED/);
    offer=await mutate(offer.id,offer.revision_id,'save',draft());offer=await mutate(offer.id,offer.revision_id,'activate');
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
    assert.equal((await publicOffers()).campaigns.length,0);
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]);
  });
  await check('F amount/percentage publication has separate gate; price changes never rewrite cart or QR terms',async()=>{
    offer=await mutate(offer.id,offer.revision_id,'save',draft({type:'price',price_minor:1000}));
    await assert.rejects(mutate(offer.id,offer.revision_id,'activate'),/price_publication_pending/);
    await db.query('UPDATE public.campaign_protocol_config SET price_publication_enabled=true');
    offer=await mutate(offer.id,offer.revision_id,'activate');
    assert.equal((await publicOffers()).campaigns[0].price_minor,1000);
    const before=(await db.query('SELECT price FROM public.shop_products WHERE id=$1',[listing])).rows[0].price;assert.equal(Number(before),12);
    await db.query('UPDATE public.shop_products SET price=9 WHERE id=$1',[listing]);
    assert.equal((await publicOffers()).campaigns.length,0);assert.equal((await owned()).campaigns[0].blocked_reason,'price_changed');
    await db.query('UPDATE public.shop_products SET price=12 WHERE id=$1',[listing]);
    const buyer=await f.session(),p=await purchase(buyer);
    const item=(await db.query('SELECT unit_price FROM public.verified_transaction_items WHERE verified_transaction_id=$1',[p.id])).rows[0];assert.equal(Number(item.unit_price),12);
    offer=await mutate(offer.id,offer.revision_id,'save',draft({type:'percentage',percentage_basis_points:1250,scope:'all',listing_ids:[]}));
    offer=await mutate(offer.id,offer.revision_id,'activate');
    assert.equal((await publicOffers()).campaigns[0].percentage_basis_points,1250);
    await db.query('UPDATE public.campaign_protocol_config SET price_publication_enabled=false');
    assert.equal((await publicOffers()).campaigns.length,0);
  });
  await check('F selected image must be owned/published/in-scope; invalid storage metadata is omitted',async()=>{
    const image=await call(f.merchant,'merchant_prepare_listing_image_v1',[listing,'image/png',68]);
    await assert.rejects(mutate(null,null,'save',draft({image_ids:[image.id]})),/CAMPAIGN_IMAGE_FORBIDDEN/);
    await db.query('INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',[image.bucket_id,image.object_path,{mimetype:'image/png',size:68}]);
    await call(f.merchant,'merchant_change_listing_images_v1',[listing,'publish',image.id,null]);
    offer=await mutate(offer.id,offer.revision_id,'save',draft({image_ids:[image.id]}));
    offer=await mutate(offer.id,offer.revision_id,'activate');assert.equal((await publicOffers()).campaigns[0].images.length,1);
    await db.query("UPDATE storage.objects SET metadata='{}' WHERE bucket_id=$1 AND name=$2",[image.bucket_id,image.object_path]);
    assert.equal((await publicOffers()).campaigns[0].images.length,0);
    const foreign=await call(f.other,'merchant_prepare_listing_image_v1',[otherListing,'image/png',68]);
    await assert.rejects(mutate(null,null,'save',draft({image_ids:[foreign.id]})),/CAMPAIGN_IMAGE_FORBIDDEN/);
    await assert.rejects(db.query('DELETE FROM public.campaign_revisions WHERE campaign_id=$1',[offer.id]),/append-only/);
    const history=await call(f.merchant,'read_campaign_history_v1',[f.shop,offer.id,100,0]);assert(history.history.length>5);
    assert.equal(JSON.stringify(await publicOffers()).includes('actor_subject'),false);
  });
  return checks;
}
