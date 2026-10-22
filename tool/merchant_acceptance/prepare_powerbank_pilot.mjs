// Offline review only; neither network access nor an apply command exists here.
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest,projectRef,projectUrl} from './pilot_preparation_contract.mjs';
import {captureIntegratedSources} from './pilot_integrated_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';
import {lf} from './pilot_publication_contract.mjs';
import {powerbankManifest,powerbankManifestPath,powerbankProofPath,powerbankObservationSql,powerbankCategoryPlan,powerbankRollbackPlan} from './pilot_powerbank_contract.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const slugPattern=/^[a-z][a-z0-9-]{2,60}$/;
export const databaseChecks=[
 'existing approved branch cannot accept a powerbank before the additive leaf',
 'missing approval token leaves all categories unchanged',
 'permission drift is refused without normalizing the schema',
 'even unrelated category metadata drift prevents activation',
 'catalog and decision drift are independently refused',
 'concurrent category writer cannot race the reviewed snapshot',
 'late failure rolls back both new leaf and ancestor activation',
 'one leaf and two ancestors change while schema and historical rows remain intact',
 'replay is rejected rather than allocating another identity',
 'separate recovery retains new identity and cannot delete historic rows',
 'real barcode-less submission creates one pending row and no product or identifier',
 'category recovery refuses after product publication',
 'published price and stock survive actual client checks without enabling decisions or inventing purchases',
 'historical proofs remain byte-identical and current sources stayed unchanged',
];
export const clientChecks=[{phase:'submission',checks:[
 'current repository onboarding',
 'exact newly approved leaf is the only selectable category',
 'barcode-less submission retries return one pending identity without publishing',
]},{phase:'listing',checks:[
 'published identity supports owner listing at TRY 990',
 'Customer reads the merchant price',
 'unavailable listing disappears and stale price update is rejected',
 'stock recovery preserves price and another merchant cannot edit',
]}];
export function validatePowerbankProof(p,sources,manifestSha){
 assert.equal(p.kind,'merchant-pilot-powerbank-local-v1');assert.equal(p.result,'PASS');
 assert.equal(p.remote_access,'NONE');assert.equal(p.production_writes,'NONE');
 assert.equal(p.distribution_ready,false);assert.equal(p.physical_two_device,'OPEN');
 assert.equal(p.synthetic_accounts,true);assert.equal(p.real_catalog_written,false);assert.equal(p.verified_purchases,0);
 assert.match(p.run_id,/^ev-merchant-ab-[a-f0-9]{12}$/);assert.match(p.nonce_sha256,/^[a-f0-9]{64}$/);
 assert.match(p.source_commit,/^[a-f0-9]{40}$/);assert(Number.isFinite(Date.parse(p.captured_at)));
 assert.equal(p.installed_schema_md5,installedSchemaMd5);
 assert.equal(p.manifest_sha256_lf,manifestSha);
 assert.deepEqual(p.checks,databaseChecks.map(name=>({name,result:'PASS'})));
 assert.deepEqual(p.client_checks,clientChecks);
 assert.deepEqual(p.sources,sources,'Powerbank proof stale or incomplete');
}
export async function verifyPowerbankProof(repo){
 const proof=JSON.parse(await readFile(resolve(repo,powerbankProofPath),'utf8'));
 validatePowerbankProof(proof,await captureIntegratedSources(repo),digest(lf(await readFile(resolve(repo,powerbankManifestPath),'utf8'))));
 const expected=['docs/data/merchant_pilot_publication_acceptance.json','docs/data/merchant_pilot_installed_acceptance.json','docs/data/merchant_pilot_integrated_ui_acceptance.json','docs/data/merchant_pilot_integrated_repository_acceptance.json'];
 assert.deepEqual(proof.historical_proofs.map(x=>x.path),expected);
 for(const p of proof.historical_proofs)assert.equal(p.sha256_lf,digest(lf(await readFile(resolve(repo,p.path),'utf8'))));
 return proof;
}
export async function preparePowerbankPilot(repo,mode,slug,observation=null){
 assert(['observe','activate','deactivate'].includes(mode));assert(slugPattern.test(slug),'Plain unused output name required');
 const canonical=await realpath(repo);await verifyPowerbankProof(canonical);
 const target={project_ref:projectRef,project_url:projectUrl},manifest=await powerbankManifest(canonical);
 const prepared=mode==='observe'?null:(mode==='activate'?powerbankCategoryPlan:powerbankRollbackPlan)(target,observation,manifest);
 const files={'observation.readonly.sql':powerbankObservationSql()};
 if(prepared){files['plan.json']=JSON.stringify(prepared.plan,null,2)+'\n';files[mode+'.review-only.sql']=prepared.sql;}
 files['README.txt']='Development '+projectRef+' only. REVIEW ONLY; no remote execution or owner approval is implied. Verify the actual project identity in the official dashboard and obtain separate owner approval before any write. The SQL token is an accident guard, not authorization. Do not replay local fixture SQL. Refresh observations after any change. Deactivation retains category identity and requires an empty catalog. No product, price, role, feature or Production changes.\n';
 const bundle={kind:'powerbank-review-bundle-v1',mode,target,remote_authorized:false,files:Object.entries(files).map(([path,content])=>({path,sha256:digest(content)}))};
 files['bundle.json']=JSON.stringify(bundle,null,2)+'\n';
 const scratch=resolve(canonical,'.buildlog');await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
 const parent=resolve(scratch,'pilot-powerbank-review');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
 const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);await mkdir(directory);
 for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx',mode:0o600});
 return directory;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{
  assert(process.argv.length===4);const [,,mode,slug]=process.argv;assert(slugPattern.test(slug));
  let observation=null;
  if(mode!=='observe'){
   const base=await realpath(root),input=resolve(base,'.buildlog/pilot-powerbank-input',slug+'.json');
   assert.equal(await realpath(input),input);observation=JSON.parse(await readFile(input,'utf8'));
  }
  console.log('POWERBANK_REVIEW_READY: '+await preparePowerbankPilot(root,mode,slug,observation)+'; no hosted action.');
 }catch{console.error('POWERBANK_REVIEW_REFUSED: exact current proof, approved category, observation and unused path required; no hosted action.');process.exitCode=1;}
}
