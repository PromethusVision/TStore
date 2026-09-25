// Independent identity. This does not build or alter the existing activation seal.
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {root,hash,stable,json} from '../live/common.mjs';
import {verify} from '../live/seal.mjs';
import {check} from './classifier.mjs';
export const activationSeal='86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a';
export const authority='4368911347eb2755587d02b9d50c25ec2c1653c0';
export function sealedBytes(){
 const verified=verify(activationSeal),files=json('tool/production_public_activation/live/seal.json').inventory;
 check(verified.runtime_inputs===58,'EXACT_58_INPUTS');
 const inventory=[...files.map(f=>f.path),'tool/production_public_activation/live/seal.json'].map(path=>{
  const bytes=readFileSync(resolve(root,path));return {path,bytes:bytes.length,sha256:hash(bytes)};
 });
 return {result:'PASS',activation_seal:activationSeal,runtime_inputs:58,inventory,raw_bytes_sha256:hash(stable(inventory))};
}
export function observerIdentity(){
 const inventory=['classifier.mjs','observe.mjs','public-http.mjs','legacy-http.mjs','handoff.mjs','identity.mjs'].map(name=>{
  const path='tool/production_public_activation/observer/'+name,bytes=readFileSync(resolve(root,path));
  return {path,bytes:bytes.length,sha256:hash(bytes)};
 });
 return {format:'w52lf-supplemental-observer-v1',authority_main:authority,activation_seal:activationSeal,independent_sha256:hash(stable(inventory)),inventory};
}
