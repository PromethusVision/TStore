import assert from 'node:assert/strict';
import {runPilotUi} from './pilot_ui.mjs';
try{
  assert(process.argv.length===4||(process.argv.length===5&&process.argv[4]==='repositories'));
  await runPilotUi({directory:process.argv[2],flutterPath:process.argv[3],repositories:process.argv[4]==='repositories',integrated:true});
}catch{
  console.error('INTEGRATED_PILOT_REFUSED: owned fresh local fixture and reviewed sources required; no remote fallback.');
  process.exitCode=1;
}
