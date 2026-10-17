import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {checkTarget,digest,quote,schemaExpression,readOnlySql,categoryPlan,authPlan} from './pilot_preparation_contract.mjs';
import {profileSha} from './pilot_hosted_profile.mjs';

export const installedSchemaMd5='6b26d924c04ad9aa568f15bfcf3279bf';
export const repairFile='supabase/proposals/pilot_notification_text_repair_v1.sql';
export const repairVersion='20261017003200';
export const repairName='0032_pilot_notification_text_repair';
export const repairSignatures=['create_chat_message_notification()','create_verified_purchase_notification()'];
const replacements=[
  ['Bir kullanÄ±cÄ±','Bir kullanıcı'],['Yeni mesajÄ±n var','Yeni mesajın var'],
  ['%s sana yeni bir mesaj gÃ¶nderdi.','%s sana yeni bir mesaj gönderdi.'],
  ['MaÄŸaza','Mağaza'],['AlÄ±ÅŸveriÅŸin onaylandÄ±','Alışverişin onaylandı'],
  ['%s alÄ±ÅŸveriÅŸini onayladÄ±.','%s alışverişini onayladı.'],
];
export const lf=text=>text.replaceAll('\r\n','\n');
const seal=value=>({...value,sha256:digest(JSON.stringify(value))});
const sourceHeader='-- REVIEW SOURCE ONLY: Development notification text correction.\n-- Execute only through the separately approved, guarded E bundle; never replay 0006.\n';

export function repairedSource(profile,canonical0006) {
  const definitions=[];
  for(const [index,signature] of repairSignatures.entries()) {
    const original=profile.function_definitions[signature];assert.equal(typeof original,'string');
    assert.equal(digest(original,'md5'),profile.schema.functions.find(f=>f.signature===signature)?.definition_md5);
    let fixed=lf(original);
    for(const [bad,good] of replacements.slice(index*3,index*3+3)) {
      assert.equal(fixed.split(quote(bad)).length,2,'Expected exactly one known SQL string literal');
      fixed=fixed.replace(quote(bad),quote(good));
    }
    const block=lf(canonical0006).split('CREATE FUNCTION public.'+signature+'\n')[1];
    assert(block,'Canonical 0006 function missing');
    assert.equal(fixed.split('$function$')[1],block.split('$function$')[1],'Correction must match canonical body exactly');
    assert(fixed.startsWith('CREATE OR REPLACE FUNCTION public.'+signature+'\n'));
    definitions.push({signature,before_md5:digest(original,'md5'),after_md5:digest(fixed,'md5'),definition:fixed});
  }
  return {sql:sourceHeader+definitions.map(f=>f.definition.trimEnd()+';\n').join('\n'),definitions};
}

export async function loadRepair(repo) {
  const profileText=lf(await readFile(resolve(repo,'docs/data/merchant_pilot_hosted_profile.json'),'utf8'));
  assert.equal(digest(profileText),profileSha,'Pinned observation changed');
  const source=repairedSource(JSON.parse(profileText),await readFile(resolve(repo,'supabase/migrations/20260812000600_0006_chat_notifications_account.sql'),'utf8'));
  const proposal=lf(await readFile(resolve(repo,repairFile),'utf8'));
  assert.equal(proposal,source.sql,'Only six canonical literal corrections are allowed');
  return {...source,sha256_lf:digest(proposal)};
}

// This module builds review text only. No connection or remote apply interface.
export const functionMetadataExpression=`(SELECT jsonb_agg(jsonb_build_object(
 'signature',p.oid::regprocedure::text,'oid',p.oid,'owner',pg_get_userbyid(p.proowner),
 'acl',p.proacl::text,'definer',p.prosecdef,'settings',p.proconfig,'language',p.prolang,
 'volatile',p.provolatile,'parallel',p.proparallel,'strict',p.proisstrict,'leakproof',p.proleakproof,
 'return_type',p.prorettype,'cost',p.procost,'rows',p.prorows,'support',p.prosupport)
 ORDER BY p.oid::regprocedure::text) FROM pg_proc p WHERE p.oid IN
 (${repairSignatures.map(s=>quote('public.'+s)+'::regprocedure').join(',')}))`;

export function repairPlan(target,receipt,source) {
  checkTarget(target);assert.deepEqual(receipt.target,target);
  assert.equal(receipt.kind,'merchant-pilot-approved-test-installation-v1');
  assert.equal(receipt.result,'PASS');assert.equal(receipt.postcheck.schema_md5,installedSchemaMd5);
  assert.equal(receipt.postcheck.core.ledger.length,13);
  assert.equal(digest(source.sql),source.sha256_lf);
  assert.equal(source.definitions.length,2);
  assert.deepEqual(source.definitions.map(({signature,before_md5,after_md5})=>({signature,before_md5,after_md5})),[
    {signature:repairSignatures[0],before_md5:'2c5c102cb8a2f0caa1e87563fa704602',after_md5:'99dd8841f5092b10634f25109e99f3b3'},
    {signature:repairSignatures[1],before_md5:'6f4d7f9a1ff3a53fe30e2fb925df2192',after_md5:'c1f3e83146c67dc68b74d34dd692e311'},
  ]);
  for(const fn of source.definitions)assert.equal(digest(fn.definition,'md5'),fn.after_md5);
  assert.equal(source.sql,sourceHeader+source.definitions.map(f=>f.definition.trimEnd()+';\n').join('\n'));
  const plan=seal({contract:'merchant-pilot-notification-repair-review-v1',target,
    baseline_md5:installedSchemaMd5,source_file:repairFile,source_sha256_lf:source.sha256_lf,
    ledger:{version:repairVersion,name:repairName},
    functions:source.definitions.map(({signature,before_md5,after_md5})=>({signature,before_md5,after_md5})),
    remote_authorized:false,effect:'Six future notification literals only; preserve all existing rows, function owners/ACL/OIDs and trigger wiring; add one new ledger entry',
    excluded:'No categories, Auth, accounts, historical row repair, push provider or feature activation',
    after_commit:'Preserve evidence and prepare a separately reviewed forward correction; never replay old migrations or delete historical notifications'});
  const restore=`jsonb_set(s,'{functions}',(SELECT jsonb_agg(CASE ${plan.functions.map(f=>`WHEN item->>'signature'=${quote(f.signature)} THEN jsonb_set(item,'{definition_md5}',to_jsonb(${quote(f.before_md5)}::text))`).join(' ')} ELSE item END ORDER BY ord) FROM jsonb_array_elements(s->'functions') WITH ORDINALITY x(item,ord)))`;
  assert(!source.sql.includes('$approved_notification_body$'));
  const sql=`-- REVIEW ONLY: ${target.project_ref}; separate approval for E required.\nBEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $pilot_repair_guard$ BEGIN
 IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'PILOT_REVIEW_NOT_APPROVED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:${target.project_ref}:pilot-notification-text',0)) THEN RAISE EXCEPTION 'PILOT_COMPETING_WRITER'; END IF;
END $pilot_repair_guard$;
LOCK TABLE public.notifications,public.chat_messages,public.verified_transactions,supabase_migrations.schema_migrations IN SHARE ROW EXCLUSIVE MODE;
DO $pilot_text_repair$
DECLARE before_schema jsonb; before_metadata jsonb; s jsonb;
BEGIN
 before_schema := ${schemaExpression};
 IF md5(before_schema::text)<>${quote(installedSchemaMd5)} THEN RAISE EXCEPTION 'PILOT_BASELINE_DRIFT'; END IF;
 before_metadata := ${functionMetadataExpression};
 EXECUTE replace($approved_notification_body$${source.sql}$approved_notification_body$,chr(13)||chr(10),chr(10));
 IF ${functionMetadataExpression} IS DISTINCT FROM before_metadata THEN RAISE EXCEPTION 'PILOT_FUNCTION_AUTHORITY_CHANGED'; END IF;
 ${plan.functions.map(f=>`IF md5(pg_get_functiondef(${quote('public.'+f.signature)}::regprocedure))<>${quote(f.after_md5)} THEN RAISE EXCEPTION 'PILOT_TEXT_POSTCHECK'; END IF;`).join('\n ')}
 s := ${schemaExpression};
 IF ${restore} IS DISTINCT FROM before_schema THEN RAISE EXCEPTION 'PILOT_UNRELATED_SCHEMA_CHANGE'; END IF;
 INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${quote(repairVersion)},${quote(repairName)},ARRAY[replace(${quote(source.sql)},chr(13)||chr(10),chr(10))]);
END $pilot_text_repair$;
COMMIT;
`;
  return {plan,sql,preflight:readOnlySql(`SELECT md5((${schemaExpression})::text)=${quote(installedSchemaMd5)} AS baseline_matches,md5((${schemaExpression})::text) AS observed_md5,${functionMetadataExpression} AS functions`),
    postcheck:readOnlySql(`SELECT md5((${schemaExpression})::text) AS schema_md5,(SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'md5',md5(pg_get_functiondef(p.oid))) ORDER BY p.oid::regprocedure::text) FROM pg_proc p WHERE p.oid IN (${repairSignatures.map(s=>quote('public.'+s)+'::regprocedure').join(',')})) AS functions,(SELECT jsonb_agg(jsonb_build_object('version',version,'name',name,'source_sha256_lf',encode(sha256(convert_to(replace(array_to_string(statements,''),chr(13)||chr(10),chr(10)),'UTF8')),'hex'))) FROM supabase_migrations.schema_migrations WHERE version=${quote(repairVersion)}) AS repair_ledger`)};
}

// No IDs, private contacts, passwords or participant permissions are collected.
// Unknown facts stay unknown. This report can never certify release readiness.
export function intakeTemplate() {
  return {version:1,location:'Istanbul / Esenler',participants_selected:false,
    product_leaf_ids:[],catalog_items_verified:false,account_identity_reviewed:false,
    account_role_reviewed:false,owner_shop_reviewed:false,customer_pair_ready:false,
    recovery_mail_verified:false,physical_qr_verified:false,signed_build_verified:false,
    support_owner_ready:false,rollback_reviewed:false,owner_launch_accepted:false};
}
export function assessIntake(target,taxonomyText,intake) {
  checkTarget(target);const template=intakeTemplate();
  assert.deepEqual(Object.keys(intake).sort(),Object.keys(template).sort(),'No unknown or sensitive intake fields');
  assert.equal(intake.version,1);assert.equal(intake.location,template.location);
  for(const key of Object.keys(template).filter(k=>typeof template[k]==='boolean')) assert.equal(typeof intake[key],'boolean',key);
  assert(Array.isArray(intake.product_leaf_ids));
  let categories=null;
  if(intake.product_leaf_ids.length) categories=categoryPlan(target,taxonomyText,intake.product_leaf_ids);
  const missing=Object.keys(template).filter(k=>typeof template[k]==='boolean'&&!intake[k]);
  if(!categories)missing.unshift('explicit_product_categories');
  if(!intake.participants_selected && (intake.account_identity_reviewed||intake.owner_shop_reviewed))throw Error('Cannot review nonexistent participants');
  if(intake.account_role_reviewed&&!intake.account_identity_reviewed)throw Error('Identity review must precede role review');
  if(intake.owner_shop_reviewed&&!intake.account_role_reviewed)throw Error('Role review must precede shop review');
  if(intake.catalog_items_verified&&!categories)throw Error('Catalog review requires explicit eligible leaves');
  return {contract:'merchant-pilot-intake-assessment-v1',target,remote_authorized:false,
    distribution_ready:false,assessment:missing.length?'INCOMPLETE':'CLAIMED_COMPLETE_REQUIRES_INDEPENDENT_EVIDENCE',
    missing,category_selection:categories?'PROPOSED_ONLY':'NOT_SELECTED',categories,
    limitations:['Self-reported flags do not prove accounts, remote acceptance or Product Owner permission',
      'Catalog decisions remain OFF; no SQL seed or product approval bypass is generated',
      'Service offerings, appointments and professional-review changes remain outside scope']};
}

export function reviewCallbacks(target,before,observedAfter) {
  const plan=authPlan(target,before);
  assert.deepEqual(observedAfter,plan.proposed,'Exact additive callback plan required; preserve other settings and existing URLs');
  return {result:'CONFIGURATION_MATCH_ONLY',remote_authorized:false,mail_delivered:false,
    physical_callback_accepted:false,plan_sha256:plan.sha256};
}
