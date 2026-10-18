import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {checkTarget,digest,schemaExpression} from './pilot_preparation_contract.mjs';
import {verifyPublicationProof,loadPublication,lf} from './pilot_publication_contract.mjs';
import {observedLineEndings} from './pilot_launch_profile.mjs';

export const installedReceipt='docs/data/merchant_pilot_test_catalog_installation.json';
export const installedReceiptSha='e0521cb54ba2cfe4895ba6ad31b89e151a033061ef11b521f920bfc1a0bfdefc';
export const installedSchemaMd5='d9607df877e9115eb811d984e561b4e7';
export const rehearsedLfSchemaMd5='590f31a8d4e3485d6b23434e17bd9d40';
export const installedSignatures=['_catalog_price_contract_guard_v1()','_catalog_publication_immutable_v1()','_publish_catalog_submission_v1(uuid,uuid,uuid,boolean,text)'];
const root=fileURLToPath(new URL('../../',import.meta.url));

export async function verifiedInstalledProfile(repo=root){
 const text=lf(await readFile(resolve(repo,installedReceipt),'utf8'));
 assert.equal(digest(text),installedReceiptSha,'Pinned J8 observation changed');
 const receipt=JSON.parse(text);checkTarget(receipt.target);assert.equal(receipt.result,'PASS');
 const proof=await verifyPublicationProof(repo),source=await loadPublication(repo);
 assert.equal(receipt.source_sha256_lf,source.sha256_lf);
 assert.equal(receipt.after.schema_md5,installedSchemaMd5);
 assert.equal(proof.installed_schema_md5,rehearsedLfSchemaMd5);
 assert.equal(receipt.newline_observation.only_three_new_functions_lf_schema_md5,rehearsedLfSchemaMd5);
 assert.deepEqual(receipt.newline_observation.functions.map(f=>f.signature),installedSignatures);
 assert(receipt.after.private_helpers.every(f=>!f.definer&&!f.anon&&!f.authenticated&&!f.service_role));
 return {target:receipt.target,receipt_sha256_lf:installedReceiptSha,raw_schema_md5:installedSchemaMd5,
  lf_rehearsal_schema_md5:rehearsedLfSchemaMd5,functions:receipt.newline_observation.functions};
}

export function installedFunctionDefinition(signature,definition,profile){
 assert(installedSignatures.includes(signature),'Only the three observed functions');
 const expected=profile.functions.find(f=>f.signature===signature);assert(expected);
 // Only the body delimiter's content changes line endings. This is a local
 // fixture operation, never a forgiving remote fingerprint comparison.
 const result=observedLineEndings(definition,{lf_md5:expected.lf_md5,md5:expected.definition_md5});
 assert.equal(result.length-result.replaceAll('\r','').length,expected.cr_count);
 return result;
}

export async function mirrorInstalledPublicationProfile(db,repo=root){
 assert.equal(db.connectionParameters.host,'127.0.0.1');assert.equal(Number(db.connectionParameters.port),55432);
 const profile=await verifiedInstalledProfile(repo);
 const schema=async()=>(await db.query(`SELECT (${schemaExpression})::text value`)).rows[0].value;
 assert.equal(digest(await schema(),'md5'),rehearsedLfSchemaMd5,'Exact LF rehearsal required, no replay or arbitrary baseline');
 const rows=(await db.query("SELECT p.oid::regprocedure::text signature,pg_get_functiondef(p.oid) definition FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.oid::regprocedure::text=ANY($1::text[]) ORDER BY signature",[installedSignatures])).rows;
 assert.deepEqual(rows.map(r=>r.signature),installedSignatures);
 const definitions=rows.map(r=>installedFunctionDefinition(r.signature,r.definition,profile));
 await db.query('BEGIN');
 try{
  for(const definition of definitions)await db.query(definition+';');
  assert.equal(digest(await schema(),'md5'),installedSchemaMd5,'Entire raw J8 structure must match');
  await db.query('COMMIT');return profile;
 }catch(error){await db.query('ROLLBACK');throw error;}
}
