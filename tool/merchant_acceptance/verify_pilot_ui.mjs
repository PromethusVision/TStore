import {verifyUiProof} from './pilot_ui_contract.mjs';
import {root} from './local.mjs';

try {
  const proof=await verifyUiProof(root);
  console.log('PILOT_UI_PROOF_CURRENT: '+proof.checks.length+' local screen checkpoints; hosted/device/pilot gates remain OPEN.');
} catch {
  console.error('PILOT_UI_PROOF_MISSING_OR_STALE: no acceptance or remote authority inferred.');
  process.exitCode=1;
}
