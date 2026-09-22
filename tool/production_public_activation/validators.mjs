import {check,json,directory,stable,hash,literal,body,version,name,tables} from './common.mjs';
import {identity,verifyEntry,contract as legacyContract} from '../production_taxonomy/execution/validators.mjs';
import {ledger,ledgerSchema,legacyDataHashes} from '../production_taxonomy/execution/catalog.mjs';
import {baseline as bridgeBaseline,security as bridgeSecurity,verifyBridgeEntry,contract as bridgeContract} from '../production_preview_bridge/execution/validators.mjs';
import {snapshot} from '../production_preview_bridge/execution/catalog.mjs';
import {integrity} from '../production_taxonomy/real_contract_checks.mjs';
import {policy,structuralData} from './policy.mjs';
import {legacyCompatibility,publicContract} from './compatibility.mjs';
export async function security(db){
 check(stable(await snapshot(db))===stable(bridgeContract().after),'SCHEMA_SECURITY_DRIFT');
 await bridgeSecurity(db);
 const grants=(await db.query(`SELECT count(*)::int AS n FROM pg_class c CROSS JOIN (VALUES ('anon'),('authenticated')) r(role) WHERE c.relnamespace='public'::regnamespace AND c.relname=ANY($1::text[]) AND (has_table_privilege(r.role,c.oid,'INSERT') OR has_table_privilege(r.role,c.oid,'UPDATE') OR has_table_privilege(r.role,c.oid,'DELETE') OR has_table_privilege(r.role,c.oid,'TRUNCATE') OR has_any_column_privilege(r.role,c.oid,'INSERT') OR has_any_column_privilege(r.role,c.oid,'UPDATE'))`,[tables])).rows[0].n;
 check(grants===0,'CANONICAL_WRITE_EXPOSURE');
 const rls=(await db.query("SELECT count(*)::int AS n FROM pg_class WHERE relnamespace='public'::regnamespace AND relname=ANY($1::text[]) AND relrowsecurity",[tables])).rows[0].n;
 check(rls===9,'CANONICAL_RLS_REQUIRED');
 return {result:'PASS',client_write_grants:0,canonical_tables_with_rls:9,catalog_unchanged:true};
}
export async function activationEntry(db){
 const rows=(await db.query('SELECT name,statements FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows;
 check(rows.length===1&&rows[0].name===name&&rows[0].statements?.length===1&&hash(rows[0].statements[0])===hash(body(false)),'EXACT_ACTIVATION_LEDGER');
}
export async function state(db,active){
 await identity(db);await verifyEntry(db);await verifyBridgeEntry(db);
 if(active)await activationEntry(db);
 else check((await db.query('SELECT count(*)::int AS n FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows[0].n===0,'REAPPLY_PROTECTION');
 const entries=await ledger(db),expected=legacyContract();
 check(stable(entries.filter(r=>!['20260916001200','20260919001300',version].includes(r.version)))===stable(expected.ledger_baseline)&&entries.length===expected.ledger_baseline.length+(active?3:2),'EXACT_LEDGER_SET');
 check(stable(await ledgerSchema(db))===stable(expected.ledger_schema),'LEDGER_SCHEMA');
 check(stable(await legacyDataHashes(db))===stable(expected.legacy_data),'LEGACY_DATA_DRIFT');
 const flags=(await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows;
 check(flags.length===1&&flags[0].public_enabled===active&&!flags[0].preview_enabled,'EXACT_PUBLIC_FLAG');
 const counts=await integrity(db,true),gates=await policy(db,active);
 const expectedData=json(`${directory}/state-oracle.json`)[active?'active':'staged'];
 check(stable(await structuralData(db))===stable(expectedData),'EXACT_STRUCTURAL_DATA');
 const secured=await security(db);
 const legacy=await legacyCompatibility(db);
 const canonical=await publicContract(db,active);
 return {result:'PASS',public_enabled:active,counts,policy:gates,security:secured,legacy,canonical};
}
export async function preflight(db){
 // Strict frozen Production baseline; no schema normalization or repair here.
 await identity(db);
 check((await db.query('SELECT count(*)::int AS n FROM supabase_migrations.schema_migrations WHERE version=$1',[version])).rows[0].n===0,'REAPPLY_PROTECTION');
 check((await db.query('SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows[0]?.public_enabled===false,'PUBLIC_ALREADY_ON');
 await bridgeBaseline(db,true);
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE enabled AND expires_at>clock_timestamp()')).rows[0].n===0,'ACTIVE_PREVIEW_LEASE_MUST_EXPIRE_FIRST');
 check((await db.query('SELECT count(*)::int AS n FROM public.taxonomy_aliases WHERE is_active')).rows[0].n===0,'STAGED_ALIAS_BASELINE');
 return state(db,false);
}
export const postflight=db=>state(db,true);
