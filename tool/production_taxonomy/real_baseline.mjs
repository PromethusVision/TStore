import { guard, LocalDb, source, sql, run, container, check, sha256, stableJson, writeEvidence, safeFailure } from './real_restore_lib.mjs';
import { integrity, legacyQueries, legacyMetadata } from './real_contract_checks.mjs';

export const fingerprintSql = `SELECT jsonb_build_object(
 'products_full_rows_md5',(SELECT md5(string_agg(to_jsonb(p)::text,chr(10) ORDER BY id)) FROM public.products p),
 'categories_full_rows_md5',(SELECT md5(string_agg(to_jsonb(c)::text,chr(10) ORDER BY id)) FROM public.categories c),
 'ledger_full_rows_md5',(SELECT md5(string_agg(to_jsonb(m)::text,chr(10) ORDER BY version)) FROM supabase_migrations.schema_migrations m),
 'public_policies_md5',(SELECT md5(string_agg(to_jsonb(p)::text,chr(10) ORDER BY tablename,policyname)) FROM pg_policies p WHERE schemaname='public'),
 'public_functions_md5',(SELECT md5(string_agg(proname||':'||pg_get_function_identity_arguments(oid)||':'||pg_get_functiondef(oid),chr(10) ORDER BY proname,pg_get_function_identity_arguments(oid))) FROM pg_proc WHERE pronamespace='public'::regnamespace),
 'public_columns_md5',(SELECT md5(string_agg(table_name||':'||column_name||':'||data_type||':'||is_nullable||':'||coalesce(column_default,''),',' ORDER BY table_name,ordinal_position)) FROM information_schema.columns WHERE table_schema='public')
) AS fingerprints`;

export async function archiveRows(db) {
  const rendered = run(['exec',container,'pg_restore','--file=-','/backup/production.dump']);
  const toc = run(['exec',container,'pg_restore','--list','/backup/production.dump']);
  const copies = [...rendered.matchAll(/^COPY ([a-z_][a-z_0-9]*\.[a-z_][a-z_0-9]*) \(([^\r\n]+)\) FROM stdin;\r?\n([\s\S]*?)^\\\.\r?$/gm)];
  check(copies.length === [...toc.matchAll(/ TABLE DATA /g)].length && copies.length > 5, 'ALL_ARCHIVE_TABLE_DATA_COVERED');
  const normalized = s => s.replace(/\r?\n$/, '').split(/\r?\n/).filter(Boolean).sort();
  const result = [];
  for (const [, table, columns, data] of copies) {
    check(/^[a-z_0-9", ]+$/.test(columns), 'SAFE_COPY_COLUMN_NAMES');
    const restored = sql(db.name, `SET TimeZone='UTC'; SET DateStyle='ISO'; SET extra_float_digits=3; COPY (SELECT ${columns} FROM ONLY ${table}) TO STDOUT;`);
    const before = normalized(data); const after = normalized(restored);
    check(stableJson(before) === stableJson(after), 'ARCHIVE_TABLE_ROWS_MISMATCH:' + table.replace('.','_').toUpperCase());
    result.push({table,rows:after.length,ordered_copy_sha256:sha256(after.join('\n')),match:'PASS'});
  }
  return result;
}

export async function baseline(name) {
  guard();
  const db = new LocalDb(name);
  const counts = await integrity(db);
  const fingerprints = (await db.query(fingerprintSql)).rows[0].fingerprints;
  for (const [key,value] of Object.entries(source.fingerprints)) check(fingerprints[key] === value, 'LIVE_SOURCE_FINGERPRINT:' + key.toUpperCase());
  const extensions = (await db.query("SELECT extname AS name,extversion AS version FROM pg_extension ORDER BY extname")).rows;
  check(stableJson(extensions) === stableJson(source.extensions), 'EXTENSION_VERSIONS_MATCH_SOURCE');
  const database = (await db.query("SELECT pg_encoding_to_char(encoding) AS encoding,datcollate AS collate,datctype AS ctype FROM pg_database WHERE datname=current_database()")).rows[0];
  check(stableJson(database) === stableJson(source.database), 'SOURCE_LOCALE_MATCH');
  const fk = (await db.query("SELECT count(*)::int AS total,count(*) FILTER(WHERE NOT convalidated)::int AS unvalidated FROM pg_constraint WHERE contype='f' AND connamespace='public'::regnamespace")).rows[0];
  check(fk.total === 33 && fk.unvalidated === 0, 'PUBLIC_FK_VALIDATION');
  const eventTriggers = (await db.query("SELECT evtname AS name,pg_get_userbyid(evtowner) AS owner,evtenabled AS enabled FROM pg_event_trigger ORDER BY evtname")).rows;
  check(eventTriggers.length === 7 && eventTriggers.find(t=>t.name==='ensure_rls')?.owner === 'postgres', 'EVENT_TRIGGER_OWNERSHIP');
  const allRows = await archiveRows(db);
  const contracts = {anon:await legacyQueries(db,'anon'),authenticated:await legacyQueries(db,'authenticated')};
  const metadata = await legacyMetadata(db);
  const result={contract:'w52h-r-restored-baseline-v1',captured_at_utc:new Date().toISOString(),database:name,result:'PASS',counts,fingerprints,source_comparison:'All six fingerprints match fresh READ ONLY Production observations',extensions,database_locale:database,public_foreign_keys:fk,event_triggers:eventTriggers,archive_table_data:allRows,archive_rows_match:'PASS_ALL_TABLE_DATA_ENTRIES',legacy_queries:contracts,legacy_metadata_sha256:metadata,production_rows_emitted_or_saved:false};
  writeEvidence(name==='w52hr_first'?'w52h_r_first_restore_baseline.json':'w52h_r_second_restore_baseline.json',result);
  return result;
}

if (process.argv[1]?.endsWith('real_baseline.mjs')) {
  try {
    check(process.argv.length === 3 && ['--first','--second'].includes(process.argv[2]), 'BASELINE_STAGE_REQUIRED');
    const result=await baseline(process.argv[2]==='--first'?'w52hr_first':'w52hr_second');
    console.log(JSON.stringify({result:result.result,database:result.database,counts:result.counts,table_data_entries_compared:result.archive_table_data.length,live_fingerprints_matched:6,public_foreign_keys_validated:33}));
  } catch(error) { safeFailure(error); }
}
