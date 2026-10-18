import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {root} from './local.mjs';
import {assertOwnedAuth,callbacks} from './auth_mail_local.mjs';
import {templateContract} from './auth_mail_contract.mjs';

const project='ev-merchant-ab-123456abcdef';
const state=()=>({Name:`/supabase_auth_${project}`,Config:{Image:'public.ecr.aws/supabase/gotrue:v2.197.0',Labels:{'com.supabase.cli.project':project}},HostConfig:{Privileged:false,NetworkMode:`${project}-network`,PortBindings:{}},Mounts:[],NetworkSettings:{Networks:{[`${project}-network`]:{}}}});
test('only exact disposable owned Auth may be reconfigured',()=>assertOwnedAuth(state(),project));
for(const [name,change]of [
 ['foreign identity',s=>s.Name='/supabase_auth_foreign'],
 ['foreign label',s=>s.Config.Labels['com.supabase.cli.project']='foreign'],
 ['unexpected Auth image',s=>s.Config.Image='supabase/gotrue:latest'],
 ['privileged',s=>s.HostConfig.Privileged=true],
 ['host networking',s=>s.HostConfig.NetworkMode='host'],
 ['host filesystem mount',s=>s.Mounts.push({Source:'C:/'})],
 ['published Auth',s=>s.HostConfig.PortBindings['9999/tcp']=[{HostIp:'0.0.0.0',HostPort:'9999'}]],
 ['second network',s=>s.NetworkSettings.Networks.other={}],
])test('reject '+name,()=>{const s=state();change(s);assert.throws(()=>assertOwnedAuth(s,project));});
test('callback allowlist is the four reviewed Development roots only',()=>{
 assert.equal(callbacks.length,4);assert.equal(new Set(callbacks).size,4);
 for(const value of callbacks){const u=new URL(value);assert(['com.esnaftavar.app.merchant.pilot:','io.supabase.tstore:'].includes(u.protocol));assert.equal(u.hostname,'login-callback');assert.equal(u.pathname,'/');assert.equal(u.hash,'');assert.equal(u.port,'');assert(!value.includes('*'));}
});
for(const flow of ['confirmation','recovery'])test(flow+' template retains shared provider PKCE URL',async()=>{
 const html=await readFile(resolve(root,`supabase/templates/pilot/${flow}.html`),'utf8');templateContract(html);
 for(const changed of [html.replace('.ConfirmationURL','.TokenHash'),html.replace('.ConfirmationURL','.SiteURL'),html+'<img src="https://tracker.invalid/pixel">',html+'<script>alert(1)</script>',html.replace('href="{{ .ConfirmationURL }}"','href="com.esnaftavar.app.merchant.pilot://login-callback/"'),html+'{{ .Email }}'])assert.throws(()=>templateContract(changed));
});
