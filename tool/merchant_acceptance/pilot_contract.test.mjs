import test from 'node:test';
import assert from 'node:assert/strict';
import { assertMigrationManifest } from './pilot_contract.mjs';
import { migrate } from './fixture.mjs';

test('base core rejects every downstream activation before any database query', async()=>{
  let queries=0;
  const db={query:async()=>{queries++;throw new Error('must not reach database');}};
  for(const flag of ['reviews','trustCampaigns','ledger','rewards','checkout','statement','promotion','notifications']) {
    await assert.rejects(migrate(db,{coreOnly:true,[flag]:true}),/Base core cannot enable/);
  }
  assert.equal(queries,0);
});

test('manifest rejects additions, omissions, reordered bytes and proposal/migration ambiguity',()=>{
  const expected=[{file:'0001.sql',sha256:'a'},{file:'0016_catalog_listing_media.sql',sha256:'b'}];
  assertMigrationManifest(structuredClone(expected),expected);
  for(const actual of [expected.slice(1),[...expected,{file:'0018.sql',sha256:'c'}],
    [...expected].reverse(),[expected[0],{...expected[1],sha256:'different'}],
    [expected[0],{file:'proposals/0016_engagement_foundation.sql',sha256:'b'}]]) {
    assert.throws(()=>assertMigrationManifest(actual,expected));
  }
});
