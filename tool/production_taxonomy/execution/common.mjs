import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const root = resolve(fileURLToPath(new URL('../../..', import.meta.url)));
export const directory = 'tool/production_taxonomy/execution';
export const project = 'mefhfvrgkwciubeajjeb';
export const version = '20260916001200';
export const migrationName = '0012_production_canonical_side_by_side';
export const candidatePath = `supabase/migrations/${version}_${migrationName}.sql`;
export const sourceHash = 'a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834';
export const originalBackupHash = '83029c3871ce1689851b08beb2690be202d7d22d79bcdbdda3b5eadd46c64b10';
export const read = path => readFileSync(resolve(root, path), 'utf8').replaceAll('\r\n', '\n');
export const json = path => JSON.parse(read(path));
export const hash = (value, algorithm = 'sha256') => createHash(algorithm).update(value).digest('hex');
export function check(value, code) { if (!value) throw new Error(`W52JB_${code}`); }
export const stable = value => Array.isArray(value) ? `[${value.map(stable).join(',')}]` :
  value && typeof value === 'object' ? `{${Object.keys(value).sort().map(key => `${JSON.stringify(key)}:${stable(value[key])}`).join(',')}}` : JSON.stringify(value);
export function literal(value) {
  if (value === null) return 'NULL';
  if (Array.isArray(value)) return `ARRAY[${value.map(literal).join(',')}]`;
  if (typeof value === 'boolean') return String(value);
  if (typeof value === 'number') { check(Number.isFinite(value), 'FINITE_NUMBER'); return String(value); }
  return `'${String(value).replaceAll("'", "''")}'`;
}
export const identifier = value => `"${value.replaceAll('"', '""')}"`;
export function safeError(error) {
  return error.message?.match(/W52(?:JB|H)_[A-Z0-9_]+/)?.[0] ?? (/^[A-Z0-9_]+$/.test(error.message ?? '') ? `W52JB_CONTRACT_${error.message}` : 'W52JB_OPERATION_FAILED_PRIVATE_DETAILS_SUPPRESSED');
}
export function payload() {
  const original = read(candidatePath);
  check(hash(original) === sourceHash, 'FROZEN_0012_CHANGED');
  const opening = original.indexOf('\nBEGIN;\n');
  check(opening > 0 && original.endsWith('COMMIT;\n'), 'TRANSACTION_BOUNDARIES');
  const body = original.slice(opening + '\nBEGIN;\n'.length, -'COMMIT;\n'.length);
  const oldGuard = " IF current_setting('esnaftavar.w52h.execution_scope',true) IS DISTINCT FROM 'local-rehearsal'\n THEN RAISE EXCEPTION 'W52H_LOCAL_REHEARSAL_ONLY_NO_PRODUCTION_WRITE_AUTHORIZATION'; END IF;";
  const newGuard = ` IF current_setting('esnaftavar.w52jb.target_ref',true) IS DISTINCT FROM '${project}'\n OR current_database()<>'postgres' OR session_user<>'postgres'\n OR current_setting('server_version')<>'17.6'\n THEN RAISE EXCEPTION 'W52JB_EXECUTION_CONTEXT'; END IF;`;
  check(body.split(oldGuard).length === 2, 'EXACT_GUARD_LOCATION');
  const sql = body.replace(oldGuard, newGuard);
  check(sql.replace(newGuard, oldGuard) === body, 'SEMANTIC_RECONSTRUCTION');
  check(!sql.includes('local-rehearsal'), 'LOCAL_GUARD_NOT_REPURPOSED');
  return { sql, sha256: hash(sql), source_sha256: sourceHash, unchanged_body_sha256: hash(body.replace(oldGuard, '/* EXECUTION_GUARD */')),
    changes: ['Outer BEGIN/COMMIT owned by dedicated executor', 'Local scope guard replaced by checked target/database/role/version guard'],
    reconstructed_source_sha256: hash(original.slice(0, opening) + '\nBEGIN;\n' + sql.replace(newGuard, oldGuard) + 'COMMIT;\n') };
}

export function validateBackup(metadata, bytes, now = Date.now()) {
  check(metadata && metadata.project_ref === project && metadata.database === 'postgres' && metadata.source_pg_version === '17.6', 'BACKUP_IDENTITY');
  check(metadata.format === 'CUSTOM' && /^17\./.test(metadata.tool_version), 'BACKUP_TOOL');
  const age = now - Date.parse(metadata.completed_at_utc);
  check(Number.isFinite(age) && age >= -30000 && age <= 15 * 60 * 1000, 'BACKUP_NOT_FRESH');
  check(bytes.length > 0 && bytes.subarray(0, 5).toString() === 'PGDMP', 'BACKUP_ARCHIVE');
  check(bytes.length === metadata.size_bytes && hash(bytes) === metadata.sha256, 'BACKUP_HASH');
  return Object.freeze({ ...metadata, verified: true });
}
