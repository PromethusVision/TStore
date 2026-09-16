// Offline archive inspection only. Never connects to a database or emits rows.
import { readFileSync, statSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { isAbsolute, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

function requireCondition(condition, code) {
  if (!condition) throw new Error(code);
}

try {
  const args = process.argv.slice(2);
  requireCondition(args.length === 6, 'EXPECTED_DUMP_READER_OUTPUT_ARGUMENTS');
  const options = {};
  for (let i = 0; i < args.length; i += 2) {
    requireCondition(['--dump', '--pg-restore', '--output'].includes(args[i]), 'UNKNOWN_ARGUMENT');
    requireCondition(!options[args[i]], 'DUPLICATE_ARGUMENT');
    options[args[i]] = args[i + 1];
  }
  for (const key of ['--dump', '--pg-restore', '--output']) {
    requireCondition(options[key] && isAbsolute(options[key]), 'ABSOLUTE_PATH_REQUIRED');
  }
  const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
  requireCondition(resolve(options['--output']) === resolve(root, 'docs/data/w52h_r_backup_archive_inspection.json'), 'SANITIZED_REPORT_OUTPUT_REQUIRED');
  requireCondition(!resolve(options['--dump']).toLowerCase().startsWith(root.toLowerCase() + sep), 'DUMP_MUST_REMAIN_OUTSIDE_REPO');
  const preflight = JSON.parse(readFileSync(resolve(root, 'docs/data/w52h_production_preflight_manifest.json'), 'utf8'));
  const dumpInfo = statSync(options['--dump']);
  requireCondition(dumpInfo.isFile() && dumpInfo.size > 0, 'DUMP_MISSING_OR_EMPTY');
  const archive = readFileSync(options['--dump']);
  requireCondition(archive.subarray(0, 5).toString() === 'PGDMP', 'CUSTOM_ARCHIVE_MAGIC_REQUIRED');
  const digest = createHash('sha256').update(archive).digest('hex');

  const run = argv => {
    const result = spawnSync(options['--pg-restore'], argv, {
      encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, windowsHide: true,
    });
    // Do not emit stderr: it could contain source SQL or sensitive row values.
    requireCondition(!result.error && result.status === 0, 'OFFLINE_READER_FAILED');
    requireCondition(!result.stderr.trim(), 'OFFLINE_READER_WARNING_REQUIRES_PRIVATE_REVIEW');
    return result.stdout;
  };
  const readerVersion = run(['--version']).trim();
  requireCondition(/^pg_restore \(PostgreSQL\) 17\./.test(readerVersion), 'PG17_READER_REQUIRED');
  const toc = run(['--list', options['--dump']]);
  const headerValue = label => toc.match(new RegExp(`^;\\s*${label}:\\s*(.+)$`, 'm'))?.[1]?.trim();
  const sourceVersion = headerValue('Dumped from database version');
  const toolVersion = headerValue('Dumped by pg_dump version');
  requireCondition(sourceVersion === '17.6', 'SOURCE_VERSION_MISMATCH');
  requireCondition(toolVersion === '17.11', 'EXPECTED_MANUAL_DUMP_TOOL_MISMATCH');
  // Without --dbname this renders the archive into memory, not a database.
  const sql = run(['--file=-', options['--dump']]);
  requireCondition(/-- PostgreSQL database dump complete/.test(sql), 'INCOMPLETE_SQL_RENDER');
  const copyTables = new Map();
  const copyPattern = /^COPY ([a-z_]+)\.([a-z_]+) \(([^\r\n]+)\) FROM stdin;\r?\n([\s\S]*?)^\\\.\r?$/gm;
  for (const match of sql.matchAll(copyPattern)) {
    const table = `${match[1]}.${match[2]}`;
    if (!['public.categories', 'public.products', 'public.shop_products', 'public.shops', 'supabase_migrations.schema_migrations'].includes(table)) continue;
    requireCondition(!copyTables.has(table), 'DUPLICATE_COPY_BLOCK');
    const columns = match[3].split(', ').map(c => c.replace(/^"|"$/g, ''));
    const lines = match[4].replace(/\r?\n$/, '').split(/\r?\n/).filter(Boolean);
    const rows = lines.map(line => {
      const values = line.split('\t');
      requireCondition(values.length === columns.length, 'COPY_COLUMN_COUNT_MISMATCH');
      return Object.fromEntries(columns.map((c, i) => [c, values[i] === '\\N' ? null : values[i]]));
    });
    copyTables.set(table, rows);
  }
  const rows = table => {
    requireCondition(copyTables.has(table), 'REQUIRED_COPY_BLOCK_MISSING');
    return copyTables.get(table);
  };
  const categories = rows('public.categories');
  const products = rows('public.products');
  const listings = rows('public.shop_products');
  const shops = rows('public.shops');
  const ledger = rows('supabase_migrations.schema_migrations');
  const counts = { categories: categories.length, products: products.length, listings: listings.length, shops: shops.length, migration_ledger: ledger.length };
  const expected = { categories: 4, products: 20, listings: 285, shops: 57, migration_ledger: 9 };
  for (const key of Object.keys(expected)) requireCondition(counts[key] === expected[key], 'ARCHIVE_BASELINE_COUNT_MISMATCH');
  const categoryIds = new Set(categories.map(r => r.id));
  const productIds = new Set(products.map(r => r.id));
  const shopIds = new Set(shops.map(r => r.id));
  const orphanProducts = products.filter(r => !categoryIds.has(r.category_id)).length;
  const orphanListings = listings.filter(r => !productIds.has(r.product_id) || !shopIds.has(r.shop_id)).length;
  requireCondition(orphanProducts + orphanListings === 0, 'ARCHIVE_ORPHAN_RELATION');
  for (const data of [categories, products, listings, shops]) requireCondition(new Set(data.map(r => r.id)).size === data.length, 'ARCHIVE_DUPLICATE_ID');
  requireCondition(categories.every(r => r.parent_id === null), 'LEGACY_ROOT_SHAPE_MISMATCH');
  const expectedReferences = new Map(preflight.observed.product_category_references.map(r => [r.product_id, r.legacy_category_id]));
  requireCondition(products.every(r => expectedReferences.get(r.id) === r.category_id), 'ARCHIVE_PRODUCT_REFERENCE_MISMATCH');
  const expectedLedger = new Map(preflight.observed.migration_ledger.map(r => [r.version, r.name]));
  requireCondition(ledger.every(r => expectedLedger.get(r.version) === r.name && r.statements && r.statements !== '{}'), 'ARCHIVE_LEDGER_MISMATCH');
  const listingRelationsMd5 = createHash('md5').update([...listings].sort((a, b) => a.id.localeCompare(b.id)).map(r => `${r.id}:${r.shop_id}:${r.product_id}`).join(',')).digest('hex');
  requireCondition(listingRelationsMd5 === preflight.observed.fingerprints_md5.listing_relations, 'ARCHIVE_LISTING_FINGERPRINT_MISMATCH');
  const functionNames = [...toc.matchAll(/ FUNCTION public ([a-z_]+)\(/g)].map(m => m[1]).sort();
  requireCondition(JSON.stringify(functionNames) === JSON.stringify([...preflight.observed.rpc_inventory_names].sort()), 'ARCHIVE_RPC_INVENTORY_MISMATCH');
  const rlsCoverage = ['categories', 'products', 'shop_products', 'shops'].every(t => new RegExp(`ALTER TABLE public\\.${t} ENABLE ROW LEVEL SECURITY;`).test(sql));
  requireCondition(rlsCoverage, 'ARCHIVE_CORE_RLS_MISSING');
  const extensions = [...toc.matchAll(/ EXTENSION - ([^\r\n]+)/g)].map(m => m[1].trim()).sort();
  const schemaNames = [...toc.matchAll(/ SCHEMA - (\S+) /g)].map(m => m[1]).sort();
  // Values below are deliberately aggregate metadata, never raw COPY data.
  const evidence = {
    contract: 'w52h-r-offline-backup-inspection-v1',
    result: 'PASS', meaning: 'ARCHIVE_INSPECTION_ONLY_NOT_RESTORE_PROOF',
    inspected_at_utc: new Date().toISOString(),
    archive: { path: options['--dump'], size_bytes: dumpInfo.size, sha256: digest, file_last_write_utc: dumpInfo.mtime.toISOString(), archive_created_at_raw: toc.match(/^; Archive created at (.+)$/m)?.[1] ?? null, archive_created_at_timezone: 'NOT_ENCODED_IN_HEADER', format: headerValue('Format'), source_postgres_version: sourceVersion, pg_dump_version: toolVersion, reader_version: readerVersion, toc_entries: Number(headerValue('TOC Entries')) },
    full_archive_render_to_memory: 'PASS', source_sql_executed: false, database_connection_attempted: false,
    counts, duplicate_core_ids: 0, orphan_products: orphanProducts, orphan_listings: orphanListings,
    expected_product_category_references_matched: products.length,
    migration_versions_names_and_nonempty_statements: 'PASS',
    listing_relations_md5: listingRelationsMd5, listing_relations_match_w52h: true,
    core_rls_enable_statements_present: true,
    public_function_inventory_match_w52h: true, public_function_count: functionNames.length,
    public_policy_count: [...toc.matchAll(/ POLICY public /g)].length,
    public_foreign_key_count: [...toc.matchAll(/ FK CONSTRAINT public /g)].length,
    public_index_count: [...toc.matchAll(/ INDEX public /g)].length,
    public_view_count: [...toc.matchAll(/ VIEW public /g)].length,
    nondefault_schemas: schemaNames, extensions,
    global_role_definitions_in_pg_dump: false,
    independent_live_full_product_row_fingerprint_available: false,
    restored_database_baseline_measured: false, production_rows_emitted_or_saved: false,
  };
  requireCondition(createHash('sha256').update(readFileSync(options['--dump'])).digest('hex') === digest, 'ARCHIVE_CHANGED_DURING_INSPECTION');
  writeFileSync(options['--output'], JSON.stringify(evidence, null, 2) + '\n');
  console.log(JSON.stringify(evidence, null, 2));
} catch (error) {
  // All intentional errors above are fixed codes; unexpected error details may
  // contain paths or subprocess buffers and must not be logged.
  const code = /^[A-Z0-9_]+$/.test(error.message) ? error.message : 'OFFLINE_INSPECTION_FAILED';
  console.error(code);
  process.exitCode = 1;
}
