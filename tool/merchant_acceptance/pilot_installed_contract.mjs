import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {checkTarget,digest,readOnlySql,schemaExpression,taxonomyExpression} from './pilot_preparation_contract.mjs';
import {cohortTemplate,validateIntake,observationSql,accountReview,catalogReview,postCeSchemaMd5} from './pilot_cohort_contract.mjs';
import {publicationSources,publicationTemplate,validatePublication,publicationObservationSql,publicationPlan,postPublicationCohortPlans,lf} from './pilot_publication_contract.mjs';
import {installedReceipt,installedReceiptSha,installedSchemaMd5,verifiedInstalledProfile} from './pilot_installed_profile.mjs';

export const installedSources=[...publicationSources,installedReceipt,
 'docs/data/merchant_pilot_publication_acceptance.json',
 'tool/merchant_acceptance/pilot_installed_profile.mjs',
 'tool/merchant_acceptance/pilot_installed_contract.mjs',
 'tool/merchant_acceptance/prepare_installed_pilot.mjs',
 'tool/merchant_acceptance/pilot_installed.mjs',
 'tool/merchant_acceptance/pilot_installed.test.mjs'];
export const installedProofPath='docs/data/merchant_pilot_installed_acceptance.json';
export const installedKinds=['cohort','publication'];
const json=value=>JSON.stringify(value,null,2)+'\n';
export function installedTemplate(kind){assert(installedKinds.includes(kind));return kind==='cohort'?cohortTemplate():publicationTemplate();}

export function installedCohortPlans(target,taxonomy,input,observation){
 checkTarget(target);validateIntake(input);
 return postPublicationCohortPlans(target,taxonomy,input,observation,installedSchemaMd5);
}
export function installedPublicationPlan(target,input,observation){
 return publicationPlan(target,input,observation,installedSchemaMd5);
}

// Generates review material only. No installer, credentials, execution token,
// network client, or fallback to an older/normalized schema can enter the bundle.
export function installedReviewFiles(target,kind,input,observation=null,taxonomy=null){
 checkTarget(target);assert(installedKinds.includes(kind));
 if(kind==='cohort')validateIntake(input);else validatePublication(input);
 const files={'intake.template.json':json(input),
  'observation.readonly.sql':kind==='cohort'?observationSql(input):publicationObservationSql(input),
  'structure.readonly.sql':readOnlySql(`SELECT md5((${schemaExpression})::text) AS schema_md5, md5((${schemaExpression})::text)='${installedSchemaMd5}' AS matches_installed_profile,(SELECT decisions_enabled FROM public.catalog_media_config) AS decisions_enabled`)};
 const proposals=[];let accounts=null,catalog=null;
 if(observation){
  if(kind==='cohort'){
   assert.equal(typeof taxonomy,'string');
   const plans=installedCohortPlans(target,taxonomy,input,observation);
   accounts=accountReview(input,observation);
   // The unchanged J6 catalog assessment has no mutation output. Its historical
   // baseline is translated only after the full J8 observation validation above.
   catalog=catalogReview(target,taxonomy,input,{...observation,schema_md5:postCeSchemaMd5});
   catalog.materialization_gate='Use a separate installed-profile publication intake with actual pending physical-product submissions and reviewed compatible clients';
   for(const [name,p] of Object.entries(plans))if(p){proposals.push(name);files[name+'.plan.json']=json(p.plan);files[name+'.review.sql']=p.sql;}
  }else if(input.items.length){
   const p=installedPublicationPlan(target,input,observation);proposals.push('publication');
   files['publication.plan.json']=json(p.plan);files['publication.review.sql']=p.sql;files['receipt.readonly.sql']=p.receipt;
  }else{
   // Empty inputs never acquire authority through an unrelated supplied snapshot.
   assert.equal(observation.schema_md5,installedSchemaMd5);assert.equal(observation.decisions_enabled,false);
   assert.deepEqual(observation.selected,[]);
  }
 }
 if(kind==='cohort')files['taxonomy.readonly.sql']=readOnlySql(`SELECT (${taxonomyExpression})::text AS taxonomy_text`);
 const report={kind:'merchant-pilot-installed-readiness-v1',target,mode:kind,remote_authorized:false,
  installed_profile:{receipt_sha256_lf:installedReceiptSha,raw_schema_md5:installedSchemaMd5},
  status:proposals.length?'REVIEW_CANDIDATES_ONLY':'INCOMPLETE_NO_MUTATION',
  observation:observation?'SUPPLIED_SNAPSHOT; exact state is rechecked in each transaction':'MISSING; installation receipt is not fresh account/catalog evidence',
  proposals,accounts,catalog,auth_creation:false,schema_installation:false,distribution_ready:false,
  gates:['Separate exact category/account/publication approval','Fresh target/schema/data and verified identity checks','Compatible client pair before publication','Real mail/provider, signed distribution, physical QR and pilot opening acceptance']};
 files['readiness.json']=json(report);
 return {files,report};
}

export async function verifyInstalledReadinessProof(repo){
 const profile=await verifiedInstalledProfile(repo);
 const proof=JSON.parse(await readFile(resolve(repo,installedProofPath),'utf8'));
 assert.equal(proof.kind,'merchant-pilot-installed-local-only-v1');assert.equal(proof.result,'PASS');
 assert.equal(proof.remote_access,'NONE');assert.equal(proof.installed_schema_md5,installedSchemaMd5);
 assert.equal(proof.receipt_sha256_lf,installedReceiptSha);
 assert(proof.checks.length>=24&&proof.checks.every(c=>c.result==='PASS'));
 assert.equal(proof.client_checks.length,18);assert(proof.client_checks.every(c=>c.result==='PASS'));
 assert.deepEqual(proof.sources.map(s=>s.path),installedSources);
 for(const source of proof.sources)assert.equal(digest(lf(await readFile(resolve(repo,source.path),'utf8'))),source.sha256_lf,'Installed proof stale: '+source.path);
 return {profile,proof};
}
