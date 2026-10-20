// Offline review only. Preserves existing intake/SQL/role/category contracts.
import assert from 'node:assert/strict';
import {mkdir,realpath,writeFile} from 'node:fs/promises';
import {dirname,resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {installedKinds,installedTemplate,installedReviewFiles} from './pilot_installed_contract.mjs';
import {readInstalledIntake} from './prepare_installed_pilot.mjs';
import {digest} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {verifyCurrentReadiness} from './pilot_current_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const slug=/^[a-z][a-z0-9-]{2,60}$/;
const json=x=>JSON.stringify(x,null,2)+'\n';

export async function prepareCurrentPilot(repo,kind,name,input=installedTemplate(kind),observation=null,taxonomy=null){
  assert(installedKinds.includes(kind)&&slug.test(name),'Exact mode and plain unused output name required');
  const evidence=await verifyCurrentReadiness(repo);
  const {files,report}=installedReviewFiles(evidence.target,kind,input,observation,taxonomy);
  const manifest={kind:'merchant-pilot-current-review-bundle-v1',target:evidence.target,mode:kind,
    remote_authorized:false,proofs:evidence.proofs,renewed_sources:evidence.renewed,
    contains_private_ids:kind==='cohort'?input.accounts.some(a=>a.user_id!==null):input.items.length>0,
    files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};
  files['bundle.json']=json(manifest);
  const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');
  await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch,'No output reparse path');
  const parent=resolve(scratch,'pilot-current-review');await mkdir(parent,{recursive:true});
  assert.equal(await realpath(parent),parent,'No output reparse path');
  const directory=resolve(parent,name);assert.equal(dirname(directory),parent);await mkdir(directory);
  for(const [path,content] of Object.entries(files))await writeFile(resolve(directory,path),content,{flag:'wx',mode:0o600});
  return {directory,manifest,report};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  try{
    assert(process.argv.length===4||process.argv.length===5,'Mode, new output name and optional private intake name only');
    const [kind,name,intake]=process.argv.slice(2);assert(installedKinds.includes(kind));
    const args=intake?await readInstalledIntake(root,kind,intake):{input:installedTemplate(kind),observation:null,taxonomy:null};
    const result=await prepareCurrentPilot(root,kind,name,args.input,args.observation,args.taxonomy);
    console.log('CURRENT_PILOT_REVIEW_READY: '+result.directory+'; local files only, no remote action.');
  }catch{
    console.error('CURRENT_PILOT_REVIEW_REFUSED: fresh matching UI/repository evidence and unchanged historical contracts required; no remote action.');
    process.exitCode=1;
  }
}
