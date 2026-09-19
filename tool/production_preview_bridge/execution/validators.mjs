import {check,json,stable,directory,version,name,payload,functions,facade,hash} from './common.mjs';
import {identity,contract as oldContract,verifyEntry,legacyContract} from '../../production_taxonomy/execution/validators.mjs';
import {ledger,ledgerSchema,legacyDataHashes} from '../../production_taxonomy/execution/catalog.mjs';
import {integrity,canonicalQueries} from '../../production_taxonomy/real_contract_checks.mjs';
import {snapshot,unchanged0012Catalog} from './catalog.mjs';
import {existingUsers,checkAllowlist} from './authorization.mjs';
import {previewContracts} from './rpc-checks.mjs';
export const contract=()=>json(`${directory}/contract.json`);
export async function verifyBridgeEntry(db){
 const rows=(await db.query('SELECT name,statements FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows;
 check(rows.length===1&&rows[0].name===name&&rows[0].statements?.length===1&&hash(rows[0].statements[0])===payload().sha256,'BX_LEDGER_PAYLOAD');
}
export async function baseline(db,present){
 const target=await identity(db);
 await verifyEntry(db);
 const old=oldContract(),rows=await ledger(db);
 check(stable(rows.filter(r=>![version,'20260916001200'].includes(r.version)))===stable(old.ledger_baseline),'BX_HISTORICAL_LEDGER');
 check(rows.length===old.ledger_baseline.length+(present?2:1),'BX_REAPPLY_OR_LEDGER_STATE');
 if(present)await verifyBridgeEntry(db);
 check(stable(await ledgerSchema(db))===stable(old.ledger_schema),'BX_LEDGER_SCHEMA');
 check(stable(await legacyDataHashes(db))===stable(old.legacy_data),'BX_LEGACY_DATA');
 check(stable(await unchanged0012Catalog(db))===stable(old.catalog_after),'BX_0012_SCHEMA_DRIFT');
 check(stable(await snapshot(db))===stable(contract()[present?'after':'before']),'BX_SCHEMA_SECURITY_DRIFT');
 const counts=await integrity(db,true);
 const flags=(await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows;
 check(flags.length===1&&!flags[0].public_enabled&&!flags[0].preview_enabled,'BX_PUBLIC_ACTIVATION_OFF');
 check((await db.query("SELECT count(*)::int AS n FROM public.canonical_categories WHERE is_active OR is_assignable OR lifecycle_state<>'staged'")).rows[0].n===0,'BX_STAGED_ONLY');
 await legacyContract(db);
 for(const role of ['anon','authenticated']){
  await db.exec(`SET LOCAL ROLE ${role};`);
  try{await canonicalQueries(db,false);check((await db.query('SELECT count(*)::int AS n FROM public.product_canonical_assignments')).rows[0].n===0,'BX_PUBLIC_MAPPING_LEAK');}finally{await db.exec('RESET ROLE;');}
 }
 return {result:'PASS',target,counts,public_activation:false,legacy:'PASS',schema_security:'PASS',ledger:'PASS'};
}
export async function preflight(db,plan){const result=await baseline(db,false);await existingUsers(db,plan);return result;}
export async function security(db){
 const grants=(await db.query("SELECT proname,provolatile,prosecdef,proconfig,has_function_privilege('anon',oid,'EXECUTE') AS anon,has_function_privilege('authenticated',oid,'EXECUTE') AS authenticated FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname=ANY($1::text[]) ORDER BY proname",[functions])).rows;
 check(grants.length===15&&grants.every(f=>f.provolatile==='s'&&f.proconfig?.includes('search_path=pg_catalog, public')&&!f.anon&&f.authenticated===facade.includes(f.proname)),'BX_FUNCTION_SECURITY');
 check(grants.find(f=>f.proname==='production_preview_products_v1').prosecdef===false,'BX_PRODUCTS_INVOKER_RLS');
 const exposed=(await db.query("SELECT count(*)::int AS n FROM (VALUES ('anon'),('authenticated'),('service_role')) r(role) WHERE has_table_privilege(r.role,'production_preview_private.testers','SELECT,INSERT,UPDATE,DELETE') OR has_schema_privilege(r.role,'production_preview_private','USAGE,CREATE')")).rows[0].n;
 check(exposed===0,'BX_PRIVATE_ALLOWLIST_GRANTS');
 return {result:'PASS',stable_functions:15,private_client_grants:0,product_rls:'INVOKER_PRESERVED'};
}
export async function postflight(db,plan){return {...await baseline(db,true),allowlist:await checkAllowlist(db,plan),security:await security(db),preview:await previewContracts(db,plan)};}
