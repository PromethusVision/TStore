import {writeFileSync,lstatSync} from 'node:fs';
import {resolve,posix} from 'node:path';
import {pathToFileURL} from 'node:url';
import {check,read,json,hash,stable,root,directory,authority} from './common.mjs';
const seeds=['executor.mjs','seal.mjs','activate.sql','rollback.sql','runtime-manifest.json','state-oracle.json'].map(p=>`${directory}/${p}`);
const data=[
 'tool/production_taxonomy/execution/contract.json','tool/production_preview_bridge/execution/contract.json','tool/production_preview_bridge/execution/security-baseline.json',
 'docs/data/production_20_product_canonical_mapping_validation.json','docs/data/production_20_product_canonical_mapping.csv','docs/TAXONOMY_W36_CATEGORY_IMPORT.csv','docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv',
 'docs/data/w52h_r_source_restore_metadata.json',
 'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql','supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql','tool/production_preview_bridge/rollback.sql',
];
export function measure(){
 const files=new Set([...seeds,...data]);
 for(const path of files){
  check(!path.startsWith('../')&&!lstatSync(resolve(root,path)).isSymbolicLink(),'SEALED_PATH');
  if(!path.endsWith('.mjs'))continue;
  const source=read(path);check(!/\bimport\s*\(/.test(source),'NO_DYNAMIC_RUNTIME_IMPORT');
  for(const match of source.matchAll(/(?:\bfrom\s*|\bimport\s*)['"]([^'"]+)['"]/g)){
   const target=match[1];if(target.startsWith('node:'))continue;
   check(target.startsWith('.'),'NO_EXTERNAL_RUNTIME_MODULE');
   files.add(posix.normalize(posix.join(posix.dirname(path),target)));
  }
 }
 return [...files].sort().map(path=>({path,size:Buffer.byteLength(read(path)),sha256:hash(read(path))}));
}
export function verify(expected){
 check(/^[a-f0-9]{64}$/.test(expected??''),'EXTERNAL_SEAL_REQUIRED');
 check(hash(read(`${directory}/seal.json`))===expected,'SEAL_HASH');
 const seal=json(`${directory}/seal.json`);
 check(seal.authority_main===authority&&seal.format==='w52l-a-runtime-seal-v1','SEAL_AUTHORITY');
 check(stable(seal.inventory)===stable(measure()),'SEALED_INPUT_DRIFT');
 return {result:'PASS',sha256:expected,files:seal.inventory.length};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 const [operation,expected]=process.argv.slice(2);check(['build','verify'].includes(operation),'SEAL_OPERATION');
 if(operation==='build'){
  writeFileSync(resolve(root,directory,'seal.json'),JSON.stringify({format:'w52l-a-runtime-seal-v1',authority_main:authority,encoding:'UTF-8; CRLF normalized to LF',inventory:measure()},null,2)+'\n');
  console.log(hash(read(`${directory}/seal.json`)));
 }else console.log(JSON.stringify(verify(expected)));
}
