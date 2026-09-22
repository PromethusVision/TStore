import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {check,read,json,hash,stable,root,directory,migration,activationSeal} from './common.mjs';
import {verify as verifyActivation} from '../production_public_activation/seal.mjs';
const files=[migration,...['common.mjs','executor.mjs','rollback.sql','function-oracle.json','seal.mjs'].map(f=>directory+'/'+f)];
const manifest=()=>({format:'w52lb-public-facade-local-readiness-v1',live_write_enabled:false,activation_package_sha256:activationSeal,inputs:files.map(path=>({path,sha256:hash(read(path))}))});
export function verify(expected){
 verifyActivation(activationSeal);const actual=manifest(),saved=json(directory+'/seal.json');
 check(stable(actual)===stable(saved.manifest)&&saved.sha256===hash(stable(actual))&&expected===saved.sha256,'PACKAGE_SEAL');
 return {result:'PASS',sha256:expected,inputs:files.length,live_write_enabled:false};
}
if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 verifyActivation(activationSeal);const value=manifest();writeFileSync(resolve(root,directory,'seal.json'),JSON.stringify({manifest:value,sha256:hash(stable(value))},null,2)+'\n');console.log('W52LB_PACKAGE_SEALED');
}
