import assert from 'node:assert/strict';
import { readRun, credentials, runtimeEvidence } from './local.mjs';
import { localUrl } from './safety.mjs';
import { connect } from './fixture.mjs';

// A server worker, never imported into either Flutter application. This runner
// accepts only this harness's owned, loopback-only local stack. Deployment and
// an external scheduler/least-privilege operator remain a separate release gate.
assert(process.argv[2], 'Prepared owned local run required');
assert(['--once','--watch'].includes(process.argv[3]), 'Choose --once or --watch');
let stopping=false, db;
process.on('SIGINT',()=>{stopping=true;}); process.on('SIGTERM',()=>{stopping=true;});
try {
  const run=await readRun(process.argv[2]); await runtimeEvidence(run);
  const status=await credentials(run),url=localUrl(status.DB_URL,'db');
  db=await connect({host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false});
  do {
    let processed=0, transitions=0;
    for(let batch=0;batch<20 && !stopping;batch++) {
      const r=(await db.query('SELECT public.process_badge_refresh_v1(100) result')).rows[0].result;
      processed+=r.processed??0;transitions+=r.transitions??0;
      if(!r.enabled || r.busy || r.processed===0 || r.pending_events===0) break;
    }
    console.log(JSON.stringify({status:'PASS',processed,transitions}));
    if(process.argv[3]==='--once') break;
    // Short intervals let shutdown terminate promptly; each minute checks expiry
    // even with no purchases, reviews or application screen reads.
    for(let i=0;i<60 && !stopping;i++) await new Promise(r=>setTimeout(r,1000));
  }while(!stopping);
}catch(e){console.error(`BADGE_WORKER_FAILED: ${e.code||e.name}; no remote fallback.`);process.exitCode=1;}
finally{if(db) await db.end();}
