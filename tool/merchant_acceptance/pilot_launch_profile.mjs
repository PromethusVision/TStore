import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {digest,schemaExpression} from './pilot_preparation_contract.mjs';
import {installedSchemaMd5,lf} from './pilot_launch_contract.mjs';
export const postProfileSha='7aa7e8448787987f0ee22511da41b12e055fdc326516d03e5ef91332b058e5a3';

export function observedLineEndings(localDefinition,expected) {
  assert.equal(digest(lf(localDefinition),'md5'),expected.lf_md5,'Unknown executable change; newline-only mirror required');
  const parts=localDefinition.split('$function$');assert.equal(parts.length,3);
  const observed=parts[0]+'$function$'+lf(parts[1]).replaceAll('\n','\r\n')+'$function$'+parts[2];
  assert.equal(digest(observed,'md5'),expected.md5,'Only observed CRLF body storage may be mirrored');
  return observed;
}

// LOCAL fixture only: no hosted function changes and no hash substitution.
// The actual post-A hosted definitions differ from the LF local source only in
// CRLF bodies introduced by SQL editor paste. Reproduce all 22 exactly locally.
export async function mirrorPostAProfile(db) {
  assert.equal(db.connectionParameters.host,'127.0.0.1');assert.equal(Number(db.connectionParameters.port),55432);
  const text=lf(await readFile(fileURLToPath(new URL('../../docs/data/merchant_pilot_post_a_observation.json',import.meta.url)),'utf8'));
  assert.equal(digest(text),postProfileSha);const profile=JSON.parse(text);
  assert.equal(profile.schema_md5,installedSchemaMd5);assert.equal(profile.functions.length,72);
  const before=(await db.query(`SELECT (${schemaExpression})::text value`)).rows[0].value;
  const schema=JSON.parse(before),expectedFunctions=new Map(profile.functions.map(f=>[f.signature,f]));
  const raw=(await db.query("SELECT p.oid::regprocedure::text signature,pg_get_functiondef(p.oid) definition FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend d WHERE d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e')")).rows;
  const definitions=new Map(raw.map(r=>[r.signature,r.definition])),updates=[];
  assert.equal(schema.functions.length,72);
  for(const fn of schema.functions){
    const expected=expectedFunctions.get(fn.signature);assert(expected);
    assert.deepEqual({...fn,definition_md5:expected.definition_md5},expected,'Function permissions/settings changed');
    if(fn.definition_md5===expected.definition_md5)continue;
    const normalized=profile.normalized_functions.find(f=>f.signature===fn.signature);assert(normalized);
    const definition=observedLineEndings(definitions.get(fn.signature),normalized);
    assert.equal(digest(definition,'md5'),expected.definition_md5);updates.push(definition);
  }
  assert.equal(updates.length,22,'Expected only the 22 post-A function body newline differences');
  await db.query('BEGIN');try{
    for(const definition of updates)await db.query(definition+';');
    const actual=(await db.query(`SELECT (${schemaExpression})::text value`)).rows[0].value;
    assert.equal(digest(actual,'md5'),installedSchemaMd5,'Whole post-A projection must match exactly');
    assert.deepEqual(JSON.parse(actual).functions,profile.functions);
    await db.query('COMMIT');return {sha256_lf:postProfileSha,schema_md5:installedSchemaMd5,newline_only_functions:updates.length};
  }catch(error){await db.query('ROLLBACK');throw error;}
}
