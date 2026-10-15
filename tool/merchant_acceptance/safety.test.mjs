import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { localUrl, localContainer, localRequest, requestJson } from './safety.mjs';

test('rejects remote, alternate ports, query overrides and misleading loopback URLs', () => {
  for (const value of ['https://example.supabase.co', 'http://127.0.0.1:54321',
    'http://127.0.0.1.example.com:55431', 'http://localhost:55431',
    'http://127.0.0.1:55431/?host=remote', 'http://user@127.0.0.1:55431',
    'http://127.0.0.1:55431/remote']) assert.throws(() => localUrl(value, 'api'));
  assert.equal(localUrl('http://127.0.0.1:55431', 'api').hostname, '127.0.0.1');
  assert.throws(() => localUrl('postgresql://postgres:x@127.0.0.1:55432/postgres?host=example.com', 'db'));
  assert.equal(localUrl('postgresql://postgres:x@127.0.0.1:55432/postgres', 'db').port, '55432');
});

test('HTTP transport stays on literal loopback and never follows redirects', async () => {
  let hits=0;
  const server=createServer((req,res)=>{
    hits++;
    if(req.url==='/redirect') { res.writeHead(302,{Location:'https://example.invalid/credential-target'}); res.end(); return; }
    assert.equal(req.headers.authorization,'Bearer fixture-token');
    const chunks=[]; req.on('data',b=>chunks.push(b)); req.on('end',()=>{
      res.writeHead(200,{'Content-Type':'application/json'}); res.end(JSON.stringify({received:JSON.parse(Buffer.concat(chunks))}));
    });
  });
  await new Promise((ok,fail)=>{server.once('error',fail);server.listen(55431,'127.0.0.1',ok);});
  try {
    const redirect=await localRequest('http://127.0.0.1:55431','/redirect');
    assert.equal(redirect.status,302); assert.equal(redirect.ok,false); assert.equal(hits,1);
    await assert.rejects(localRequest('http://127.0.0.1:55431','https://example.invalid/'));
    assert.equal(hits,1);
    const json=await requestJson('http://127.0.0.1:55431','/echo','fixture-token','fixture-key',{quantity:3});
    assert.deepEqual(json.data,{received:{quantity:3}}); assert.equal(hits,2);
  } finally { await new Promise(ok=>server.close(ok)); }
});

test('rejects unrelated, stopped, privileged or externally published containers', () => {
  const project = 'ev-merchant-ab-0123456789ab';
  const state = { Name: `/supabase_db_${project}`, Config: { Labels: { 'com.supabase.cli.project': project } },
    State: { Running: true }, HostConfig: { Privileged: false },
    NetworkSettings: { Ports: { '5432/tcp': [{ HostIp: '127.0.0.1', HostPort: '55432' }] } } };
  localContainer(state, project);
  for (const change of [s => s.State.Running = false, s => s.HostConfig.Privileged = true,
    s => s.Name = '/existing-user-db', s => s.Config.Labels = {},
    s => s.NetworkSettings.Ports['5432/tcp'][0].HostIp = '0.0.0.0']) {
    const invalid = structuredClone(state); change(invalid); assert.throws(() => localContainer(invalid, project));
  }
});
