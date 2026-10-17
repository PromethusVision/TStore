import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest,checkTarget} from './pilot_preparation_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {cohortTemplate,validateIntake,observationSql,validateObservation,accountReview,roleProposal,boundedCategories,catalogReview,cohortSources,postCeSchemaMd5} from './pilot_cohort_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const slugPattern=/^[a-z][a-z0-9-]{2,60}$/;
const json=x=>JSON.stringify(x,null,2)+'\n';
const lf=x=>x.replaceAll('\r\n','\n');

export async function prepareCohort(repo,slug,input=cohortTemplate(),observation=null) {
 assert(slugPattern.test(slug),'Plain new output name required');validateIntake(input);
 const ce=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_test_ce_installation.json'),'utf8'));
 checkTarget(ce.target);assert.equal(ce.result,'PASS');assert.equal(ce.notification_repair.after.schema_md5,postCeSchemaMd5);
 const base=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
 assert.equal(digest(base.taxonomy_text,'md5'),ce.notification_repair.after.taxonomy_md5);
 const proof=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_cohort_acceptance.json'),'utf8'));
 assert.equal(proof.kind,'merchant-pilot-cohort-local-only-v1');assert.equal(proof.result,'PASS');assert.equal(proof.post_ce_schema_md5,postCeSchemaMd5);
 assert.equal(proof.remote_access,'NONE');assert.equal(proof.checks.length,20);assert(proof.checks.every(x=>x.result==='PASS'));
 assert.equal(proof.client_checks.length,18);assert(proof.client_checks.every(x=>x.result==='PASS'));
 assert.deepEqual(proof.sources.map(x=>x.path),cohortSources);
 for(const s of proof.sources)assert.equal(digest(lf(await readFile(resolve(repo,s.path),'utf8'))),s.sha256_lf,'Local proof stale: '+s.path);
 const files={'intake.template.json':json(input),'observation.readonly.sql':observationSql(input),
  'category-inventory.json':json({scope:'Dated unchanged taxonomy; product eligibility only, no sector exclusion or activation permission',items:categoryInventory(ce.target,base.taxonomy_text)})};
 let accounts=null,catalog=null,category=null,roles=null;
 if(observation){
  validateObservation(ce.target,base.taxonomy_text,observation);
  assert.deepEqual(observation.accounts.map(x=>x.id).sort(),input.accounts.map(a=>a.user_id).filter(Boolean).sort(),'Observation must cover exactly selected accounts');
  accounts=accountReview(input,observation);catalog=catalogReview(ce.target,base.taxonomy_text,input,observation);
  if(input.category_leaf_ids.length){category=boundedCategories(ce.target,base.taxonomy_text,observation,input.category_leaf_ids);files['category.plan.json']=json(category.plan);files['category.review.sql']=category.sql;}
  if(!accounts.issues.length&&accounts.changes.length){roles=roleProposal(ce.target,base.taxonomy_text,input,observation);files['roles.plan.json']=json(roles.plan);files['roles.review.sql']=roles.sql;}
 }
 const report={target:ce.target,remote_authorized:false,distribution_ready:false,
  observation:observation?'SUPPLIED_SNAPSHOT_REQUIRES_FRESH_PREAPPLY_RECHECK':'MISSING; no mutation SQL emitted',
  accounts:accounts??{status:'PARTICIPANTS_OR_OBSERVATION_MISSING'},catalog:catalog??{status:'PRODUCTS_OR_OBSERVATION_MISSING',publication_sql_generated:false},
  category:category?'PROPOSED_ONLY':'NOT_SELECTED_OR_OBSERVED',roles:roles?'PROPOSED_ONLY':'NO_MUTATION_PROPOSED',
  new_catalog_products:'BLOCKED_PENDING_MATERIALIZATION_CONTRACT',auth_creation:'USER_SECURE_SIGNUP_OR_SEPARATELY_APPROVED_ADMIN_FLOW; no SQL or credential collection',
  pending_gates:['Explicit separate B and D approval','Fresh target/schema/data and exact identity review','Catalog publication/legacy-price decision for new products','Real mail/device/QR, signed distribution and owner pilot opening']};
 files['readiness.json']=json(report);
 const manifest={kind:'merchant-pilot-cohort-review-bundle-v1',target:ce.target,remote_authorized:false,contains_private_account_ids:input.accounts.some(a=>a.user_id),
  historical_installations:'A/C/E already completed; never replay',catalog_publication_sql:false,account_creation:false,distribution_ready:false,
  files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};
 files['bundle.json']=json(manifest);
 const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
 const parent=resolve(scratch,'pilot-cohort-review');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
 const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);await mkdir(directory);
 for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx',mode:0o600});
 return {directory,manifest,report};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{
  assert(process.argv.length===3||process.argv.length===4,'Use new output name and optional private intake name');
  let input=cohortTemplate(),observation=null;
  if(process.argv[3]){
   assert(slugPattern.test(process.argv[3]));const directory=resolve(root,'.buildlog/pilot-cohort-input');
   const path=resolve(directory,process.argv[3]+'.json');assert.equal(await realpath(path),path);input=JSON.parse(await readFile(path,'utf8'));
   const observed=resolve(directory,process.argv[3]+'.observation.json');
   try{assert.equal(await realpath(observed),observed);observation=JSON.parse(await readFile(observed,'utf8'));}catch(e){if(e.code!=='ENOENT')throw e;}
  }
  const result=await prepareCohort(root,process.argv[2],input,observation);
  console.log('PILOT_COHORT_REVIEW_READY: '+result.directory+'; no remote operation; missing facts remain gated.');
 }catch{console.error('PILOT_COHORT_REVIEW_REFUSED: check exact input, new output name and current local proof; no remote action.');process.exitCode=1;}
}
