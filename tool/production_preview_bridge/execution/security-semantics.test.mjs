import test from 'node:test';
import assert from 'node:assert/strict';
import {normalizeRole,normalizeSecurity,assertPlatform,reviewed,order} from './security-semantics.mjs';
import {stable} from './common.mjs';
const inherited={logging:[{setting:'none',reset_val:'none',source:'configuration file'}],overrides:[]};
test('ACL tuples are order invariant but preserve privileges, grantor and grant options',()=>{
 const rows=reviewed().schemas[0].acl;assert.equal(stable(order(rows)),stable(order([...rows].reverse())));
 for(const key of ['grantee','grantor','privilege_type','is_grantable']){const changed=structuredClone(rows);changed[0][key]=typeof changed[0][key]==='boolean'?!changed[0][key]:'changed';assert.notEqual(stable(order(changed)),stable(order(rows)));}
});
test('role key order and exact Auth timeout units normalize deterministically',()=>{
 const base={rolname:'supabase_auth_admin',rolconfig:['search_path=auth','idle_in_transaction_session_timeout=60000']};
 for(const timeout of ['60000ms','60s','1min'])assert.deepEqual(normalizeRole({...base,rolconfig:['idle_in_transaction_session_timeout='+timeout,'search_path=auth']},inherited),normalizeRole(base,inherited));
 assert.notDeepEqual(normalizeRole({...base,rolconfig:['idle_in_transaction_session_timeout=2min']},inherited),normalizeRole(base,inherited));
});
test('duplicate keys and unknown timeout syntax fail closed',()=>{
 assert.throws(()=>normalizeRole({rolname:'authenticator',rolconfig:['x=1','x=1']},inherited),/DUPLICATE/);
 assert.throws(()=>normalizeRole({rolname:'supabase_auth_admin',rolconfig:['idle_in_transaction_session_timeout=infinity']},inherited),/TIMEOUT/);
});
test('only audited timeout is canonicalized; other role settings remain exact',()=>{
 const r={rolname:'other',rolconfig:['idle_in_transaction_session_timeout=1min','search_path=a, b']};assert.deepEqual(normalizeRole(r,inherited),r);
});
test('three explicit none values equal only proven inherited none',()=>{
 for(const rolname of ['supabase_admin','supabase_auth_admin','supabase_storage_admin'])assert.deepEqual(normalizeRole({rolname,rolconfig:['log_statement=none']},{logging:[],overrides:[]}),normalizeRole({rolname,rolconfig:null},inherited));
 for(const source of ['default','configuration file','command line'])assert.equal(normalizeRole({rolname:'supabase_admin',rolconfig:null},{logging:[{setting:'none',reset_val:'none',source}]}).rolconfig[0],'log_statement=none');
});
test('different effective logging and session-masked inheritance fail closed',()=>{
 for(const source of ['session','client','user','database','database user'])assert.throws(()=>normalizeRole({rolname:'supabase_admin',rolconfig:null},{logging:[{setting:'none',reset_val:'none',source}]}),/NOT_PROVEN/);
 assert.throws(()=>normalizeRole({rolname:'supabase_admin',rolconfig:['log_statement=all']},inherited),/EFFECTIVE_VALUE/);
});
test('database and database-role overrides cannot hide effective read-only/logging drift',()=>{
 for(const key of ['log_statement=all','default_transaction_read_only=off'])assert.throws(()=>normalizeSecurity({}, {},{...inherited,overrides:[{setconfig:[key]}]}),/DATABASE_ROLE_OVERRIDE/);
});
test('six reviewed properties assert exact grants, owners and read-only role',()=>{
 const value=reviewed().semantic_security_before;assert.equal(assertPlatform(value).graphql_grants,'PASS');
 for(const change of [v=>v.schemas.find(s=>s.nspname==='graphql').acl.pop(),v=>v.schemas.find(s=>s.nspname==='graphql_public').acl[0].is_grantable=true,v=>v.extensions.find(e=>e.extname==='pgcrypto').owner='supabase_admin',v=>v.roles.find(r=>r.rolname==='supabase_read_only_user').rolconfig=['default_transaction_read_only=off']]){const changed=structuredClone(value);change(changed);assert.throws(()=>assertPlatform(changed));}
});
