import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest,checkTarget} from './pilot_preparation_contract.mjs';
import {cohortTemplate,validateIntake,observationSql,accountReview} from './pilot_cohort_contract.mjs';
import {verifyPublicationProof,postPublicationCohortPlans,lf} from './pilot_publication_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const slugPattern=/^[a-z][a-z0-9-]{2,60}$/;
const json=x=>JSON.stringify(x,null,2)+'\n';
export async function preparePostPublicationCohort(repo,slug,input=cohortTemplate(),observation=null,taxonomy=null){
 assert(slugPattern.test(slug));validateIntake(input);
 const proof=await verifyPublicationProof(repo);
 const ce=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_test_ce_installation.json'),'utf8'));checkTarget(ce.target);
 const files={'cohort.template.json':json(input),'cohort.observation.readonly.sql':observationSql(input)};
 if(observation){assert.equal(typeof taxonomy,'string');const plans=postPublicationCohortPlans(ce.target,taxonomy,input,observation,proof.installed_schema_md5);
  for(const [name,p] of Object.entries(plans))if(p){files[name+'.plan.json']=json(p.plan);files[name+'.review.sql']=p.sql;}}
 files['readiness.json']=json({target:ce.target,remote_authorized:false,distribution_ready:false,scope:'J6 category/role rules on exact independently rehearsed J7 schema; each candidate needs separate approval',catalog_publication:false,auth_creation:false,observation_supplied:!!observation,account_review:observation?accountReview(input,observation):{status:'OBSERVATION_MISSING'}});
 const manifest={kind:'merchant-pilot-post-publication-cohort-review-v1',remote_authorized:false,files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};files['bundle.json']=json(manifest);
 const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
 const parent=resolve(scratch,'pilot-publication-cohort-review');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
 const directory=resolve(parent,slug);await mkdir(directory);
 for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx',mode:0o600});return {directory,manifest};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{assert(process.argv.length===3||process.argv.length===4);let input=cohortTemplate(),observation=null,taxonomy=null;
  if(process.argv[3]){assert(slugPattern.test(process.argv[3]));const directory=resolve(root,'.buildlog/pilot-publication-cohort-input');
   async function read(suffix){const path=resolve(directory,process.argv[3]+suffix);assert.equal(await realpath(path),path);return readFile(path,'utf8');}
   input=JSON.parse(await read('.json'));observation=JSON.parse(await read('.observation.json'));taxonomy=await read('.taxonomy.json');}
  const result=await preparePostPublicationCohort(root,process.argv[2],input,observation,taxonomy);console.log('POST_PUBLICATION_COHORT_REVIEW_READY: '+result.directory+'; no remote action.');
 }catch{console.error('POST_PUBLICATION_COHORT_REVIEW_REFUSED: check exact source-bound observation and unused output name; no remote action.');process.exitCode=1;}
}
