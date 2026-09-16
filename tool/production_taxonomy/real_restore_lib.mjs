// Restricted to the named, network-disabled local Docker container. No remote DB driver.
import { readFileSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

export const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
export const container = 'w52hr-pg176-proof';
export const docker = 'C:/Users/Mustafa/AppData/Local/Programs/DockerDesktop/resources/bin/docker.exe';
export const dump = 'C:/Users/Mustafa/EsnaftavarBackups/w52h-r/EsnaftaVar-Production-W52H-R-full.dump';
export const imageDigest = 'supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00';
export const read = p => readFileSync(resolve(root, p), 'utf8').replaceAll('\r\n', '\n');
export const source = JSON.parse(read('docs/data/w52h_r_source_restore_metadata.json'));
export const sha256 = b => createHash('sha256').update(b).digest('hex');
export function check(ok, code) { if (!ok) throw new Error(code); }
export function stableJson(value) {
  if (Array.isArray(value)) return '[' + value.map(stableJson).join(',') + ']';
  if (value && typeof value === 'object') return '{' + Object.keys(value).sort().map(k => JSON.stringify(k) + ':' + stableJson(value[k])).join(',') + '}';
  return JSON.stringify(value);
}
export function safeFailure(error) {
  console.error(/^[A-Z0-9_:]+$/.test(error.message) ? error.message : 'LOCAL_PROOF_FAILED_PRIVATE_DETAILS_SUPPRESSED');
  process.exitCode = 1;
}
export function run(args, input) {
  const r = spawnSync(docker, ['--context', 'desktop-linux', ...args], {
    input, encoding: 'utf8', windowsHide: true, maxBuffer: 64 * 1024 * 1024, timeout: 240000,
  });
  if (r.error || r.status !== 0) {
    // Never emit raw SQL, COPY context, personal data, or subprocess buffers.
    const stderr = r.stderr || '';
    const objectError = stderr.match(/(?:role|schema|extension|relation|function|type) "([a-zA-Z0-9_. -]+)" (?:does not exist|already exists|is not available)/);
    const tag = stderr.match(/W(?:36|38|52H)_[A-Z0-9_]+/)?.[0];
    if (tag) throw new Error(tag);
    if (objectError) throw new Error('LOCAL_SQL_OBJECT_ERROR:' + objectError[1].replace(/[^a-zA-Z0-9_]/g, '_').toUpperCase());
    const sqlstate = stderr.match(/ERROR:\s+([0-9A-Z]{5}):/)?.[1];
    throw new Error('LOCAL_COMMAND_FAILED' + (sqlstate ? ':' + sqlstate : ''));
  }
  return r.stdout;
}
export function sql(db, input) {
  check(['postgres', 'w52hr_first', 'w52hr_second'].includes(db), 'DATABASE_ALLOWLIST');
  return run(['exec', '-i', container, 'psql', '-X', '-q', '-A', '-t', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose', '-h', '/tmp', '-U', 'supabase_admin', '-d', db], input);
}
function literal(value) {
  if (value === null) return 'NULL';
  if (Array.isArray(value)) return 'ARRAY[' + value.map(literal).join(',') + ']';
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') { check(Number.isFinite(value), 'FINITE_SQL_NUMBER'); return String(value); }
  return "'" + String(value).replaceAll("'", "''") + "'";
}
export class LocalDb {
  constructor(name) { check(['w52hr_first','w52hr_second'].includes(name), 'LOCAL_DB_NAME'); this.name = name; this.role = null; }
  prefix() { return "SET client_min_messages=warning; SET search_path TO public,extensions; SET esnaftavar.w52h.execution_scope='local-rehearsal';" + (this.role ? `SET ROLE ${this.role};` : ''); }
  async query(query, args = []) {
    const bound = query.replace(/\$(\d+)/g, (_, n) => literal(args[Number(n) - 1]));
    const output = sql(this.name, this.prefix() + `SELECT coalesce(jsonb_agg(to_jsonb(q)), '[]'::jsonb) FROM (${bound}) q;`);
    return { rows: JSON.parse(output.trim()) };
  }
  async exec(statement) {
    const role = statement.match(/^SET ROLE (anon|authenticated)$/);
    if (role) { this.role = role[1]; return; }
    if (statement === 'RESET ROLE') { this.role = null; return; }
    return sql(this.name, this.prefix() + statement);
  }
}
export function guard() {
  const context = JSON.parse(run(['context','inspect','desktop-linux']))[0];
  check(context.Endpoints.docker.Host === 'npipe:////./pipe/dockerDesktopLinuxEngine', 'LOCAL_DOCKER_ENDPOINT_REQUIRED');
  const state = JSON.parse(run(['inspect', container]))[0];
  check(state.State.Running && state.HostConfig.NetworkMode === 'none', 'NETWORK_ISOLATION_REQUIRED');
  check(!state.HostConfig.Privileged && Object.keys(state.HostConfig.PortBindings || {}).length === 0 && Object.keys(state.NetworkSettings.Ports || {}).length === 0, 'NO_PUBLISHED_PORTS_OR_PRIVILEGED_CONTAINER');
  check(state.Config.Labels['esnaftavar.task'] === 'w52h-r', 'TASK_CONTAINER_REQUIRED');
  const image = JSON.parse(run(['image','inspect',state.Image]))[0];
  check(image.RepoDigests.includes(imageDigest), 'PINNED_IMAGE_REQUIRED');
  check(state.Mounts.length === 1 && state.Mounts[0].Destination === '/backup/production.dump' && state.Mounts[0].RW === false, 'READONLY_DUMP_MOUNT_REQUIRED');
  const normalized = p => p.replaceAll('\\','/').toLowerCase();
  check(normalized(state.Mounts[0].Source) === normalized(dump), 'ORIGINAL_DUMP_REQUIRED');
  check(sha256(readFileSync(dump)) === '83029c3871ce1689851b08beb2690be202d7d22d79bcdbdda3b5eadd46c64b10', 'ORIGINAL_DUMP_HASH');
  check(sql('postgres', 'SHOW server_version;').trim() === '17.6', 'EXACT_PG176_REQUIRED');
  check(sql('postgres', 'SHOW listen_addresses;').trim() === '', 'TCP_DISABLED_REQUIRED');
  return { container_id: state.Id, image_digest: imageDigest, server_version: '17.6', network_mode: 'none', published_ports: [], dump_mount_readonly: true, tcp_listening: false };
}
export function writeEvidence(name, value) {
  check(/^w52h_r_[a-z_]+\.json$/.test(name), 'EVIDENCE_NAME');
  writeFileSync(resolve(root, 'docs/data', name), JSON.stringify(value,null,2) + '\n');
}
