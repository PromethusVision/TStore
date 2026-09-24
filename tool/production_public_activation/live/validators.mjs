import {check,target,stable,hash,literal} from './common.mjs';
import {preflight,postflight} from '../validators.mjs';
import {preservedData} from '../policy.mjs';
import {activationView,verifyFacade,facadeRows} from '../../production_public_client/executor.mjs';
import {grants,offContract,fullFingerprint} from '../../production_public_client/live/validators.mjs';
import {legacyDataHashes,ledger} from '../../production_taxonomy/execution/catalog.mjs';
import {snapshot} from '../../production_preview_bridge/execution/catalog.mjs';
import {asRole} from '../../production_preview_bridge/execution/rpc-checks.mjs';
export {fullFingerprint};
export async function preserved(db){return {data:await preservedData(db),legacy:await legacyDataHashes(db),schema:await snapshot(db),facade:await facadeRows(db),ledger:(await ledger(db)).filter(r=>r.version!=='20260922001400')};}
export async function publicReads(db){
 const ids=(await db.query('SELECT product_id::text AS id,public.production_taxonomy_assignment_visible_v1(canonical_category_id) AS eligible FROM public.product_canonical_assignments ORDER BY product_id')).rows;
 const eligible=ids.filter(r=>r.eligible).map(r=>r.id),gated=ids.filter(r=>!r.eligible).map(r=>r.id);
 check(eligible.length===14&&gated.length===6,'EXACT_ELIGIBLE_AND_GATED');
 const args="p_client_contract_version=>'production-taxonomy-client-v1',p_taxonomy_version=>'canonical-v1.0.0'";
 const call=async(name,extra='')=>(await db.query(`SELECT * FROM public.production_public_${name}_v1(${args}${extra?','+extra:''})`)).rows;
 const result={};
 for(const role of ['anon','authenticated'])await asRole(db,role,null,async()=>{
  const cap=(await call('read_capabilities'))[0]?.production_public_read_capabilities_v1;
  check(cap?.contract==='production-public-customer-reads-v1'&&cap.project_ref==='mefhfvrgkwciubeajjeb'&&cap.public_enabled===true&&cap.preview_required===false&&cap.tester_required===false&&cap.policy_fail_closed===true,'PUBLIC_READ_CAPABILITY');
  const products=await call('products','p_limit=>100');
  check(stable(products.map(r=>r.product_id).sort())===stable([...eligible].sort()),'PUBLIC_PRODUCT_SET');
  const listings=[];
  for(let offset=0;offset<1000;offset+=100){const page=await call('listings',`p_limit=>100,p_offset=>${offset}`);listings.push(...page);if(page.length<100)break;}
  check(listings.length>0&&new Set(listings.map(r=>r.shop_product_id)).size===listings.length&&listings.every(r=>eligible.includes(r.product_id)&&r.shop_product.product_id===r.product_id&&r.shop_product.products.category_id===r.canonical_category_id&&r.shop_product.shops.id===r.shop_product.shop_id),'PUBLIC_SELLER_PROJECTION');
  const shops=await call('shops','p_limit=>100');check(shops.length>0&&shops.every(s=>s.is_active),'PUBLIC_SHOPS');
  for(const p of products){
   const detail=await call('products',`p_product_id=>${literal(p.product_id)}::uuid`);
   check(detail.length===1&&detail[0].product_id===p.product_id&&detail[0].product.category_id===p.canonical_category_id,'PUBLIC_DETAIL');
   const sellers=await call('listings',`p_product_id=>${literal(p.product_id)}::uuid,p_limit=>100`);
   check(sellers.length>0&&sellers.every(s=>s.product_id===p.product_id),'PUBLIC_SELLERS');
  }
  for(const id of gated){check((await call('products',`p_product_id=>${literal(id)}::uuid`)).length===0&&(await call('listings',`p_product_id=>${literal(id)}::uuid`)).length===0,'GATED_PRODUCT_EXPOSED');}
  const first=listings[0].shop_product.shop_id;
  check((await call('shops',`p_shop_id=>${literal(first)}::uuid`)).length===1,'SHOP_DETAIL');
  check((await call('listings',`p_shop_id=>${literal(first)}::uuid`)).every(r=>r.shop_product.shop_id===first),'SHOP_PRODUCTS');
  check((await call('products',`p_term=>${literal(products[0].product.name)}`)).some(r=>r.product_id===products[0].product_id),'PUBLIC_SEARCH');
  result[role]={result:'PASS',eligible_products:14,gated_excluded:6,listing_rows:listings.length,shop_rows:shops.length,detail:'PASS',seller_comparison:'PASS',shop_detail:'PASS',search:'PASS',tester_required:false};
 });
 check(stable(result.anon)===stable(result.authenticated),'PUBLIC_ROLE_PARITY');return result;
}
export async function state(db,active){
 target(db);const facade=await verifyFacade(db),security=await grants(db);
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE enabled AND expires_at>clock_timestamp()')).rows[0].n===0,'ACTIVE_PREVIEW_LEASE_MUST_EXPIRE_FIRST');
 const base=await (active?postflight:preflight)(activationView(db));
 const reads=active?await publicReads(db):await offContract(db);
 return {result:'PASS',public_enabled:active,baseline:base,facade,security,public_reads:reads,fingerprint:await fullFingerprint(db)};
}
