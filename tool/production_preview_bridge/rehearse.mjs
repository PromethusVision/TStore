import {writeFileSync,mkdirSync} from 'node:fs';
import {resolve,isAbsolute,relative,sep} from 'node:path';
import {createHmac} from 'node:crypto';
import {create,session,stop,run,container,freshBackup,latestBackupHash} from './local.mjs';
import {restore} from './restore.mjs';
import {baseline,archiveRows} from './baseline.mjs';
import {HttpChecks} from './http.mjs';
import {apply0012,readPostflight} from '../production_taxonomy/execution/engine.mjs';
import {catalog,catalogHashes,ledger,legacyDataHashes} from '../production_taxonomy/execution/catalog.mjs';
import {integrity,legacyQueries} from '../production_taxonomy/real_contract_checks.mjs';
import {check,hash,stable,literal,safeError,read,root as repositoryRoot} from '../production_taxonomy/execution/common.mjs';
const migration=read('supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql');
const rollback=read('tool/production_preview_bridge/rollback.sql');
const proofDir=process.env.W52KB_PROOF_DIR;
check(isAbsolute(proofDir??''),'PRIVATE_PROOF_DIRECTORY');
const proofRelative=relative(repositoryRoot,proofDir);
check(proofRelative==='..'||proofRelative.startsWith('..'+sep)||isAbsolute(proofRelative),'PROOF_MUST_STAY_OUTSIDE_REPOSITORY');
mkdirSync(proofDir,{recursive:true});
let db,http;
const result={format:'w52kb-real-copy-rehearsal-v1',result:'FAIL',started_at_utc:new Date().toISOString(),source_backup_sha256:latestBackupHash,migration_sha256:hash(migration),rollback_sha256:hash(rollback),production_accessed:false,development_accessed:false,production_write_performed:false,failures:[]};
function request(identity,name,args={},validSignature=true){
 const url=new URL('/rpc/'+name,'http://127.0.0.1:3000');for(const[k,v]of Object.entries(args))url.searchParams.set(k,String(v));
 let config=`url = ${JSON.stringify(url.href)}\n`;
 if(identity){
  const b64=v=>Buffer.from(JSON.stringify(v)).toString('base64url');
  const body=b64({alg:'HS256',typ:'JWT'})+'.'+b64({...identity,exp:Math.floor(Date.now()/1000)+600});
  const token=body+'.'+createHmac('sha256',validSignature?http.key:'invalid-local-test-signature').update(body).digest('base64url');
  config+=`header = ${JSON.stringify('Authorization: Bearer '+token)}\n`;
 }
 const output=run(['exec','-i',container,'curl','--silent','--show-error','--max-time','15','--write-out','\n%{http_code}','--config','-'],config);
 const split=output.lastIndexOf('\n');return {status:Number(output.slice(split+1)),body:JSON.parse(output.slice(0,split))};
}
async function snap(){return {catalog:catalogHashes(await catalog(db)),ledger:await ledger(db),legacy:await legacyDataHashes(db),counts:await integrity(db,true),canonical_data:(await db.query("SELECT md5(string_agg(to_jsonb(c)::text,chr(10) ORDER BY id)) AS hash FROM public.canonical_categories c")).rows[0],mappings:(await db.query("SELECT md5(string_agg(to_jsonb(a)::text,chr(10) ORDER BY product_id)) AS hash FROM public.product_canonical_assignments a")).rows[0]};}
try{
 await create();result.restore=await restore();db=session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await baseline(db);result.all_archive_table_data='PASS_69_TABLES';
 await apply0012(db,freshBackup());await readPostflight(db);
 result.reconstituted_0012_from_latest_prewrite_backup=true;
 const before=await snap();result.baseline_counts=before.counts;
 const binary=run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);run(['cp','-',`${container}:/tmp`],binary);
 http=new HttpChecks(db);await http.start();const legacyBefore=await http.legacy();
 await db.exec("SET esnaftavar.w52kb.target_ref='mefhfvrgkwciubeajjeb';");
 await db.exec(migration.replace(/COMMIT;\s*$/,`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ('20260919001300','0013_production_canonical_private_preview',${literal([migration])}::text[]);\nCOMMIT;`));
 // Identity fixtures only, on the network-isolated copy. All catalog/product data
 // comes from the real archive. Remove these identities before the final 69-table comparison.
 const tester={role:'authenticated',sub:'00000000-0000-4000-8000-000000005301'},normal={role:'authenticated',sub:'00000000-0000-4000-8000-000000005302'};
 check((await db.query('SELECT count(*)::int AS n FROM auth.users WHERE id=ANY($1::uuid[])',[[tester.sub,normal.sub]])).rows[0].n===0,'TEST_IDENTITY_COLLISION');
 await db.exec(`INSERT INTO auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) VALUES
 (${literal(tester.sub)},'authenticated','authenticated','preview-a@local.invalid','{}','{}',now(),now()),
 (${literal(normal.sub)},'authenticated','authenticated','preview-b@local.invalid','{}','{}',now(),now());`);
 result.identity_fixtures='Two disposable local-only identities; no synthetic category/product data';
 await db.exec(`INSERT INTO production_preview_private.testers(user_id,enabled,expires_at) VALUES(${literal(tester.sub)},true,now()+interval '1 hour'); NOTIFY pgrst,'reload schema';`);
 await new Promise(r=>setTimeout(r,500));
 const params={p_client_contract_version:'taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'};
 const calls=['taxonomy_capabilities_v2','taxonomy_roots_v2','taxonomy_children_v2','taxonomy_descendants_v2','taxonomy_breadcrumb_v2','taxonomy_exact_leaf_v2','taxonomy_resolve_alias_v2','taxonomy_search_context_v2','production_preview_mappings_v1','production_preview_products_v1'];
 const root=(await db.query('SELECT id::text FROM public.canonical_categories WHERE parent_id IS NULL ORDER BY sort_order LIMIT 1')).rows[0].id;
 const leaf=(await db.query("SELECT c.id::text FROM public.canonical_categories c JOIN public.canonical_category_qualification q ON q.category_id=c.id WHERE c.level=4 AND q.qualification='LEAF_ASSIGNABLE_CANDIDATE' LIMIT 1")).rows[0].id;
 const args=name=>({...params,...(['taxonomy_capabilities_v2','production_preview_mappings_v1','production_preview_products_v1'].includes(name)?{}:{p_preview:true}),...(name==='taxonomy_children_v2'?{p_parent_id:root}:{}),...(['taxonomy_descendants_v2','taxonomy_breadcrumb_v2','taxonomy_exact_leaf_v2'].includes(name)?{p_category_id:name==='taxonomy_descendants_v2'?root:leaf}:{}),...(name==='taxonomy_resolve_alias_v2'?{p_alias_locator:'powerbank'}:{}),...(name==='taxonomy_search_context_v2'?{p_term:'Defterler'}:{})});
 for(const [label,identity] of [['anon',null],['normal',normal],['spoofed_metadata',{...normal,user_metadata:{preview:true},app_metadata:{preview:true}}]]){
  for(const name of calls){const r=request(identity,name,args(name));check([401,403].includes(r.status),'UNAUTHORIZED_RPC_'+label.toUpperCase());}
  result.failures.push({case:label+'_all_preview_rpcs',result:'PASS_DENIED',operations:calls.length});
 }
 const fixtures={};
 check(request(tester,'taxonomy_capabilities_v2',params,false).status===401,'INVALID_AUTH_SIGNATURE');
 result.failures.push({case:'invalid_auth_signature',result:'PASS_DENIED'});
 for(const name of calls){const r=request(tester,name,args(name));check(r.status===200,'AUTHORIZED_'+name.toUpperCase());fixtures[name]=r.body;}
 check(fixtures.taxonomy_capabilities_v2[0].preview_authorized===true&&fixtures.taxonomy_capabilities_v2[0].public_enabled===false,'CAPABILITY');
 check(fixtures.taxonomy_roots_v2.length===24,'ROOTS_24');
 const mapped=fixtures.production_preview_mappings_v1;check(mapped.length===20&&mapped.filter(m=>m.eligible).length===14,'MAPPINGS_POLICY_20_14_6');
 const exact=(await db.query('SELECT product_id::text,canonical_category_id::text,canonical_path FROM public.product_canonical_assignments ORDER BY product_id')).rows;
 check(stable(mapped.map(({product_id,canonical_category_id,canonical_path})=>({product_id,canonical_category_id,canonical_path})))===stable(exact),'EXACT_MAPPING_20');
 const products=fixtures.production_preview_products_v1;check(products.length===14&&products.every(p=>p.product.category_id===p.canonical_category_id&&p.product.legacy_category_id),'PRODUCT_SCOPE_14_POLICY_ELIGIBLE');
 check(request(tester,'production_preview_products_v1',{...params,p_sort_by:'rating',p_ascending:false}).status===200,'HOME_RATING_SORT');
 for(const mapping of mapped.filter(m=>m.eligible)){
  const scoped=request(tester,'production_preview_products_v1',{...params,p_category_id:mapping.canonical_category_id,p_exact_leaf:true});
  check(scoped.status===200&&scoped.body.some(p=>p.product_id===mapping.product_id)&&scoped.body.every(p=>p.canonical_category_id===mapping.canonical_category_id),'EXACT_LEAF_PRODUCT_SCOPE');
 }
 check(request(tester,'production_preview_products_v1',{...params,p_category_id:root,p_exact_leaf:true}).status>=400,'ROOT_CANNOT_BECOME_EXACT_LEAF');
 result.failures.push({case:'root_as_exact_leaf',result:'PASS_FAIL_CLOSED'});
 fixtures.browse_paths=[];
 for(const depth of [2,3,4]){
  const node=(await db.query('SELECT id::text,parent_id::text FROM public.canonical_categories WHERE level=$1 AND policy_class<>\'EXCLUDED\' LIMIT 1',[depth])).rows[0];
  const children=request(tester,'taxonomy_children_v2',{...params,p_parent_id:node.parent_id,p_preview:true});
  const breadcrumb=request(tester,'taxonomy_breadcrumb_v2',{...params,p_category_id:node.id,p_preview:true});
  check(children.status===200&&children.body.some(n=>n.id===node.id)&&breadcrumb.status===200&&breadcrumb.body.length===depth,'RECURSIVE_L'+depth);
  fixtures.browse_paths.push({depth,node_id:node.id,children:children.body,breadcrumb:breadcrumb.body});
 }
 check(fixtures.taxonomy_resolve_alias_v2.length===1&&fixtures.taxonomy_search_context_v2.length>0,'SEARCH_ALIAS');
 for(const mapping of mapped){
  const detail=request(tester,'production_preview_products_v1',{...params,p_product_id:mapping.product_id});
  check(detail.status===200&&detail.body.length===(mapping.eligible?1:0),'PRODUCT_DETAIL_POLICY');
 }
 const errorCases=[['wrong_contract','taxonomy_roots_v2',{...params,p_client_contract_version:'wrong',p_preview:true}],['public_request','taxonomy_roots_v2',{...params,p_preview:false}],['invalid_uuid','taxonomy_children_v2',{...params,p_parent_id:'not-a-uuid',p_preview:true}],['unknown_category','production_preview_products_v1',{...params,p_category_id:'00000000-0000-4000-8000-000000000000'}]];
 for(const [label,name,values]of errorCases){check(request(tester,name,values).status>=400,'EXPECTED_FAILURE_'+label.toUpperCase());result.failures.push({case:label,result:'PASS_FAIL_CLOSED'});}
 for(const state of ['revoked','expired']){
  await db.exec(state==='revoked'?`UPDATE production_preview_private.testers SET enabled=false;`:`UPDATE production_preview_private.testers SET enabled=true,granted_at=now()-interval '2 hours',expires_at=now()-interval '1 hour';`);
  check(request(tester,'taxonomy_capabilities_v2',params).status===403,'ALLOWLIST_'+state.toUpperCase());result.failures.push({case:state+'_tester',result:'PASS_DENIED'});
 }
 await db.exec("UPDATE production_preview_private.testers SET enabled=true,granted_at=now(),expires_at=now()+interval '1 hour';");
 await db.exec('BEGIN; DELETE FROM public.product_canonical_assignments WHERE product_id=(SELECT product_id FROM public.product_canonical_assignments LIMIT 1);');
 // Same-session check sees deliberately missing uncommitted mapping; never changes real data.
 await db.exec(`SET LOCAL ROLE authenticated; SELECT set_config('request.jwt.claims',${literal(JSON.stringify(tester))},true); DO $test$ BEGIN BEGIN PERFORM public.taxonomy_capabilities_v2('taxonomy-client-v1','canonical-v1.0.0'); RAISE EXCEPTION 'W52KB_EXPECTED_MISSING_MAPPING_FAILURE'; EXCEPTION WHEN raise_exception THEN IF SQLERRM<>'W52KB_MAPPING_INCOMPLETE' THEN RAISE; END IF; END; END $test$; ROLLBACK;`);
 result.failures.push({case:'missing_mapping',result:'PASS_FAIL_CLOSED'});
 await db.exec('BEGIN; UPDATE public.production_taxonomy_config SET public_enabled=true WHERE singleton_id=1;');
 await db.exec(`SET LOCAL ROLE authenticated; SELECT set_config('request.jwt.claims',${literal(JSON.stringify(tester))},true); DO $test$ BEGIN BEGIN PERFORM public.taxonomy_capabilities_v2('taxonomy-client-v1','canonical-v1.0.0'); RAISE EXCEPTION 'W52KB_EXPECTED_PUBLIC_ACTIVATION_FAILURE'; EXCEPTION WHEN raise_exception THEN IF SQLERRM<>'W52KB_PUBLIC_ACTIVATION_MUST_REMAIN_OFF' THEN RAISE; END IF; END; END $test$; ROLLBACK;`);
 result.failures.push({case:'public_activation_conflicts_with_private_preview',result:'PASS_FAIL_CLOSED'});
 const hidden=products[0].product_id;
 await db.exec(`CREATE POLICY w52kb_test_restrict_product ON public.products AS RESTRICTIVE FOR SELECT TO authenticated USING(id<>${literal(hidden)}::uuid);`);
 check(request(tester,'production_preview_products_v1',{...params,p_product_id:hidden}).body.length===0,'PRODUCT_RLS_PRESERVED');
 await db.exec('DROP POLICY w52kb_test_restrict_product ON public.products;');
 result.product_rls_restrictive_policy_probe='PASS';
 const grants=(await db.query("SELECT proname,prosecdef,provolatile,proconfig,has_function_privilege('anon',oid,'EXECUTE') AS anon_execute,has_function_privilege('authenticated',oid,'EXECUTE') AS authenticated_execute FROM pg_proc WHERE pronamespace='public'::regnamespace AND (proname LIKE '\\_w52kb\\_%' OR proname=ANY($1::text[])) ORDER BY proname",[calls])).rows;
 check(grants.length===15&&grants.every(f=>f.provolatile==='s'&&f.proconfig.includes('search_path=pg_catalog, public')&&!f.anon_execute&&f.authenticated_execute===!f.proname.startsWith('_')),'MINIMAL_STABLE_GRANTS');
 result.security={result:'PASS',functions:grants,private_allowlist_has_client_grants:(await db.query("SELECT has_table_privilege('authenticated','production_preview_private.testers','SELECT,INSERT,UPDATE,DELETE') OR has_table_privilege('anon','production_preview_private.testers','SELECT,INSERT,UPDATE,DELETE') AS exposed")).rows[0].exposed};
 check(result.security.private_allowlist_has_client_grants===false,'ALLOWLIST_PRIVATE');
 check(stable(await http.legacy())===stable(legacyBefore),'LEGACY_HTTP_UNCHANGED');
 for(const role of ['anon','authenticated'])await legacyQueries(db,role);
 check(stable(await legacyDataHashes(db))===stable(before.legacy),'LEGACY_ROWS_UNCHANGED');
 result.authorized_preview={roots:24,levels:[2,3,4],mappings:20,eligible_products:14,gated_products:6,search_alias:'PASS',product_details:'PASS',public_activation:false};
 // Private capture is consumed by a Flutter contract test; never committed.
 writeFileSync(resolve(proofDir,'real-copy-contract.json'),JSON.stringify(fixtures,null,2));
 await db.exec(rollback.replace(/COMMIT;\s*$/,`DELETE FROM supabase_migrations.schema_migrations WHERE version='20260919001300' AND name='0013_production_canonical_private_preview' AND statements=${literal([migration])}::text[];\nCOMMIT;`));
 await db.exec(`DELETE FROM auth.users WHERE id IN (${literal(tester.sub)},${literal(normal.sub)});`);
 const after=await snap();check(stable(before)===stable(after),'EXACT_0012_BASELINE_AFTER_PREVIEW_ROLLBACK');
 await readPostflight(db);await archiveRows(db,{preserve0012:true});check(stable(await http.legacy())===stable(legacyBefore),'LEGACY_HTTP_AFTER_ROLLBACK');
 await db.exec("NOTIFY pgrst,'reload schema';");await new Promise(r=>setTimeout(r,500));
 check(request(tester,'taxonomy_capabilities_v2',params).status===404,'BRIDGE_UNAVAILABLE_FAIL_CLOSED');
 result.failures.push({case:'bridge_unavailable_after_rollback',result:'PASS_FAIL_CLOSED'});
 result.rollback={result:'PASS',only_preview_bridge_removed:true,unchanged_0012_catalog_ledger_data:true,counts:after.counts};
 result.result='PASS';
}catch(error){result.safe_error=safeError(error);console.log(result.safe_error);process.exitCode=1;}
finally{
 result.completed_at_utc=new Date().toISOString();
 if(http)try{http.stop();}catch{} if(db)try{await db.close();}catch{} try{stop();}catch{}
 // Transport container ID is local ephemeral, omit it from public evidence.
 if(result.restore)delete result.restore.isolation;
 writeFileSync(resolve(proofDir,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,error:result.safe_error,authorized:result.authorized_preview,rollback:result.rollback?.result,failure_cases:result.failures.length}));
}
