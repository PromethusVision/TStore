import { hash, stable } from './common.mjs';

export async function catalog(db) {
  const queries = {
    relations: `SELECT c.relname AS name,c.relkind::text AS kind,pg_get_userbyid(c.relowner) AS owner,c.relrowsecurity AS rls,c.relforcerowsecurity AS forced,c.relacl::text AS acl FROM pg_class c WHERE c.relnamespace='public'::regnamespace AND c.relkind IN ('r','p','v','m','S') ORDER BY c.relname`,
    columns: `SELECT table_name,column_name,ordinal_position,data_type,udt_name,is_nullable,column_default FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name,ordinal_position`,
    constraints: `SELECT conrelid::regclass::text AS relation,conname AS name,contype::text AS type,convalidated,pg_get_constraintdef(oid) AS definition FROM pg_constraint WHERE connamespace='public'::regnamespace ORDER BY conrelid::regclass::text,conname`,
    indexes: `SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname`,
    functions: `SELECT proname AS name,pg_get_function_identity_arguments(oid) AS arguments,pg_get_function_result(oid) AS returns,pg_get_functiondef(oid) AS definition,pg_get_userbyid(proowner) AS owner,proacl::text AS acl FROM pg_proc WHERE pronamespace='public'::regnamespace ORDER BY proname,pg_get_function_identity_arguments(oid)`,
    triggers: `SELECT tgrelid::regclass::text AS relation,tgname AS name,pg_get_triggerdef(oid) AS definition FROM pg_trigger WHERE tgrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) AND NOT tgisinternal ORDER BY tgrelid::regclass::text,tgname`,
    policies: `SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check FROM pg_policies WHERE schemaname='public' ORDER BY tablename,policyname`,
  };
  const result = {};
  for (const [name, query] of Object.entries(queries)) result[name] = (await db.query(query)).rows;
  return result;
}
export const catalogHashes = value => Object.fromEntries(Object.entries(value).map(([name, rows]) => [name, hash(stable(rows))]));
export async function ledgerSchema(db) {
  return (await db.query(`SELECT column_name,data_type,udt_name,is_nullable,column_default FROM information_schema.columns WHERE table_schema='supabase_migrations' AND table_name='schema_migrations' ORDER BY ordinal_position`)).rows;
}
export async function ledger(db) {
  return (await db.query(`SELECT version::text,name,md5(coalesce(statements::text,'')) AS statements_md5,cardinality(statements) AS statements_count FROM supabase_migrations.schema_migrations ORDER BY version`)).rows;
}
export async function legacyDataHashes(db) {
  const result = {};
  for (const table of ['categories','products','shop_products','shops','brands']) {
    const rows = (await db.query(`SELECT * FROM public.${table} ORDER BY id`)).rows;
    result[table] = { count: rows.length, sha256: hash(stable(rows)) };
  }
  return result;
}
