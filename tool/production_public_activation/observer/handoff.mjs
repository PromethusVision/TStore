// Scheduling only. IO must invoke the unchanged sealed W52L-E executor/CLI.
// The real-copy rehearsal exercises this same handoff with the corrected observer.
export async function flow(io){
 const r={result:'STOPPED_BEFORE_WRITE',activation_invoked:false,production_write_performed:false,rollback_triggered:false,public_activation_performed:false,public_enabled_final:'UNKNOWN'};
 const save=()=>io.save(r);
 try{
  r.package=await io.gates();r.preflight=await io.observe('preflight');r.public_enabled_final=false;save();io.progress('SEALED_LIVE_PREFLIGHT: PASS');io.progress('LEGACY_HTTP_BASELINE: PASS');
  await io.gates();r.activation_invoked=true;save();
  r.activation=await io.cli('activate');r.production_write_performed=r.activation.production_write_attempted===true;
  r.public_activation_performed=r.activation.public_activation_performed;r.backup=await io.backupReceipt();save();
  if(r.backup)io.progress('FRESH_PREWRITE_BACKUP: PASS');
  if(r.activation.result!=='PASS'){
   r.safe_error=r.activation.safe_error;
   if(r.activation.result==='ROLLED_BACK_0014_ONLY'){r.rollback_triggered=true;r.rollback=r.activation.reconciliation;r.result='ROLLED_BACK';r.restored=await io.observe('baseline');await io.compare(r.preflight,r.restored,false);}
   else if(r.activation.result==='BASELINE_NO_WRITE'){r.result='STOPPED_BEFORE_WRITE';r.production_write_performed=false;r.atomic_failure_reconciled=true;r.restored=await io.observe('baseline');await io.compare(r.preflight,r.restored,false);}
   else if(r.production_write_performed){r.result='FAIL';r.public_enabled_final='UNKNOWN';}
   save();return r;
  }
  r.public_enabled_final=true;if(!r.backup)throw Error('W52LE_BACKUP_RECEIPT_MISSING');
  io.progress('ATOMIC_0014_AND_LEDGER: PASS');
  r.postflight=await io.observe('postflight');await io.compare(r.preflight,r.postflight,true);r.result='PASS';save();
  io.progress('PUBLIC_CANONICAL_AND_FACADE: PASS');io.progress('LEGACY_SECURITY_DATA_INTEGRITY: PASS');io.progress('PUBLIC_CUSTOMER_READS: PASS');
 }catch(e){
  r.safe_error=io.safeError(e);
  if(r.activation_invoked&&(!r.activation||r.production_write_performed)){
   try{
    const active=await io.cli('postflight');
    if(active.result==='PASS'){
     r.rollback_triggered=true;r.production_write_performed=true;r.public_activation_performed=true;r.rollback=await io.cli('rollback');
     if(r.rollback.result!=='PASS')throw Error('W52LE_REVIEWED_ROLLBACK_STOPPED');
     r.restored=await io.observe('baseline');await io.compare(r.preflight,r.restored,false);r.result='ROLLED_BACK';r.public_enabled_final=false;
    }else{
     r.restored=await io.observe('baseline');await io.compare(r.preflight,r.restored,false);
     r.result='STOPPED_WITH_BASELINE_RESTORED';r.public_enabled_final=false;
     // A lost child report cannot prove that no committed write ever occurred.
     if(!r.activation){r.production_write_performed='UNKNOWN';r.public_activation_performed='UNKNOWN';}
    }
   }catch(recovery){r.result='FAIL';r.public_enabled_final='UNKNOWN';r.recovery_error=io.safeError(recovery);}
  }
  save();
 }
 return r;
}
