import { spawn } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
import { inside, localUrl, localContainer, localEmptyNetwork, ports, projectPattern } from './safety.mjs';
import { withLoopbackDocker } from './docker-proxy.mjs';

export const root = fileURLToPath(new URL('../../', import.meta.url));
export const scratch = resolve(root, '.buildlog/merchant-acceptance');
const shim = fileURLToPath(new URL('node_modules/supabase/dist/supabase.js', import.meta.url));
const engine = process.platform === 'win32' ? 'npipe:////./pipe/dockerDesktopLinuxEngine' : 'unix:///var/run/docker.sock';
const env = { ...process.env, DOCKER_HOST: engine, SUPABASE_TELEMETRY_DISABLED: '1', DO_NOT_TRACK: '1' };
// No externally selected Docker context or hosted-project credential is inherited.
for (const key of ['DOCKER_CONTEXT', 'DOCKER_TLS_VERIFY', 'DOCKER_CERT_PATH', 'SUPABASE_ACCESS_TOKEN', 'SUPABASE_DB_PASSWORD']) delete env[key];

export function command(executable, args, cwd = root, timeout = 60000, detachOutput = false, overrides = {}) {
  return new Promise((ok, fail) => {
    const child = spawn(executable, args, { cwd, env: { ...env, ...overrides }, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
    const chunks = [], diagnostics = []; let size = 0, diagnosticSize = 0;
    const timer = setTimeout(() => child.kill(), timeout);
    child.stdout.on('data', b => { size += b.length; if (size < 4e6) chunks.push(b); });
    // CLI output may contain local signing keys. Never forward it to terminal.
    child.stderr.on('data', b => { diagnosticSize += b.length; if (diagnosticSize < 4e6) diagnostics.push(b); });
    child.once('error', () => { clearTimeout(timer); fail(new Error('LOCAL_TOOL_UNAVAILABLE')); });
    child.once(detachOutput ? 'exit' : 'close', code => {
      clearTimeout(timer);
      if (detachOutput) { child.stdout.destroy(); child.stderr.destroy(); }
      if (code !== 0) { const error = new Error('LOCAL_COMMAND_FAILED'); error.diagnostics = Buffer.concat([...diagnostics, ...chunks]).toString(); fail(error); }
      else ok(Buffer.concat(chunks).toString());
    });
  });
}
export const docker = args => command('docker', ['--host', engine, ...args]);
export const cli = (dir, args, timeout, overrides) => command(process.execPath, [shim, ...args, '--workdir', dir], dir, timeout, false, overrides);

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
  const networks = (await docker(['network','ls','--format','{{.Name}}'])).split(/\r?\n/);
  if (!networks.includes(network)) {
    await docker(['network', 'create', '--driver', 'bridge', '--opt', 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1',
      '--label', `esnaftavar.acceptance=${run.project}`, network]);
  }
  // Allows an explicitly prepared, owned empty network when default address
  // pools are exhausted. Never prune another task's network or resume its data.
  localEmptyNetwork(JSON.parse(await docker(['network','inspect',network]))[0],run.project);
  try {
    await withLoopbackDocker(run, endpoint => cli(run.dir, ['start', '--network-id', network, '--exclude',
      'realtime,imgproxy,mailpit,postgres-meta,studio,edge-runtime,logflare,vector,supavisor'], 600000, { DOCKER_HOST: endpoint }));
    await credentials(run);
  } catch (error) {
    // Ignored task scratch only; diagnostics can contain local service secrets.
    await writeFile(resolve(run.dir, 'setup-failure.txt'), error.diagnostics || error.stack, { mode: 0o600 });
    // Preserve this fixture's data, but don't leave a failed stack listening.
    await cli(run.dir, ['stop']).catch(() => {});
    throw error;
  }
  console.log('Local stack ready; credentials suppressed. Run acceptance with the same directory.');
}

export async function credentials(run) {
  const state = JSON.parse(await docker(['inspect', `supabase_db_${run.project}`]))[0];
  localContainer(state, run.project);
  const all = JSON.parse(await docker(['inspect', `supabase_kong_${run.project}`]))[0];
  assert.equal(all.Name, `/supabase_kong_${run.project}`);
  assert.equal(all.Config.Labels['com.supabase.cli.project'], run.project);
  assert.equal(all.State.Running, true); assert.equal(all.HostConfig.Privileged, false);
  const bindings = all.NetworkSettings.Ports['8000/tcp'];
  assert(bindings?.length && bindings.every(b => b.HostIp === '127.0.0.1' && b.HostPort === String(ports.api)), 'API must bind loopback');
  const status = JSON.parse(await cli(run.dir, ['status', '--output', 'json']));
  localUrl(status.API_URL, 'api'); localUrl(status.DB_URL, 'db');
  assert(status.ANON_KEY && status.SERVICE_ROLE_KEY, 'Local legacy JWT keys required');
  return status;
}

export async function runtimeEvidence(run) {
  const services = ['db', 'kong', 'auth', 'rest', 'storage'];
  const states = JSON.parse(await docker(['inspect', ...services.map(service => `supabase_${service}_${run.project}`)]));
  return states.map((state, i) => {
    assert.equal(state.Name, `/supabase_${services[i]}_${run.project}`);
    assert.equal(state.Config.Labels['com.supabase.cli.project'], run.project);
    assert.equal(state.State.Running, true); assert.equal(state.HostConfig.Privileged, false);
    const bindings = Object.entries(state.NetworkSettings.Ports).flatMap(([port, entries]) =>
      (entries ?? []).map(entry => ({ container_port: port, host_ip: entry.HostIp, host_port: entry.HostPort })));
    for (const binding of bindings) {
      assert.equal(binding.host_ip, '127.0.0.1');
      assert.equal(binding.host_port, String(services[i] === 'db' ? ports.db : ports.api));
      assert(['db', 'kong'].includes(services[i]), 'Unexpected published service');
    }
    return { service: services[i], image: state.Config.Image, image_id: state.Image, bindings };
  });
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
