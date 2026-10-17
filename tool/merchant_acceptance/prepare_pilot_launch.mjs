import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath,lstat} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest,authPlan,cohortPlan} from './pilot_preparation_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {loadRepair,repairPlan,intakeTemplate,assessIntake,installedSchemaMd5,lf} from './pilot_launch_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const json=value=>JSON.stringify(value,null,2)+'\n';
const namePattern=/^[a-z][a-z0-9-]{2,60}$/;

// Fixed scratch output, source-bound local proof, no remote client/apply switch.
export async function prepareLaunch(repo,slug,intake=intakeTemplate()) {
  assert(namePattern.test(slug),'Use one plain new bundle name');
  const receipt=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
  const baseline=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
  const previous=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_acceptance.json'),'utf8'));
  const proof=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_launch_acceptance.json'),'utf8'));
  const repair=repairPlan(receipt.target,receipt,await loadRepair(repo));
  assert.equal(proof.result,'PASS');assert.equal(proof.before_schema_md5,installedSchemaMd5);
  assert.equal(proof.repair_plan.sha256,repair.plan.sha256,'Repair plan changed since rehearsal');
  assert.equal(proof.remote_writes,'NONE');assert.equal(proof.production_access,'NONE');
  assert(proof.checks.length===18 && proof.checks.every(c=>c.result==='PASS'),'Complete local rehearsal required');
  assert.equal(proof.before_taxonomy_md5,receipt.postcheck.taxonomy_md5);
  assert.equal(digest(baseline.taxonomy_text,'md5'),receipt.postcheck.taxonomy_md5);
  const required=['tool/merchant_acceptance/pilot_launch_contract.mjs','tool/merchant_acceptance/pilot_launch.mjs','tool/merchant_acceptance/prepare_pilot_launch.mjs',repair.plan.source_file,'tool/merchant_acceptance/pilot_hosted_profile.mjs','tool/merchant_acceptance/pilot_preparation_contract.mjs','tool/merchant_acceptance/fixture.mjs','tool/merchant_acceptance/local.mjs','tool/merchant_acceptance/safety.mjs','tool/merchant_acceptance/docker-proxy.mjs','tool/merchant_acceptance/pilot_launch_profile.mjs','docs/data/merchant_pilot_post_a_observation.json'];
  assert.deepEqual(proof.sources.map(s=>s.path),required,'Proof source manifest incomplete');
  for(const source of proof.sources)assert.equal(digest(lf(await readFile(resolve(repo,source.path),'utf8'))),source.sha256_lf,'Local proof stale: '+source.path);
  const assessment=assessIntake(receipt.target,baseline.taxonomy_text,intake);
  const auth=authPlan(receipt.target,previous.auth_plan.before);
  const files={
    'notification.plan.json':json(repair.plan),'notification.preflight.sql':repair.preflight,
    'notification.review.sql':repair.sql,'notification.postcheck.readonly.sql':repair.postcheck,
    'auth.plan.json':json({...auth,observation_scope:'Prior read-only settings observation, not a fresh settings read; reread before approval/apply'}),
    'intake.template.json':json(intake),'intake.assessment.json':json({...assessment,categories:undefined}),
    'cohort.example.json':json(cohortPlan(receipt.target,[{slot:'merchant-01',role:'merchant',user_id:null},{slot:'customer-01',role:'customer',user_id:null}])),
    'category-inventory.json':json({scope:'Eligibility only, no sector exclusion or activation permission',items:categoryInventory(receipt.target,baseline.taxonomy_text)}),
  };
  if(assessment.categories){files['category.plan.json']=json(assessment.categories.plan);files['category.review.sql']=assessment.categories.sql;}
  const manifest={kind:'merchant-pilot-launch-review-bundle-v1',target:receipt.target,
    remote_authorized:false,schema_A:'ALREADY_INSTALLED; never replay',notification_E:'PROPOSED_ONLY',
    callbacks_C:'PROPOSED_ONLY; fresh settings read required',category_B:assessment.category_selection,
    provisioning_D:'NOT_AUTHORIZED; no account/catalog writes generated',distribution_ready:false,
    local_repair_post_schema_md5:proof.after_schema_md5,
    files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};
  files['bundle.json']=json(manifest);
  const canonicalRepo=await realpath(repo),scratch=resolve(canonicalRepo,'.buildlog');await mkdir(scratch,{recursive:true});
  assert.equal(await realpath(scratch),scratch,'Scratch redirection forbidden');
  const parent=resolve(scratch,'pilot-launch-review');await mkdir(parent,{recursive:true});
  assert(!(await lstat(parent)).isSymbolicLink());assert.equal(await realpath(parent),parent);
  const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);await mkdir(directory);
  for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx'});
  return {directory,manifest};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
  try{
    assert(process.argv.length===3||process.argv.length===4,'Use a new bundle name and optional local intake name');
    let intake=intakeTemplate();
    if(process.argv[3]){
      assert(namePattern.test(process.argv[3]),'Use one plain local intake name');
      const path=resolve(root,'.buildlog/pilot-intake',process.argv[3]+'.json');
      assert.equal(await realpath(path),path,'Intake redirection forbidden');intake=JSON.parse(await readFile(path,'utf8'));
    }
    const result=await prepareLaunch(root,process.argv[2],intake);
    console.log('PILOT_LAUNCH_REVIEW_READY: '+result.directory+'; no remote execution or authorization.');
  }catch{console.error('PILOT_LAUNCH_REVIEW_REFUSED: check source-bound proof, explicit intake fields and new output name. No remote action attempted.');process.exitCode=1;}
}
