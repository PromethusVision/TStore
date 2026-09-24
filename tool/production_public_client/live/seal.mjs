import {writeFileSync,lstatSync} from 'node:fs';
import {resolve,posix} from 'node:path';
import {pathToFileURL} from 'node:url';
import {read,json,hash,stable,root,directory,authority,check,payload,previousSeal,migration,rollbackPath} from './common.mjs';
import {verify as verifyPrevious} from '../seal.mjs';
export function measure(){
 const paths=new Set([
  ...['cli.mjs','seal.mjs','runtime-manifest.json'].map(f=>directory+'/'+f),migration,rollbackPath,
  'tool/production_public_client/function-oracle.json','tool/production_public_client/seal.json','tool/production_public_activation/seal.json',
  ...json('tool/production_public_activation/seal.json').inventory.map(f=>f.path),
  ...json('tool/production_public_client/seal.json').manifest.inputs.map(f=>f.path),
 ]);
 for(const path of paths){
  check(!path.startsWith('../')&&!lstatSync(resolve(root,path)).isSymbolicLink(),'SEALED_PATH');
  if(!path.endsWith('.mjs'))continue;const text=read(path);check(!/\bimport\s*\(/.test(text),'DYNAMIC_RUNTIME_IMPORT_FORBIDDEN');
  for(const m of text.matchAll(/(?:\bfrom\s*|\bimport\s*)['"]([^'"]+)['"]/g)){
   if(m[1].startsWith('node:'))continue;check(m[1].startsWith('.'),'EXTERNAL_RUNTIME_MODULE');paths.add(posix.normalize(posix.join(posix.dirname(path),m[1])));
  }
 }
 return [...paths].sort().map(path=>({path,size:Buffer.byteLength(read(path)),sha256:hash(read(path))}));
}
export function verify(expected){
 check(/^[a-f0-9]{64}$/.test(expected??''),'EXTERNAL_SEAL_REQUIRED');check(hash(read(directory+'/seal.json'))===expected,'PACKAGE_HASH');
 verifyPrevious(previousSeal);payload();
 const seal=json(directory+'/seal.json');check(seal.format==='w52lc-0015-runtime-seal-v1'&&seal.authority_main===authority,'SEAL_AUTHORITY');
 check(stable(seal.inventory)===stable(measure()),'RUNTIME_INPUT_DRIFT');return {result:'PASS',sha256:expected,runtime_inputs:seal.inventory.length};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 const [op,expected]=process.argv.slice(2);check(['build','verify'].includes(op),'SEAL_OPERATION');
 if(op==='build'){verifyPrevious(previousSeal);payload();writeFileSync(resolve(root,directory,'seal.json'),JSON.stringify({format:'w52lc-0015-runtime-seal-v1',authority_main:authority,encoding:'UTF-8; CRLF normalized to LF',inventory:measure()},null,2)+'\n');console.log(hash(read(directory+'/seal.json')));}
 else console.log(JSON.stringify(verify(expected)));
}
