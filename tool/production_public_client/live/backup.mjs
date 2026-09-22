import {check,project} from './common.mjs';
import {validateBackup} from '../../production_taxonomy/execution/common.mjs';
const receipts=new WeakSet();
// Only verified bytes from the caller's trusted dump/restore transport can issue
// a receipt. CLI never accepts an externally asserted "verified:true" object.
export function issueBackup({metadata,bytes,tocVerified},baselineFingerprint){
 check(tocVerified===true,'BACKUP_TOC_REQUIRED');
 const valid=validateBackup(metadata,bytes);
 check(/^[a-f0-9]{64}$/.test(baselineFingerprint??''),'BACKUP_BASELINE_REQUIRED');
 const receipt=Object.freeze({...valid,baseline_fingerprint:baselineFingerprint});receipts.add(receipt);return receipt;
}
export function requireBackup(receipt,fingerprint,now=Date.now()){
 check(receipts.has(receipt)&&receipt.project_ref===project,'VERIFIED_FRESH_BACKUP_REQUIRED');
 const age=now-Date.parse(receipt.completed_at_utc);
 check(Number.isFinite(age)&&age>=-30000&&age<=900000,'BACKUP_EXPIRED');
 check(receipt.baseline_fingerprint===fingerprint,'BACKUP_BASELINE_CHANGED');
 return {sha256:receipt.sha256,size_bytes:receipt.size_bytes,completed_at_utc:receipt.completed_at_utc,baseline_fingerprint:fingerprint};
}
