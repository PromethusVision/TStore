import { run, container, sql, sha256, stableJson, source } from './local.mjs';
import { check } from '../production_taxonomy/execution/common.mjs';
export const fingerprintSql = `SELECT jsonb_build_object(
 'products_full_rows_md5',(SELECT md5(string_agg(to_jsonb(p)::text,chr(10) ORDER BY id)) FROM public.products p),
 'categories_full_rows_md5',(SELECT md5(string_agg(to_jsonb(c)::text,chr(10) ORDER BY id)) FROM public.categories c),
 'ledger_full_rows_md5',(SELECT md5(string_agg(to_jsonb(m)::text,chr(10) ORDER BY version)) FROM supabase_migrations.schema_migrations m),
 'public_policies_md5',(SELECT md5(string_agg(to_jsonb(p)::text,chr(10) ORDER BY tablename,policyname)) FROM pg_policies p WHERE schemaname='public'),
 'public_functions_md5',(SELECT md5(string_agg(proname||':'||pg_get_function_identity_arguments(oid)||':'||pg_get_functiondef(oid),chr(10) ORDER BY proname,pg_get_function_identity_arguments(oid))) FROM pg_proc WHERE pronamespace='public'::regnamespace),
 'public_columns_md5',(SELECT md5(string_agg(table_name||':'||column_name||':'||data_type||':'||is_nullable||':'||coalesce(column_default,''),',' ORDER BY table_name,ordinal_position)) FROM information_schema.columns WHERE table_schema='public')
) AS fingerprints`;

export async function archiveRows(db, { preserve0012 = false } = {}) {
  const rendered = run(['exec',container,'pg_restore','--file=-','/backup/production.dump']);
  const toc = run(['exec',container,'pg_restore','--list','/backup/production.dump']);
  const copies = [...rendered.matchAll(/^COPY ([a-z_][a-z_0-9]*\.[a-z_][a-z_0-9]*) \(([^\r\n]+)\) FROM stdin;\r?\n([\s\S]*?)^\\\.\r?$/gm)];
  check(copies.length === [...toc.matchAll(/ TABLE DATA /g)].length && copies.length > 5, 'ALL_ARCHIVE_TABLE_DATA_COVERED');
  const normalized = s => s.replace(/\r?\n$/, '').split(/\r?\n/).filter(Boolean).sort();
  const result = [];
  for (const [, table, columns, data] of copies) {
    check(/^[a-z_0-9", ]+$/.test(columns), 'SAFE_COPY_COLUMN_NAMES');
    // The newest archive predates 0012. Its exact ten-row post-0012 ledger is
    // independently compared before/after bridge rollback by the harness.
    const filter = preserve0012 && table === 'supabase_migrations.schema_migrations'
      ? " WHERE version<>'20260916001200'" : '';
    const restored = sql(db.name, `SET TimeZone='UTC'; SET DateStyle='ISO'; SET extra_float_digits=3; COPY (SELECT ${columns} FROM ONLY ${table}${filter}) TO STDOUT;`);
    const before = normalized(data); const after = normalized(restored);
    check(stableJson(before) === stableJson(after), 'ARCHIVE_TABLE_ROWS_MISMATCH_' + table.replace('.','_').toUpperCase());
    result.push({table,rows:after.length,ordered_copy_sha256:sha256(after.join('\n')),match:'PASS'});
  }
  return result;
}


export async function baseline(db) {
 const fingerprints=(await db.query(fingerprintSql)).rows[0].fingerprints;
 for(const [key,value] of Object.entries(source.fingerprints)) check(fingerprints[key]===value,'SOURCE_FINGERPRINT_'+key.toUpperCase());
 const rows=await archiveRows(db);
 check(rows.length===69,'ALL_69_TABLE_DATA');
 return {result:'PASS',fingerprints,table_data:rows,archive_rows_match:'PASS_ALL_69',original_backup:true};
}
