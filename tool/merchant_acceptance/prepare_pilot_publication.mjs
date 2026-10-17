import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {digest,checkTarget,readOnlySql,schemaExpression} from './pilot_preparation_contract.mjs';
import {publicationTemplate,validatePublication,verifyPublicationProof,loadPublication,publicationSchemaPlan,publicationPlan,publicationObservationSql,lf} from './pilot_publication_contract.mjs';
const root=fileURLToPath(new URL('../../',import.meta.url));
const slugPattern=/^[a-z][a-z0-9-]{2,60}$/;
const json=x=>JSON.stringify(x,null,2)+'\n';
export async function preparePublication(repo,slug,input=publicationTemplate(),observation=null){
 assert(slugPattern.test(slug),'New plain output name required');validatePublication(input);
 const ce=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_test_ce_installation.json'),'utf8'));checkTarget(ce.target);
 const proof=await verifyPublicationProof(repo);
 const schema=publicationSchemaPlan(ce.target,await loadPublication(repo));
 const files={'intake.template.json':json(input),'observation.readonly.sql':publicationObservationSql(input),
 'schema.plan.json':json(schema.plan),'schema.review.sql':schema.sql,
 'schema.verification.readonly.sql':readOnlySql(`SELECT md5((${schemaExpression})::text) AS schema_md5, md5((${schemaExpression})::text)='${proof.installed_schema_md5}' AS matches_rehearsed_structure, (SELECT decisions_enabled FROM public.catalog_media_config) AS decisions_enabled; SELECT version,name FROM supabase_migrations.schema_migrations WHERE version='${schema.plan.version}'`)};
 let publication=null;
 if(observation){publication=publicationPlan(ce.target,input,observation,proof.installed_schema_md5);files['publication.plan.json']=json(publication.plan);files['publication.review.sql']=publication.sql;files['receipt.readonly.sql']=publication.receipt;}
 const report={target:ce.target,remote_authorized:false,schema:'REVIEW_CANDIDATE_ONLY; separate approval and integration PASS required',
  publication:publication?'EXACT_BATCH_REVIEW_ONLY':'MISSING_REAL_SUBMISSIONS_AND_FRESH_POST_INSTALL_OBSERVATION',
  client_contract:'listing_only_v1; compatible Customer and Merchant builds must be reviewed before first publication; old clients are not safe for tagged zero',
  distribution_ready:false,decisions_enabled:false,
  gates:['Explicit approval for schema installation','Real physical products, categories, verified owners and evidence','Fresh post-install snapshot and separate exact batch approval','Compatible builds, physical QR, provider, mail and pilot opening acceptance']};
 files['readiness.json']=json(report);
 const manifest={kind:'merchant-pilot-publication-review-bundle-v1',target:ce.target,remote_authorized:false,publication_sql:!!publication,
  contains_private_ids:input.items.length>0,files:Object.entries(files).map(([path,content])=>({path,sha256_lf:digest(lf(content))}))};
 files['bundle.json']=json(manifest);
 const canonical=await realpath(repo),scratch=resolve(canonical,'.buildlog');await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch);
 const parent=resolve(scratch,'pilot-publication-review');await mkdir(parent,{recursive:true});assert.equal(await realpath(parent),parent);
 const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);await mkdir(directory);
 for(const [name,content] of Object.entries(files))await writeFile(resolve(directory,name),content,{flag:'wx',mode:0o600});
 return {directory,manifest,report};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{assert(process.argv.length===3||process.argv.length===4,'New output name and optional private intake name only');let input=publicationTemplate(),observation=null;
  if(process.argv[3]){assert(slugPattern.test(process.argv[3]));const directory=resolve(root,'.buildlog/pilot-publication-input');
   const path=resolve(directory,process.argv[3]+'.json');assert.equal(await realpath(path),path);input=JSON.parse(await readFile(path,'utf8'));
   const observed=resolve(directory,process.argv[3]+'.observation.json');try{assert.equal(await realpath(observed),observed);observation=JSON.parse(await readFile(observed,'utf8'));}catch(e){if(e.code!=='ENOENT')throw e;}}
  const result=await preparePublication(root,process.argv[2],input,observation);console.log('PILOT_PUBLICATION_REVIEW_READY: '+result.directory+'; no remote action.');
 }catch{console.error('PILOT_PUBLICATION_REVIEW_REFUSED: verify input, local proof and unused output name; no remote action.');process.exitCode=1;}
}
