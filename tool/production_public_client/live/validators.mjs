import {check,target,functions,version,stable,hash,literal} from './common.mjs';
import {identity} from '../../production_taxonomy/execution/validators.mjs';
import {canonicalData,snapshot} from '../../production_preview_bridge/execution/catalog.mjs';
import {ledger,legacyDataHashes} from '../../production_taxonomy/execution/catalog.mjs';
import {preflight as baseline} from '../../production_public_activation/validators.mjs';
import {activationView,verifyFacade,facadeRows} from '../executor.mjs';
import {asRole,denied} from '../../production_preview_bridge/execution/rpc-checks.mjs';

export async function unchangedData(db){
 return {canonical:await canonicalData(db),legacy:await legacyDataHashes(db),private_testers:hash(stable((await db.query('SELECT to_jsonb(t) AS row FROM production_preview_private.testers t ORDER BY to_jsonb(t)::text COLLATE "C"')).rows))};
}
export async function fullFingerprint(db){return hash(stable({data:await unchangedData(db),schema:await snapshot(db),ledger:await ledger(db)}));}
export async function offContract(db){
 const flags=(await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows;
 check(flags.length===1&&!flags[0].public_enabled&&!flags[0].preview_enabled,'PUBLIC_MUST_STAY_OFF');
 for(const role of ['anon','authenticated'])await asRole(db,role,null,async()=>{
  for(const fn of functions)await denied(db,`SELECT * FROM public.${fn}('production-taxonomy-client-v1','canonical-v1.0.0')`);
 });
 return {result:'PASS',anonymous_calls_denied:4,authenticated_calls_denied:4,expected_sqlstate:'42501',public_enabled:false};
}
export async function grants(db){
 const rows=(await db.query(`SELECT proname AS name,prosecdef AS definer,provolatile::text AS volatility,proconfig,
 EXISTS(SELECT 1 FROM aclexplode(coalesce(proacl,acldefault('f',proowner))) a WHERE a.grantee=0 AND a.privilege_type='EXECUTE') AS public_execute,
 has_function_privilege('anon',oid,'EXECUTE') AS anon_execute,has_function_privilege('authenticated',oid,'EXECUTE') AS authenticated_execute,
 has_function_privilege('service_role',oid,'EXECUTE') AS service_execute,
 (SELECT array_agg(pg_get_userbyid(a.grantee)::text ORDER BY pg_get_userbyid(a.grantee)::text) FROM aclexplode(coalesce(proacl,acldefault('f',proowner))) a WHERE a.grantee<>proowner AND a.privilege_type='EXECUTE') AS grantees
 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname=ANY($1::text[]) ORDER BY proname`,[functions])).rows;
 check(rows.length===4,'EXACT_FOUR_FUNCTIONS');
 for(const r of rows)check(r.volatility==='s'&&r.definer===(r.name==='production_public_read_capabilities_v1')&&stable(r.proconfig)===stable(['search_path=pg_catalog, public'])&&!r.public_execute&&r.anon_execute&&r.authenticated_execute&&!r.service_execute&&stable(r.grantees)===stable(['anon','authenticated']),'EXECUTE_OR_RLS_SECURITY');
 return {result:'PASS',functions:4,public_execute:false,client_execute_roles:['anon','authenticated'],stable:4,invoker:3,definer_fixed_search_path:1};
}
export async function state(db,installed){
 target(db);await identity(db);
 const activation=(await db.query("SELECT count(*)::int AS n FROM supabase_migrations.schema_migrations WHERE version='20260922001400'")).rows[0].n;
 check(activation===0,'0014_MUST_BE_ABSENT');
 const flags=(await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows;
 check(flags.length===1&&flags[0].public_enabled===false&&flags[0].preview_enabled===false,'PUBLIC_MUST_STAY_OFF');
 const count=(await db.query('SELECT count(*)::int AS n FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows[0].n;
 if(installed)check(count===1,'0015_LEDGER_REQUIRED');
 else {check(count===0,'0015_ALREADY_APPLIED');check((await facadeRows(db)).length===0,'UNLEDGERED_0015_OBJECTS');}
 let facade,security,off;
 if(installed){facade=await verifyFacade(db);security=await grants(db);}
 const base=await baseline(installed?activationView(db):db);
 if(installed)off=await offContract(db);
 return {result:'PASS',installed,public_enabled:false,activation_0014_present:false,legacy:'PASS',schema_security:'PASS',canonical_write_grants:base.security.client_write_grants,facade,security,off,fingerprint:await fullFingerprint(db)};
}
