import {writeFileSync,mkdirSync} from 'node:fs';
import {resolve,relative,isAbsolute,sep} from 'node:path';
import {bootstrap,fixtures,removeFixtures,startHttp,httpRequest,reload,stop,freshBackup,latestBackupHash,archiveRows} from './local-support.mjs';
import {root,hash,read,stable,check,safeError,directory,facade} from './common.mjs';
import {verify} from './seal.mjs';
import {readPreflight,deploy,readPostflight,rollback,readRollbackValidation} from './engine.mjs';
import {beforeTests,afterTests,expectFailure} from './failure-tests.mjs';
import {snapshot,canonicalData} from './catalog.mjs';
import {ledger,legacyDataHashes} from '../../production_taxonomy/execution/catalog.mjs';
import {params,rpcArguments} from './rpc-checks.mjs';
const output=process.env.W52KBX_PROOF_DIR,rel=relative(root,output??root);
check(isAbsolute(output??'')&&(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel)),'BX_PROOF_OUTSIDE_REPO');mkdirSync(output,{recursive:true});
const packageHash=process.env.W52KBX_PACKAGE_SHA256;
let db,http;
const result={format:'w52k-bx-real-copy-proof-v1',result:'FAIL',package_sha256:packageHash,source_backup_sha256:latestBackupHash,production_accessed:false,production_write_performed:false,development_accessed:false,failures:[]};
try{
 result.seal_before=verify(packageHash);
 ({db}=await bootstrap());result.restored_table_data=69;result.reconstituted_0012_from_prewrite_archive=true;console.log('BX_RESTORE_AND_0012_BASELINE: PASS');
 const before={schema:await snapshot(db),canonical:await canonicalData(db),ledger:await ledger(db),legacy:await legacyDataHashes(db)};
 const {ids,plan}=await fixtures(db);http=await startHttp(db);const legacyBefore=await http.legacy();
 let backup=freshBackup();await beforeTests(db,packageHash,plan,backup,result.failures);console.log('BX_PREWRITE_FAILURE_TESTS: PASS');
 result.preflight=await readPreflight(db,packageHash,plan);
 backup=freshBackup();const applied=await deploy(db,packageHash,plan,backup);result.deployment={result:applied.result,transaction:applied.transaction,payload_sha256:applied.payload_sha256,atomic:applied.atomic};
 result.postflight=await readPostflight(db,packageHash,plan);console.log('BX_ATOMIC_DEPLOY_AND_POSTFLIGHT: PASS');await reload(db);
 const args=await rpcArguments(db);
 for(const fn of facade){
  const values={...params,...args(fn)};
  check(httpRequest(http,ids[0],fn,values).status===200,'BX_HTTP_AUTHORIZED');
  check([401,403].includes(httpRequest(http,ids[1],fn,values).status),'BX_HTTP_NORMAL_DENIED');
  check([401,403].includes(httpRequest(http,null,fn,values).status),'BX_HTTP_ANON_DENIED');
 }
 check(httpRequest(http,ids[0],'taxonomy_capabilities_v2',params,false).status===401,'BX_HTTP_SIGNATURE');
 result.http={authorized_rpcs:10,normal_denied:10,anon_denied:10,invalid_signature_denied:true};
 check(stable(await http.legacy())===stable(legacyBefore),'BX_LEGACY_HTTP_AFTER_DEPLOY');
 await afterTests(db,packageHash,plan,backup,result.failures);
 result.rollback=await rollback(db,packageHash);result.rollback_validation=await readRollbackValidation(db,packageHash);
 await expectFailure('rollback_twice',()=>rollback(db,packageHash),result.failures);
 await removeFixtures(db,ids);await archiveRows(db,{preserve0012:true});
 check(stable(before)===stable({schema:await snapshot(db),canonical:await canonicalData(db),ledger:await ledger(db),legacy:await legacyDataHashes(db)}),'BX_EXACT_BASELINE_RESTORED');
 check(stable(await http.legacy())===stable(legacyBefore),'BX_LEGACY_HTTP_AFTER_ROLLBACK');await reload(db);
 check(httpRequest(http,ids[0],'taxonomy_capabilities_v2',params).status===404,'BX_BRIDGE_GONE');
 result.seal_after=verify(packageHash);result.result='PASS';
}catch(error){result.safe_error=safeError(error);process.exitCode=1;}
finally{
 if(http)try{http.stop();}catch{}if(db)try{await db.close();}catch{}try{stop();}catch{}
 // No subject IDs, tokens, emails, dumps, SQL row bodies or user paths.
 if(result.preflight?.target)delete result.preflight.target;
 if(result.postflight?.target)delete result.postflight.target;
 if(result.rollback?.target)delete result.rollback.target;
 if(result.rollback_validation?.target)delete result.rollback_validation.target;
 writeFileSync(resolve(output,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,error:result.safe_error,failure_cases:result.failures.length,package_sha256:packageHash}));
}
