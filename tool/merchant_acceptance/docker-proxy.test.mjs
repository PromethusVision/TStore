import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer, request } from 'node:http';
import { randomUUID } from 'node:crypto';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { loopbackCreate, withLoopbackDocker } from './docker-proxy.mjs';

const project = 'ev-merchant-ab-0123456789ab';
const path = `/v1.53/containers/create?name=supabase_db_${project}`;
const spec = () => ({ Labels: { 'com.supabase.cli.project': project },
  HostConfig: { NetworkMode: `${project}-network`, Privileged: false,
    PortBindings: { '5432/tcp': [{ HostIp: '', HostPort: '55432' }] } } });

test('explicit loopback binding precedes creation and rejects foreign or unexpected resources', () => {
  assert.equal(JSON.parse(loopbackCreate(path, JSON.stringify(spec()), project)).HostConfig.PortBindings['5432/tcp'][0].HostIp, '127.0.0.1');
  for (const change of [s => s.Labels = {}, s => s.HostConfig.NetworkMode = 'host',
    s => s.HostConfig.Privileged = true, s => s.HostConfig.PortBindings['5432/tcp'][0].HostPort = '5432',
    s => s.HostConfig.PortBindings['9999/tcp'] = [{ HostPort: '55432' }]]) {
    const invalid = spec(); change(invalid); assert.throws(() => loopbackCreate(path, JSON.stringify(invalid), project));
  }
  assert.throws(() => loopbackCreate(path.replace(`supabase_db_${project}`, 'unrelated-db'), JSON.stringify(spec()), project));
  const job = spec(); job.Image = 'public.ecr.aws/supabase/gotrue:v2.197.0';
  job.HostConfig.AutoRemove = true; job.HostConfig.PortBindings = {};
  const jobPath = '/v1.53/containers/create';
  assert.equal(JSON.parse(loopbackCreate(jobPath, JSON.stringify(job), project)).Image, job.Image);
  for (const change of [s => s.HostConfig.PublishAllPorts = true, s => s.HostConfig.Binds = ['/host:/data'],
    s => s.HostConfig.PortBindings = spec().HostConfig.PortBindings, s => s.Image = 'unrelated-image']) {
    const invalid = structuredClone(job); change(invalid); assert.throws(() => loopbackCreate(jobPath, JSON.stringify(invalid), project));
  }
});

test('actual local socket proxy forwards rewritten JSON, rejects foreign creates and preserves exec streams', async () => {
  const socket = process.platform === 'win32' ? `//./pipe/ev-proxy-test-${randomUUID()}` : join(tmpdir(), `ev-proxy-${randomUUID()}.sock`);
  let creates = 0, attached;
  const backend = createServer(async (req, res) => {
    if (req.url === '/v1.53/containers/fixture/attach') {
      attached = res; res.writeHead(200); res.flushHeaders(); return;
    }
    const chunks = []; for await (const chunk of req) chunks.push(chunk);
    const body = JSON.parse(Buffer.concat(chunks));
    assert.equal(body.HostConfig.PortBindings['5432/tcp'][0].HostIp, '127.0.0.1'); creates++;
    res.writeHead(201, { 'Content-Type': 'application/json' }); res.end('{"Id":"fixture"}');
  });
  backend.on('upgrade', (req, peer, head) => {
    assert.equal(req.url, '/v1.53/exec/abcd/start');
    peer.write('HTTP/1.1 101 Switching Protocols\r\nConnection: Upgrade\r\nUpgrade: tcp\r\n\r\n');
    if (head.length) peer.write(head); peer.pipe(peer);
  });
  await new Promise((ok, fail) => { backend.once('error', fail); backend.listen(socket, ok); });
  try {
    await withLoopbackDocker({ project, dir: tmpdir() }, async endpoint => {
      const socketPath = endpoint.startsWith('npipe:') ? endpoint.slice('npipe://'.length) : endpoint.slice('unix://'.length);
      const send = body => new Promise((ok, fail) => {
        const req = request({ socketPath, path, method: 'POST', headers: { 'Content-Type': 'application/json' } }, res => {
          res.resume(); res.on('end', () => ok(res.statusCode));
        }); req.on('error', fail); req.end(JSON.stringify(body));
      });
      assert.equal(await send(spec()), 201);
      const foreign = spec(); foreign.Labels = {}; assert.equal(await send(foreign), 403); assert.equal(creates, 1);
      await new Promise((ok, fail) => {
        const req = request({ socketPath, path: '/v1.53/containers/fixture/attach', method: 'POST',
          signal: AbortSignal.timeout(2000) }, res => {
          // docker run starts only after attach's headers, before any output.
          attached.end('started'); const chunks = [];
          res.on('data', chunk => chunks.push(chunk));
          res.on('end', () => { assert.equal(Buffer.concat(chunks).toString(), 'started'); ok(); });
        }); req.on('error', fail); req.end();
      });
      await new Promise((ok, fail) => {
        const req = request({ socketPath, path: '/v1.53/exec/abcd/start', method: 'POST',
          headers: { Connection: 'Upgrade', Upgrade: 'tcp', 'Content-Length': '4' } });
        req.on('error', fail); req.on('upgrade', (res, peer, head) => {
          const chunks = [head];
          const done = () => { if (Buffer.concat(chunks).length >= 4) {
            assert.equal(Buffer.concat(chunks).toString(), 'body'); peer.destroy(); ok();
          } };
          peer.on('data', chunk => { chunks.push(chunk); done(); }); peer.on('error', fail); done();
        }); req.end('body');
      });
    }, socket);
  } finally { await new Promise(ok => backend.close(ok)); }
});
