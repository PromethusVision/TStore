import {writeFileSync,lstatSync} from 'node:fs';
import {resolve,posix} from 'node:path';
import {pathToFileURL} from 'node:url';
import {read,hash,check,json,stable,root,directory,sourcePath,rollbackPath,payload} from './common.mjs';
// Explicit roots and runtime data. Imported modules are recursively inventoried;
// evidence globs are deliberately absent. A document is sealed only if consumed.
const roots={
 [`${directory}/cli.mjs`]:'live-entrypoint',
 [`${directory}/seal.mjs`]:'seal-verifier',
 [`${directory}/contract.json`]:'schema-security-contract',
 [sourcePath]:'frozen-bridge-sql',[rollbackPath]:'frozen-bridge-rollback',
 'tool/production_taxonomy/execution/contract.json':'0012-schema-ledger-contract',
 'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql':'immutable-0012-ledger-verification',
 'docs/data/production_20_product_canonical_mapping_validation.json':'runtime-owner-mapping-validation',
 'docs/data/production_20_product_canonical_mapping.csv':'runtime-owner-mapping',
 'docs/TAXONOMY_W36_CATEGORY_IMPORT.csv':'runtime-canonical-identities',
 'docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv':'runtime-qualification',
 'docs/data/w52h_r_source_restore_metadata.json':'runtime-source-metadata',
 [`${directory}/rehearse.mjs`]:'isolated-rehearsal-entrypoint',
 [`${directory}/prepare.mjs`]:'isolated-contract-preparation',
 [`${directory}/failure-tests.mjs`]:'isolated-failure-injection',
 [`${directory}/package.test.mjs`]:'offline-package-tests',
};
export function measure(){
 const files=new Map(Object.entries(roots));
 for(const [path] of files){
  check(!path.startsWith('../')&&!lstatSync(resolve(root,path)).isSymbolicLink(),'BX_SEAL_PATH');
  if(!path.endsWith('.mjs'))continue;
  const text=read(path);
  check(!/\bimport\s*\(/.test(text),'BX_DYNAMIC_IMPORT_FORBIDDEN');
  for(const match of text.matchAll(/(?:\bfrom\s*|\bimport\s*)['"]([^'"]+)['"]/g)){
   const spec=match[1];if(spec.startsWith('node:'))continue;
   check(spec.startsWith('.'),'BX_EXTERNAL_MODULE_FORBIDDEN');
   const target=posix.normalize(posix.join(posix.dirname(path),spec));
   if(!files.has(target))files.set(target,path.includes('/execution/')?'security-executable-dependency':'isolated-rehearsal-dependency');
  }
 }
 return [...files].sort(([a],[b])=>a<b?-1:a>b?1:0).map(([path,role])=>({path,role,size:Buffer.byteLength(read(path),'utf8'),sha256:hash(read(path))}));
}
export function build(){
 payload();payload(true);
 const manifest={format:'w52k-bx-execution-package-v1',authority_main:'afac64f92e3b706a864b36b0e72d27dcf75ef07f',encoding:'UTF-8; CRLF normalized to LF before size and SHA-256',inventory:measure()};
 writeFileSync(resolve(root,directory,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
 return hash(read(`${directory}/manifest.json`));
}
export function verify(expected){
 check(/^[a-f0-9]{64}$/.test(expected??''),'BX_PACKAGE_HASH_REQUIRED');
 check(hash(read(`${directory}/manifest.json`))===expected,'BX_PACKAGE_HASH');
 const manifest=json(`${directory}/manifest.json`);
 check(manifest.format==='w52k-bx-execution-package-v1'&&manifest.authority_main==='afac64f92e3b706a864b36b0e72d27dcf75ef07f','BX_MANIFEST_AUTHORITY');
 check(stable(manifest.inventory)===stable(measure()),'BX_SEALED_INPUT_DRIFT');
 payload();payload(true);
 return {result:'PASS',package_sha256:expected,files:manifest.inventory.length};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 const [command,expected]=process.argv.slice(2);
 check(command==='build'||command==='verify','BX_SEAL_COMMAND');
 console.log(command==='build'?build():JSON.stringify(verify(expected)));
}
