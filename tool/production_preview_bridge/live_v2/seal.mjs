import {writeFileSync,lstatSync} from 'node:fs';
import {resolve,posix} from 'node:path';
import {pathToFileURL} from 'node:url';
import {read,hash,json,stable,root,directory,authority,check,payload,sourcePath,rollbackPath} from './common.mjs';
const inputs={
 [`${directory}/cli.mjs`]:'live-entrypoint', [`${directory}/seal.mjs`]:'seal-verifier',
 [`${directory}/runtime-manifest.json`]:'runtime-operations-and-ownership',
 [sourcePath]:'immutable-0013-bridge', [rollbackPath]:'reviewed-teardown-signatures',
 'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql':'immutable-0012-ledger-reference',
 'tool/production_taxonomy/execution/contract.json':'0012-contract',
 'tool/production_preview_bridge/execution/contract.json':'bridge-schema-contract',
 'docs/data/production_20_product_canonical_mapping_validation.json':'runtime-mapping-validation',
 'docs/data/production_20_product_canonical_mapping.csv':'runtime-owner-mapping',
 'docs/TAXONOMY_W36_CATEGORY_IMPORT.csv':'runtime-taxonomy-identities',
 'docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv':'runtime-qualification',
 'docs/data/w52h_r_source_restore_metadata.json':'runtime-source-metadata',
};
export function measure(){
 const files=new Map(Object.entries(inputs));
 for(const [path]of files){
  check(!path.startsWith('../')&&!lstatSync(resolve(root,path)).isSymbolicLink(),'SEALED_PATH');
  if(!path.endsWith('.mjs'))continue;const source=read(path);
  check(!/\bimport\s*\(/.test(source),'DYNAMIC_IMPORT_FORBIDDEN');
  for(const match of source.matchAll(/(?:\bfrom\s*|\bimport\s*)['"]([^'"]+)['"]/g)){
   const target=match[1];if(target.startsWith('node:'))continue;check(target.startsWith('.'),'EXTERNAL_MODULE_FORBIDDEN');
   const resolved=posix.normalize(posix.join(posix.dirname(path),target));if(!files.has(resolved))files.set(resolved,'runtime-security-dependency');
  }
 }
 return [...files].sort(([a],[b])=>a<b?-1:a>b?1:0).map(([path,role])=>({path,role,size:Buffer.byteLength(read(path)),sha256:hash(read(path))}));
}
export function verify(expected){
 check(/^[a-f0-9]{64}$/.test(expected??''),'EXTERNAL_SEAL_HASH_REQUIRED');
 check(hash(read(`${directory}/seal.json`))===expected,'PACKAGE_HASH');
 const manifest=json(`${directory}/seal.json`);check(manifest.authority_main===authority&&manifest.format==='w52k-by-runtime-seal-v1','SEAL_AUTHORITY');
 check(stable(manifest.inventory)===stable(measure()),'RUNTIME_INPUT_DRIFT');payload();payload(true);
 return {result:'PASS',sha256:expected,files:manifest.inventory.length};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 const [operation,expected]=process.argv.slice(2);check(['build','verify'].includes(operation),'SEAL_OPERATION');
 if(operation==='build'){payload();payload(true);writeFileSync(resolve(root,directory,'seal.json'),JSON.stringify({format:'w52k-by-runtime-seal-v1',authority_main:authority,encoding:'UTF-8, CRLF normalized to LF',inventory:measure()},null,2)+'\n');console.log(hash(read(`${directory}/seal.json`)));}
 else console.log(JSON.stringify(verify(expected)));
}
