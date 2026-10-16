import assert from 'node:assert/strict';
import { realpath } from 'node:fs/promises';
import { relative, isAbsolute, resolve, sep } from 'node:path';
import { request as httpRequest } from 'node:http';

export const ports = Object.freeze({ api: 55431, db: 55432, shadow: 55430 });
export const projectPattern = /^ev-merchant-ab-[a-f0-9]{12}$/;
export function localUrl(value, kind) {
  const url = new URL(value);
  assert.equal(url.hostname, '127.0.0.1', 'Literal loopback required');
  assert.equal(url.port, String(ports[kind]), 'Dedicated acceptance port required');
  assert.equal(url.protocol, kind === 'db' ? 'postgresql:' : 'http:');
  assert.equal(url.search, ''); assert.equal(url.hash, '');
  assert.equal(url.pathname, kind === 'db' ? '/postgres' : '/');
  if (kind === 'api') { assert.equal(url.username, ''); assert.equal(url.password, ''); }
  else assert.equal(url.username, 'postgres');
  return url;
}
export async function inside(base, path) {
  const canonicalBase = await realpath(base), canonical = await realpath(resolve(path));
  const part = relative(canonicalBase, canonical);
  assert(part && part !== '..' && !part.startsWith(`..${sep}`) && !isAbsolute(part), 'Owned scratch directory required');
  return canonical;
}
export function localContainer(state, project) {
  assert(projectPattern.test(project));
  assert.equal(state.Name, `/supabase_db_${project}`);
  assert.equal(state.Config.Labels['com.supabase.cli.project'], project);
  assert.equal(state.State.Running, true);
  assert.equal(state.HostConfig.Privileged, false);
  const bindings = state.NetworkSettings.Ports['5432/tcp'];
  assert(bindings?.length > 0, 'Dedicated database port required');
  assert(bindings.every(b => b.HostIp === '127.0.0.1' && b.HostPort === String(ports.db)), 'Loopback binding required');
}
export function localEmptyNetwork(state, project) {
  assert(projectPattern.test(project));
  assert.equal(state.Name, project+'-network');
  assert.equal(state.Labels?.['esnaftavar.acceptance'], project);
  assert.equal(state.Driver, 'bridge'); assert.equal(state.Scope, 'local');
  assert.equal(state.Options?.['com.docker.network.bridge.host_binding_ipv4'], '127.0.0.1');
  assert.equal(state.EnableIPv6, false); assert.equal(state.Ingress, false);
  assert(state.Containers && Object.keys(state.Containers).length === 0, 'Network already in use');
}
export async function localRequest(base, path, { method='GET', headers={}, body }={}) {
  const root = localUrl(base, 'api');
  const url = new URL(path, root);
  assert.equal(url.origin, root.origin, 'Cross-origin request denied');
  // node:http uses a literal loopback connection and ignores proxy environment
  // variables. Never follow redirects with local credentials or image bytes.
  return new Promise((ok,fail)=>{
    const request=httpRequest({hostname:'127.0.0.1',port:ports.api,path:url.pathname+url.search,
      method,headers,agent:false,signal:AbortSignal.timeout(15000)},response=>{
      const chunks=[]; let bytes=0;
      response.on('data',chunk=>{ bytes+=chunk.length; if(bytes>9*1024*1024) response.destroy(new Error('Response too large')); else chunks.push(chunk); });
      response.on('error',fail);
      response.on('end',()=>{
        const status=response.statusCode;
        ok({status,ok:status>=200&&status<300,body:Buffer.concat(chunks)});
      });
    });
    request.on('error',fail); request.end(body);
  });
}
export async function requestJson(base, path, token, key, body, method = 'POST') {
  const response = await localRequest(base,path,{method,
    headers:{apikey:key,Authorization:`Bearer ${token || key}`,'Content-Type':'application/json'},
    body:body===undefined?undefined:JSON.stringify(body)});
  const raw = response.body.toString('utf8');
  let data; try { data = raw ? JSON.parse(raw) : null; } catch { data = null; }
  // Callers assert status; raw auth/error payloads never enter logs or evidence.
  return { status: response.status, ok: response.ok, data };
}
