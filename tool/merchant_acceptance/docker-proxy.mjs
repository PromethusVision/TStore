import assert from 'node:assert/strict';
import { createServer, request } from 'node:http';
import { createConnection } from 'node:net';
import { randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import { ports, projectPattern } from './safety.mjs';

// Docker Desktop may ignore a bridge's default host_binding_ipv4 option.
// This short-lived local socket makes the binding explicit BEFORE creation.
// It never listens on TCP, logs Docker payloads or changes the global daemon.
export function loopbackCreate(url, body, project) {
  assert(projectPattern.test(project));
  const target = new URL(url, 'http://docker.local');
  assert(/^\/v[\d.]+\/containers\/create$/.test(target.pathname));
  const name = target.searchParams.get('name');
  const spec = JSON.parse(body);
  assert.equal(spec.Labels?.['com.supabase.cli.project'], project, 'Foreign project');
  assert.equal(spec.HostConfig?.NetworkMode, `${project}-network`, 'Foreign network');
  assert(!spec.HostConfig.Privileged, 'Privileged container denied');
  assert(!spec.HostConfig.PublishAllPorts, 'Automatic port publishing denied');
  if (!name) {
    // Supabase 17 initializes managed Auth/Storage with labeled, unnamed,
    // one-shot migration jobs. They publish no ports and mount no host files.
    assert(/^public\.ecr\.aws\/supabase\/(gotrue|storage-api):[\w.-]+$/.test(spec.Image), 'Unexpected bootstrap image');
    assert.equal(spec.HostConfig.AutoRemove, true, 'Bootstrap job must be ephemeral');
    assert.equal(Object.keys(spec.HostConfig.PortBindings ?? {}).length, 0, 'Bootstrap ports denied');
    assert.equal((spec.HostConfig.Binds ?? []).length, 0, 'Bootstrap host bind denied');
    assert.equal((spec.HostConfig.Mounts ?? []).length, 0, 'Bootstrap mount denied');
    return Buffer.from(JSON.stringify(spec));
  }
  assert(['db', 'kong', 'auth', 'rest', 'storage'].some(service => name === `supabase_${service}_${project}`), 'Unexpected container');
  const expected = name === `supabase_db_${project}` ? ['5432/tcp', ports.db]
    : name === `supabase_kong_${project}` ? ['8000/tcp', ports.api] : null;
  for (const [port, bindings] of Object.entries(spec.HostConfig.PortBindings ?? {})) {
    assert(expected && port === expected[0], 'Unexpected published port');
    assert(Array.isArray(bindings) && bindings.length > 0);
    for (const binding of bindings) {
      assert.equal(binding.HostPort, String(expected[1]), 'Unexpected host port');
      binding.HostIp = '127.0.0.1';
    }
  }
  return Buffer.from(JSON.stringify(spec));
}

export async function withLoopbackDocker(run, action, backend = process.platform === 'win32'
  ? '//./pipe/dockerDesktopLinuxEngine' : '/var/run/docker.sock') {
  const socket = process.platform === 'win32' ? `//./pipe/ev-merchant-ab-${randomUUID()}`
    : resolve(run.dir, `docker-${randomUUID()}.sock`);
  const endpoint = process.platform === 'win32' ? `npipe:////./pipe/${socket.split('/').at(-1)}` : `unix://${socket}`;
  const peers = new Set();
  const server = createServer(async (incoming, outgoing) => {
    try {
      let body;
      if (incoming.method === 'POST' && /\/containers\/create(?:\?|$)/.test(incoming.url)) {
        const chunks = []; let size = 0;
        for await (const chunk of incoming) {
          size += chunk.length; assert(size < 4e6, 'Docker payload limit'); chunks.push(chunk);
        }
        body = loopbackCreate(incoming.url, Buffer.concat(chunks), run.project);
      }
      const headers = { ...incoming.headers };
      if (body) { delete headers['transfer-encoding']; headers['content-length'] = String(body.length); }
      const upstream = request({ socketPath: backend, path: incoming.url, method: incoming.method, headers }, response => {
        // docker run attaches before starting its container. Deliver headers
        // immediately: buffering until output would deadlock that handshake.
        outgoing.writeHead(response.statusCode, response.headers); outgoing.flushHeaders(); response.pipe(outgoing);
        response.on('error', () => outgoing.destroy());
      });
      upstream.on('error', () => { if (!outgoing.headersSent) outgoing.writeHead(502); outgoing.end(); });
      outgoing.on('close', () => upstream.destroy());
      if (body) upstream.end(body); else incoming.pipe(upstream);
    } catch (error) {
      outgoing.writeHead(403);
      outgoing.end(error.code === 'ERR_ASSERTION' ? 'Local fixture Docker guard rejected: ' + error.message.split('\n')[0]
        : 'Local fixture Docker guard rejected request');
    }
  });
  // Docker exec/attach uses HTTP upgrade during local bootstrap. Forward the
  // byte stream without decoding or persisting credentials/database content.
  server.on('upgrade', (incoming, client, head) => {
    if (!/^\/v[\d.]+\/(?:exec\/[a-f0-9]+\/start|containers\/[^/]+\/attach)(?:\?|$)/.test(incoming.url)) {
      client.end('HTTP/1.1 403 Forbidden\r\nConnection: close\r\nContent-Length: 0\r\n\r\n'); return;
    }
    const remote = createConnection(backend, () => {
      remote.write(`${incoming.method} ${incoming.url} HTTP/${incoming.httpVersion}\r\n`);
      for (let i = 0; i < incoming.rawHeaders.length; i += 2) remote.write(`${incoming.rawHeaders[i]}: ${incoming.rawHeaders[i + 1]}\r\n`);
      remote.write('\r\n'); if (head.length) remote.write(head);
      remote.pipe(client); client.pipe(remote);
    });
    peers.add(remote); remote.on('close', () => peers.delete(remote));
    remote.on('error', () => client.destroy()); client.on('error', () => remote.destroy());
    client.on('close', () => remote.destroy()); remote.on('close', () => client.destroy());
  });
  server.on('connection', peer => { peers.add(peer); peer.on('close', () => peers.delete(peer)); });
  await new Promise((ok, fail) => { server.once('error', fail); server.listen(socket, ok); });
  try { return await action(endpoint); }
  finally { for (const peer of peers) peer.destroy(); await new Promise(ok => server.close(ok)); }
}
