import {readFileSync} from 'node:fs';
import {check,json,directory,hash} from './common.mjs';
import {externalPath} from '../../production_public_client/live/production.mjs';
export function artifactGate(options){
 const expected=json(directory+'/artifact-contract.json');
 check(expected.package==='com.esnaftavar.app'&&expected.version_name==='1.0.0'&&expected.version_code===3&&expected.runtime==='PRODUCTION_PUBLIC_CANONICAL'&&expected.public_define===true&&expected.preview_define===false,'FROZEN_PUBLIC_CONTRACT');
 for(const kind of ['apk','aab']){
  check(typeof options?.[kind]==='string','FROZEN_ARTIFACT_PATH_REQUIRED');
  const bytes=readFileSync(externalPath(options[kind]));
  check(hash(bytes)===expected[kind].sha256&&bytes.length===expected[kind].size_bytes,'FROZEN_'+kind.toUpperCase()+'_HASH');
 }
 return {result:'PASS',package:expected.package,version:'1.0.0+3',runtime:expected.runtime,apk_sha256:expected.apk.sha256,aab_sha256:expected.aab.sha256};
}
export function physicalGate(db){
 const proof=json(directory+'/physical-public-off.json'),artifact=json(directory+'/artifact-contract.json');
 if(db.transport.kind==='ISOLATED_REAL_BACKUP_RESTORE')return {result:'LOCAL_REHEARSAL_ONLY',live_authorization:false};
 check(proof.result==='PASS'&&proof.apk_sha256===artifact.apk.sha256&&proof.version_code===3&&proof.install_upgrade==='PASS'&&proof.controlled_unavailable==='PASS'&&proof.no_fallback==='PASS'&&proof.crash===false&&proof.anr===false,'PHYSICAL_PUBLIC_OFF_REQUIRED');
 return {result:'PASS',apk_sha256:proof.apk_sha256,observed_utc:proof.observed_utc};
}
