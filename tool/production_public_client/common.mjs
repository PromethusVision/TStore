import {read,hash,json,stable,literal,root,project} from '../production_taxonomy/execution/common.mjs';
export {read,hash,json,stable,literal,root,project};
export const directory='tool/production_public_client';
export const migration='supabase/migrations/20260922001500_0015_production_public_customer_reads.sql';
export const version='20260922001500', name='0015_production_public_customer_reads';
export const activationSeal='6ec54cc42daa4f8d166bc1fc0f56982d42e0c4050c214b8ce307a6f6fc45c584';
export const functions=['production_public_read_capabilities_v1','production_public_products_v1','production_public_listings_v1','production_public_shops_v1'];
export function check(ok,code){if(!ok)throw Error('W52LB_'+code);}
export const safeError=e=>e?.message?.match(/W52(?:LB|LA|JB|KBY|H)_[A-Z0-9_]+/)?.[0]??'W52LB_PRIVATE_ERROR_SUPPRESSED';
export function payload(){const s=read(migration);check(s.split('BEGIN;').length===2&&s.endsWith('COMMIT;\n'),'PAYLOAD_TRANSACTION');return s.replace('BEGIN;','').replace(/COMMIT;\n$/,'');}
export const functionQuery="SELECT proname AS name,pg_get_function_identity_arguments(oid) AS arguments,pg_get_function_result(oid) AS returns,pg_get_functiondef(oid) AS definition,pg_get_userbyid(proowner) AS owner,proacl::text AS acl FROM pg_proc WHERE pronamespace='public'::regnamespace ORDER BY proname,pg_get_function_identity_arguments(oid)";
export const ledgerQuery="SELECT version::text,name,md5(coalesce(statements::text,'')) AS statements_md5,cardinality(statements) AS statements_count FROM supabase_migrations.schema_migrations ORDER BY version";
