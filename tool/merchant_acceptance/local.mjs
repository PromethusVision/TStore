import { spawn } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
import { inside, localUrl, localContainer, ports, projectPattern } from './safety.mjs';

export const root = fileURLToPath(new URL('../../', import.meta.url));
export const scratch = resolve(root, '.buildlog/merchant-acceptance');
const shim = fileURLToPath(new URL('node_modules/supabase/dist/supabase.js', import.meta.url));
const engine = process.platform === 'win32' ? 'npipe:////./pipe/dockerDesktopLinuxEngine' : 'unix:///var/run/docker.sock';
const env = { ...process.env, DOCKER_HOST: engine, SUPABASE_TELEMETRY_DISABLED: '1', DO_NOT_TRACK: '1' };
// No externally selected Docker context or hosted-project credential is inherited.
for (const key of ['DOCKER_CONTEXT', 'DOCKER_TLS_VERIFY', 'DOCKER_CERT_PATH', 'SUPABASE_ACCESS_TOKEN', 'SUPABASE_DB_PASSWORD']) delete env[key];

export function command(executable, args, cwd = root, timeout = 60000, detachOutput = false) {
  return new Promise((ok, fail) => {
    const child = spawn(executable, args, { cwd, env, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    const chunks = []; let size = 0;
    const timer = setTimeout(() => child.kill(), timeout);
    child.stdout.on('data', b => { size += b.length; if (size < 4e6) chunks.push(b); });
    // CLI output may contain local signing keys. Never forward it to terminal.
    child.stderr.resume();
    child.once('error', () => { clearTimeout(timer); fail(new Error('LOCAL_TOOL_UNAVAILABLE')); });
    child.once(detachOutput ? 'exit' : 'close', code => {
      clearTimeout(timer);
      if (detachOutput) { child.stdout.destroy(); child.stderr.destroy(); }
      if (code !== 0) fail(new Error('LOCAL_COMMAND_FAILED')); else ok(Buffer.concat(chunks).toString());
    });
  });
}
export const docker = args => command('docker', ['--host', engine, ...args]);
export const cli = (dir, args, timeout) => command(process.execPath, [shim, ...args, '--workdir', dir], dir, timeout);

export async function readRun(directory) {
  const dir = await inside(scratch, directory);
  const run = JSON.parse(await readFile(resolve(dir, 'run.json'), 'utf8'));
  assert.equal(run.kind, 'synthetic-merchant-ab-local-only'); assert(projectPattern.test(run.project));
  assert.equal(dir, await inside(scratch, resolve(scratch, run.project)));
  const config = await readFile(resolve(dir, 'supabase/config.toml'), 'utf8');
  assert.equal(config, configuration(run.project), 'Unexpected local configuration');
  return { ...run, dir };
}

function configuration(project) {
  assert(projectPattern.test(project));
  return `project_id = "${project}"
[api]
enabled = true
port = ${ports.api}
schemas = ["public", "graphql_public"]
extra_search_path = ["public", "extensions"]
max_rows = 1000
[db]
port = ${ports.db}
shadow_port = ${ports.shadow}
major_version = 17
[db.seed]
enabled = false
[db.pooler]
enabled = false
[auth]
enabled = true
site_url = "http://127.0.0.1:55431"
jwt_expiry = 3600
enable_signup = true
[auth.email]
enable_signup = true
enable_confirmations = false
[storage]
enabled = true
file_size_limit = "8MiB"
[studio]
enabled = false
[realtime]
enabled = false
[analytics]
enabled = false
[edge_runtime]
enabled = false
`;
}

async function prepare() {
  const project = `ev-merchant-ab-${randomBytes(6).toString('hex')}`;
  const dir = resolve(scratch, project);
  await mkdir(resolve(dir, 'supabase'), { recursive: true });
  await writeFile(resolve(dir, 'supabase/config.toml'), configuration(project), { flag: 'wx' });
  await writeFile(resolve(dir, 'run.json'), JSON.stringify({ kind: 'synthetic-merchant-ab-local-only', project,
    created_at: new Date().toISOString() }, null, 2), { flag: 'wx' });
  console.log(`Prepared local fixture: ${dir}`);
}

async function start(run) {
  await docker(['info', '--format', '{{.ServerVersion}}']);
  // Refuse name collisions rather than adopting other containers/volumes.
  const existing = (await docker(['ps', '-a', '--format', '{{.Names}}'])).split(/\r?\n/);
  assert(!existing.some(n => n.endsWith(`_${run.project}`)), 'Existing stack: inspect/resume explicitly; never reset');
  const volumes = (await docker(['volume', 'ls', '--format', '{{.Name}}'])).split(/\r?\n/);
  assert(!volumes.some(n => n.endsWith(`_${run.project}`)), 'Existing data retained; prepare a fresh run');
  const network = `${run.project}-network`;
  await docker(['network', 'create', '--driver', 'bridge', '--opt', 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1',
    '--label', `esnaftavar.acceptance=${run.project}`, network]);
  await cli(run.dir, ['start', '--network-id', network, '--exclude',
    'realtime,imgproxy,mailpit,postgres-meta,studio,edge-runtime,logflare,vector,supavisor'], 600000);
  await credentials(run);
  console.log('Local stack ready; credentials suppressed. Run acceptance with the same directory.');
}

export async function credentials(run) {
  const state = JSON.parse(await docker(['inspect', `supabase_db_${run.project}`]))[0];
  localContainer(state, run.project);
  const all = JSON.parse(await docker(['inspect', `supabase_kong_${run.project}`]))[0];
  assert.equal(all.Config.Labels['com.supabase.cli.project'], run.project);
  const bindings = all.NetworkSettings.Ports['8000/tcp'];
  assert(bindings?.length && bindings.every(b => b.HostIp === '127.0.0.1' && b.HostPort === String(ports.api)), 'API must bind loopback');
  const status = JSON.parse(await cli(run.dir, ['status', '--output', 'json']));
  localUrl(status.API_URL, 'api'); localUrl(status.DB_URL, 'db');
  assert(status.ANON_KEY && status.SERVICE_ROLE_KEY, 'Local legacy JWT keys required');
  return status;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const action = process.argv[2];
    if (action === 'prepare') await prepare();
    else {
      assert(process.argv[3], 'Provide prepared local run directory');
      const run = await readRun(process.argv[3]);
      if (action === 'start') await start(run);
      else if (action === 'stop') { await cli(run.dir, ['stop']); console.log('Owned local stack stopped; data retained.'); }
      else throw new Error('Use prepare, start or stop');
    }
  } catch { console.error('LOCAL_SETUP_NOT_READY: no remote fallback or reset attempted.'); process.exitCode = 1; }
}
