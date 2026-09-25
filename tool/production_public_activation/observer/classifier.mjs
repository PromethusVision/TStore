// Supplemental observer only; independent of the frozen 58-input executor seal.
export const check=(ok,code)=>{if(!ok)throw Error('W52LF_'+code);};
export const expectedState={preflight:false,postflight:true,baseline:false};
export function authoritative(rows,mode){
 check(Object.hasOwn(expectedState,mode),'OBSERVATION_MODE');
 check(rows.length===1&&typeof rows[0].public_enabled==='boolean'&&rows[0].preview_enabled===false,'AUTHORITATIVE_CONFIG');
 const active=rows[0].public_enabled;
 check(active===expectedState[mode],'UNEXPECTED_ACTIVATION_STATE');
 return active;
}
export function classify(active,row){
 check(typeof active==='boolean','BOOLEAN_ACTIVATION_STATE');
 check(row.total===20&&row.eligible===14&&row.gated===6,'STATE_ELIGIBILITY_14_6');
 check(row.public_visible===(active?14:0),'STATE_PUBLIC_VISIBILITY');
 check(row.roots===(active?24:0)&&row.published===(active?325:0)&&row.leaves===(active?247:0),'STATE_PUBLIC_TAXONOMY');
 check(row.activation_entries===(active?1:0),'STATE_LEDGER');
 return {result:'PASS',public_enabled:active,classifier:active?'PUBLIC_VISIBILITY_AND_ASSIGNABILITY':'STAGED_PRIVATE_PREVIEW_ELIGIBILITY',...row};
}
