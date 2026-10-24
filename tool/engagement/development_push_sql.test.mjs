import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {developmentPushSql} from './development_push_sql.mjs';
test('reviewed Development SQL exactly matches existing transport and independent session guard',async()=>{
  const sql=await developmentPushSql();
  const checkedIn=(await readFile(new URL('../../supabase/proposals/development_push_transport_v1.sql',import.meta.url),'utf8')).replaceAll('\r\n','\n');
  assert.equal(checkedIn,sql);
  assert.equal(sql.includes('_qr_auth_session_b'),false);
  assert.equal(sql.includes('ALTER TABLE public.banners'),false);
  assert.equal(sql.includes('CREATE TABLE public.verified'),false);
  assert.match(sql,/enabled boolean NOT NULL DEFAULT false/);
  assert.match(sql,/FROM PUBLIC,anon,authenticated,service_role/);
  assert.match(sql,/AND s.user_id=auth.uid\(\)/);
});
