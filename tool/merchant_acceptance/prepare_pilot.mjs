import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,realpath,lstat} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {checkTarget,loadDelta,schemaPlan,categoryPlan,authPlan,cohortPlan,digest,schemaExpression,taxonomyExpression,readOnlySql} from './pilot_preparation_contract.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const json=value=>JSON.stringify(value,null,2)+'\n';
export function categoryInventory(target,text) {
  checkTarget(target);
  const nodes=JSON.parse(text),byId=new Map(nodes.map(n=>[n.id,n]));
  const parents=new Set(nodes.map(n=>n.parent_id)),leaves=nodes.filter(n=>!parents.has(n.id));
  return leaves.map(leaf=>{
    const path=[],seen=new Set();let node=leaf;
    while(node) {assert(!seen.has(node.id),'Taxonomy cycle');seen.add(node.id);path.unshift(node.name);node=byId.get(node.parent_id);}
    try {categoryPlan(target,text,[leaf.id]);return {id:leaf.id,path,eligible:true};}
    catch(error) {return {id:leaf.id,path,eligible:false,reason:error.message.split('\n')[0]};}
  });
}

// Offline file generation ONLY. No remote executor, DB URL, credential, approval
// switch, Auth client or migration CLI exists here. Generated SQL is a review
// artifact; it cannot establish human approval or identify the executing server.
export async function prepareBundle(repo,slug,leaves=[]) {
  assert(/^[a-z][a-z0-9-]{2,60}$/.test(slug),'Use one plain new bundle name');
  assert(Array.isArray(leaves));
  const baseline=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_baseline.json'),'utf8'));
  const evidence=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_preparation_acceptance.json'),'utf8'));
  assert.equal(baseline.kind,'merchant-pilot-local-baseline-v1');assert.equal(baseline.remote_observed,false);
  checkTarget(baseline.target);assert.equal(evidence.result,'PASS');
  assert.equal(digest(baseline.schema_text),evidence.schema_plan.baseline_sha256,'Baseline not bound to passing local evidence');
  assert.equal(digest(baseline.taxonomy_text,'md5'),evidence.synthetic_category_plan.taxonomy_md5,'Taxonomy not bound to passing local evidence');
  assert.equal(evidence.checks.length,18);assert(evidence.checks.every(c=>c.result==='PASS'));assert.equal(evidence.client_checks.length,18);
  assert.equal(digest((await readFile(resolve(repo,'docs/data/merchant_pilot_hosted_profile.json'),'utf8')).replaceAll('\r\n','\n')),evidence.hosted_profile.sha256_lf,'Hosted mirror observation changed');
  for(const item of evidence.sources) {
    assert(/^tool\/merchant_acceptance\/[a-z_]+\.(mjs|dart)$/.test(item.path));
    assert.equal(digest((await readFile(resolve(repo,item.path),'utf8')).replaceAll('\r\n','\n')),item.sha256_lf,'Local proof is stale; rehearse changed sources');
  }
  const schema=schemaPlan(baseline.target,baseline.schema_text,await loadDelta(repo));
  const category=leaves.length?categoryPlan(baseline.target,baseline.taxonomy_text,leaves):null;
  const auth=authPlan(baseline.target,evidence.auth_plan.before);
  const cohort=cohortPlan(baseline.target,[{slot:'merchant-01',role:'merchant',user_id:null},{slot:'customer-01',role:'customer',user_id:null}]);
  const files={
    'schema.plan.json':json(schema.plan),'schema.preflight.sql':schema.preflight,'schema.review.sql':schema.sql,
    'schema.components.readonly.sql':readOnlySql(`SELECT jsonb_object_agg(key,md5(value::text)) AS component_hashes, md5((${taxonomyExpression})::text) AS taxonomy_md5 FROM jsonb_each(${schemaExpression})`),
    'auth.plan.json':json(auth),'cohort.example.json':json(cohort),
    'category-inventory.json':json({scope:'PRODUCT leaves, not merchant sectors; eligibility is not approval',items:categoryInventory(baseline.target,baseline.taxonomy_text)}),
  };
  if(category) {files['category.plan.json']=json(category.plan);files['category.review.sql']=category.sql;}
  const manifest={kind:'merchant-pilot-offline-review-bundle-v1',target:baseline.target,
    remote_authorized:false,remote_preflight:'MUST_PASS_AFTER_REVIEW; local baseline is not remote evidence',
    category_selection:category?'PROPOSED_ONLY':'NOT_SELECTED',provisioning:'NOT_AUTHORIZED',
    files:Object.entries(files).map(([path,content])=>({path,sha256:digest(content)}))};
  files['bundle.json']=json(manifest);
  // Fixed scratch root, no arbitrary output path, no overwrite, no symlinks.
  const canonicalRepo=await realpath(repo),scratch=resolve(canonicalRepo,'.buildlog');
  await mkdir(scratch,{recursive:true});assert.equal(await realpath(scratch),scratch,'Scratch path must not be redirected');
  const parent=resolve(scratch,'pilot-review');await mkdir(parent,{recursive:true});
  assert(!(await lstat(parent)).isSymbolicLink());assert.equal(await realpath(parent),parent);
  const directory=resolve(parent,slug);assert.equal(dirname(directory),parent);
  await mkdir(directory); // Existing/partial bundles are preserved, never overwritten.
  for(const [name,content] of Object.entries(files)) await writeFile(resolve(directory,name),content,{flag:'wx'});
  return {directory,manifest};
}

if(process.argv[1] && import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  try {
    assert(process.argv.length>=3,'Usage: prepare_pilot.mjs new-bundle-name [explicit-leaf-uuid ...]');
    const result=await prepareBundle(root,process.argv[2],process.argv.slice(3));
    console.log('OFFLINE_REVIEW_READY: '+result.directory+'; no remote authorization or execution.');
  } catch {console.error('PILOT_PREPARATION_REFUSED: check arguments, current local evidence and fresh output name. No remote action was attempted.');process.exitCode=1;}
}
