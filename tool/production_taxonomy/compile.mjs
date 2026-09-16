// Offline compiler. No database connection, credentials, or remote apply path.
import { readFile, writeFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseCsv, sha256, check, sql } from '../taxonomy_migration/lib.mjs';

export const candidatePath = 'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql';
const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const read = async p => (await readFile(resolve(root, p), 'utf8')).replaceAll('\r\n', '\n');
const preflight = JSON.parse(await read('docs/data/w52h_production_preflight_manifest.json'));
const evidence = JSON.parse(await read('docs/data/production_20_product_canonical_mapping_validation.json'));
const mappingText = await read('docs/data/production_20_product_canonical_mapping.csv');
const mapping = parseCsv(mappingText).rows;
check(sha256(mappingText) === evidence.mapping_sha256_lf_utf8, 'OWNER_MAPPING_HASH');
check(mapping.length === 20 && evidence.owner_approved === 20 && evidence.unresolved === 0, 'OWNER_APPROVAL');
for (const source of evidence.canonical_sources) {
  const blob = execFileSync('git', ['show', `${preflight.base_head}:${source.path}`], { cwd: root });
  check(sha256(blob) === source.git_blob_sha256, `FROZEN_SOURCE:${source.path}`);
  check(blob.toString().replaceAll('\r\n', '\n') === await read(source.path), 'SOURCE_DRIFT');
}
const qualification = parseCsv(await read('docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv')).rows;
const canonical = parseCsv(await read('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')).rows;
const old10 = await read('supabase/migrations/20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql');
const old11 = await read('supabase/migrations/20260830001100_0011_canonical_taxonomy_contract_v2.sql');
for (const [name, text] of [
 ['20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql',old10],
 ['20260830001100_0011_canonical_taxonomy_contract_v2.sql',old11],
]) {
 const frozen = execFileSync('git',['show',`${preflight.base_head}:supabase/migrations/${name}`],{cwd:root,maxBuffer:8 * 1024 * 1024}).toString().replaceAll('\r\n','\n');
 check(text === frozen, `HISTORICAL_MIGRATION_CHANGED:${name}`);
}
const header = await read('tool/production_taxonomy/adapter_header.sql');
const tail = await read('tool/production_taxonomy/adapter_contract.sql');
const legacy = new Map(evidence.evidence.map(p => [p.product_id, p.legacy_category_id]));
const ledgerValues = preflight.observed.migration_ledger.map(r => `(${sql(r.version)},${sql(r.name)})`).join(',\n');
let schema = old10.slice(old10.indexOf('-- Additive Wave 36'), old10.indexOf('DO $guard$'));
let data = old10.slice(old10.indexOf('INSERT INTO public.categories('), old10.indexOf('CREATE OR REPLACE FUNCTION public.taxonomy_roots_v1'));
for (const name of ['schema', 'data']) check((name === 'schema' ? schema : data).length > 1000, 'SOURCE_SECTION');
// Copy frozen staged values and aliases, not Development guards or mutation policy.
schema = schema.replaceAll('public.categories', 'public.canonical_categories').replaceAll('categories_', 'canonical_categories_');
data = data.replaceAll('public.categories', 'public.canonical_categories');
const v2Start = old11.indexOf('CREATE TABLE IF NOT EXISTS public.taxonomy_contract_config');
const v2End = old11.indexOf('CREATE OR REPLACE FUNCTION public.taxonomy_set_preview_v2');
let contracts = old11.slice(v2Start, v2End)
  .replaceAll('public.categories', 'public.canonical_categories')
  .replaceAll('taxonomy_contract_config', 'production_taxonomy_config')
  .replace(/taxonomy_([a-z_]+)_v2/g, 'production_taxonomy_$1_v1')
  .replaceAll('taxonomy-client-v1', 'production-taxonomy-client-v1')
  .replaceAll('taxonomy-rpc-v2', 'production-taxonomy-rpc-v1')
  .replaceAll('rpc_generation <> 2', 'rpc_generation <> 1')
  .replace('  2,\n  true,\n  false', '  1,\n  false,\n  false')
  .replace('preview_supported BOOLEAN NOT NULL DEFAULT true', 'preview_supported BOOLEAN NOT NULL DEFAULT false')
  .replaceAll('preview_supported <> true', 'preview_supported <> false')
  .replace('IF p_preview AND NOT config_row.preview_enabled THEN', 'IF p_preview THEN')
  .replace("AND c.level = 1 AND c.parent_id IS NULL\n        AND c.lifecycle_state", "AND c.level = 1 AND c.parent_id IS NULL\n        AND config_row.public_enabled\n        AND c.lifecycle_state")
  .replace("'exact-leaf-visible-assignable-policy-eligible'::TEXT", "'production-shadow-mapping-policy-eligible-v1'::TEXT");
const qValues = qualification.map(r => `(${sql(r.DEVELOPMENT_UUID)}::uuid,${sql(r.QUALIFICATION)},${sql(r.EFFECTIVE_POLICY_GATE)},${sql(r.EFFECTIVE_PROFESSIONAL_REVIEW_GATE)},${sql(r.FAIL_CLOSED_REASON)})`).join(',\n');
const mappingValues = mapping.map(r => {
  const target = canonical.find(c => c.ID === r.PROPOSED_CANONICAL_UUID);
  check(target && !canonical.some(c => c.PARENT_ID === target.ID), 'NON_TERMINAL_MAPPING');
  return `(${sql(r.PRODUCT_ID)}::uuid,${sql(legacy.get(r.PRODUCT_ID))}::uuid,${sql(target.ID)}::uuid,${sql(r.PROPOSED_CANONICAL_PATH)},${sql(evidence.mapping_sha256_lf_utf8)})`;
}).join(',\n');
const output = `-- W52H Production-shaped adapter CANDIDATE; NOT remotely authorized.
-- No 0010/0011 ledger repair; no public activation; no legacy row mutation.
-- Frozen source 0010 SHA256: ${sha256(old10)}
-- Frozen source 0011 SHA256: ${sha256(old11)}
-- Owner mapping SHA256: ${evidence.mapping_sha256_lf_utf8}
${header.replace('/* EXPECTED_LEDGER */', ledgerValues)}
${schema}
${data}
CREATE TABLE public.canonical_category_qualification (
 category_id UUID PRIMARY KEY REFERENCES public.canonical_categories(id) ON DELETE RESTRICT,
 qualification TEXT NOT NULL, policy_gate TEXT NOT NULL, professional_gate TEXT NOT NULL,
 source_gate_reason TEXT NOT NULL
);
ALTER TABLE public.canonical_category_qualification ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.canonical_category_qualification FROM PUBLIC,anon,authenticated,service_role;
INSERT INTO public.canonical_category_qualification VALUES
${qValues};
${contracts}
${tail}
-- W52H_STAGE_D_EXACT_MAPPING
INSERT INTO public.product_canonical_assignments(product_id,legacy_category_id,canonical_category_id,canonical_path,owner_mapping_sha256) VALUES
${mappingValues};
DO $final$
BEGIN
 IF (SELECT count(*) FROM public.product_canonical_assignments) <> 20
 OR (SELECT count(*) FROM public.products) <> 20
 OR (SELECT count(*) FROM public.shop_products) <> 285
 OR (SELECT count(*) FROM public.shops) <> 57
 OR (SELECT count(*) FROM public.categories) <> 4
 THEN RAISE EXCEPTION 'W52H_FINAL_COUNTS'; END IF;
 IF EXISTS(SELECT 1 FROM public.product_canonical_assignments a JOIN public.products p ON p.id=a.product_id WHERE p.category_id<>a.legacy_category_id)
 THEN RAISE EXCEPTION 'W52H_LEGACY_REFERENCE_CHANGED'; END IF;
 IF (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1)
 OR EXISTS(SELECT 1 FROM public.canonical_categories WHERE is_active OR is_assignable OR lifecycle_state<>'staged')
 THEN RAISE EXCEPTION 'W52H_SURPRISE_ACTIVATION'; END IF;
END $final$;
COMMIT;
`;
check(!output.includes('tnipyxnvhgelwdpykyez'), 'DEVELOPMENT_BINDING_LEAK');
check(!/UPDATE public\.(products|categories|shop_products|shops)\b/i.test(output), 'LEGACY_MUTATION');
check(!/INSERT INTO supabase_migrations/i.test(output), 'LEDGER_MUTATION');
await writeFile(resolve(root, candidatePath), output);
await writeFile(resolve(root, 'tool/production_taxonomy/artifact_manifest.json'), JSON.stringify({
  candidate: candidatePath, sha256_lf_utf8: sha256(output), bytes_lf_utf8: Buffer.byteLength(output),
  owner_mapping_sha256: evidence.mapping_sha256_lf_utf8,
  source_0010_sha256: sha256(old10), source_0011_sha256: sha256(old11),
  canonical_sources: evidence.canonical_sources, target: 'production-shaped local rehearsal only',
}, null, 2) + '\n');
console.log(`COMPILED ${candidatePath}: ${sha256(output)}`);
