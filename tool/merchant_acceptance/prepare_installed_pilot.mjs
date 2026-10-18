import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {installedKinds,installedTemplate,installedReviewFiles,verifyInstalledReadinessProof} from './pilot_installed_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const slugPattern=/^[a-z][a-z0-9-]{2,60}$/;
const json=x=>JSON.stringify(x,null,2)+'\n';

export async function readInstalledIntake(repo,kind,slug){
 assert(installedKinds.includes(kind)&&slugPattern.test(slug),'Plain intake name and exact mode required');
 const canonical=await realpath(repo),directory=resolve(canonical,'.buildlog/pilot-installed-input',kind);
 async function read(suffix){const path=resolve(directory,slug+suffix);assert.equal(await realpath(path),path,'No input symlink/reparse escape');return readFile(path,'utf8');}
 const input=JSON.parse(await read('.json'));
 const observation=JSON.parse(await read('.observation.json'));
 const taxonomy=kind==='cohort'?await read('.taxonomy.json'):null;
 return {input,observation,taxonomy};
}

export async function prepareInstalledPilot(repo,kind,slug,input=installedTemplate(kind),observation=null,taxonomy=null){
 assert(installedKinds.includes(kind)&&slugPattern.test(slug),'Exact mode and new plain output name required');
 const {profile}=await verifyInstalledReadinessProof(repo);
 const {files,report}=installedReviewFiles(profile.target,kind,input,observation,taxonomy);
 const manifest={kind:'merchant-pilot-installed-review-bundle-v1',target:profile.target,mode:kind,remote_authorized:false,
  installed_profile:report.installed_profile,contains_private_ids:kind==='cohort'?input.accounts.some(a=>a.user_id!==null):input.items.length>0,
  files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};
 files['bundle.json']=json(manifest);
 const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
 const parent=resolve(scratch,'pilot-installed-review');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
 const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);await mkdir(directory);
 for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx',mode:0o600});
 return {directory,manifest,report};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{
  assert(process.argv.length===4||process.argv.length===5,'Mode, new output name and optional private intake name only');
  const [, ,kind,slug,intake]=process.argv;assert(installedKinds.includes(kind));
  const args=intake?await readInstalledIntake(root,kind,intake):{input:installedTemplate(kind),observation:null,taxonomy:null};
  const result=await prepareInstalledPilot(root,kind,slug,args.input,args.observation,args.taxonomy);
  console.log('INSTALLED_PILOT_REVIEW_READY: '+result.directory+'; no remote action.');
 }catch{console.error('INSTALLED_PILOT_REVIEW_REFUSED: check local proof, exact input/state and unused output name; no remote action.');process.exitCode=1;}
}
