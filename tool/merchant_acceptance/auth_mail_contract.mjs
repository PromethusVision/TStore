import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {root} from './local.mjs';

export const hash=text=>createHash('sha256').update(text.replace(/\r\n/g,'\n')).digest('hex');
export function templateContract(html){
 assert.match(html,/<html lang="tr">/);
 assert.equal((html.match(/{{\s*\.ConfirmationURL\s*}}/g)??[]).length,1);
 assert.deepEqual([...html.matchAll(/{{([^}]*)}}/g)].map(x=>x[1].trim()),['.ConfirmationURL']);
 assert.deepEqual([...html.matchAll(/href\s*=\s*"([^"]*)"/gi)].map(x=>x[1]),['{{ .ConfirmationURL }}']);
 assert(!/<(?:script|img|iframe|form|object|embed|link)\b|\bon\w+\s*=|url\s*\(|https?:\/\//i.test(html),'No trackers, executable content or external dependencies');
 assert.match(html,/telefonda/);assert.match(html,/paylaşmayın/);
}
export async function verifyMailProof(base=root){
 const proof=JSON.parse(await readFile(resolve(base,'docs/data/merchant_pilot_auth_mail_validation.json'),'utf8'));
 assert.equal(proof.kind,'merchant-auth-mail-local-v1');assert.equal(proof.result,'PASS');
 assert.equal(proof.remote_access,'NONE');assert.equal(proof.production_access,'NONE');assert.equal(proof.external_email_sent,false);
 assert(proof.checks.length>=16&&proof.checks.every(c=>c.result==='PASS'));
 assert.equal(new Set(proof.checks.map(c=>c.name)).size,proof.checks.length);
 const paths=proof.sources.map(s=>s.path);assert.equal(new Set(paths).size,paths.length);
 for(const required of ['lib/features/merchant/data/supabase_merchant_recovery_backend.dart','lib/features/merchant/domain/merchant_account_recovery.dart','lib/core/supabase/auth_callback_contract.dart','pubspec.lock','tool/merchant_acceptance/auth_mail.mjs','tool/merchant_acceptance/auth_mail_local.mjs','tool/merchant_acceptance/auth_mail_test.dart','supabase/templates/pilot/recovery.html','supabase/templates/pilot/confirmation.html'])assert(paths.includes(required));
 for(const source of proof.sources){
  assert(/^(lib\/|tool\/merchant_acceptance\/|supabase\/templates\/pilot\/|pubspec\.(yaml|lock)$)/.test(source.path));
  assert(!source.path.includes('..')&&!source.path.includes('\\')&&!source.path.includes(':'));
  assert.equal(hash(await readFile(resolve(base,source.path),'utf8')),source.sha256_lf,'Auth mail proof stale: '+source.path);
 }
 for(const flow of ['confirmation','recovery'])templateContract(await readFile(resolve(base,`supabase/templates/pilot/${flow}.html`),'utf8'));
 return proof;
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 try{const proof=await verifyMailProof();console.log(`AUTH_MAIL_PROOF_PASS: ${proof.checks.length} checkpoints; local evidence only. Hosted delivery and device acceptance remain OPEN.`);}
 catch{console.error('AUTH_MAIL_PROOF_INVALID_OR_STALE');process.exitCode=1;}
}
