import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {digest,schemaExpression,validateBaseline} from './pilot_preparation_contract.mjs';

export const profileSha='57ac9101d04a10cfbfdf3014377b0e8ed5fc6ef3eb4ca6cb3efae094c8fe1735';
export const hostedSchemaMd5='d4cb86def9cc856135f09ab83588b83c';
const textFixes=[['Bir kullanÄ±cÄ±','Bir kullanıcı'],['Yeni mesajÄ±n var','Yeni mesajın var'],['%s sana yeni bir mesaj gÃ¶nderdi.','%s sana yeni bir mesaj gönderdi.'],['MaÄŸaza','Mağaza'],['AlÄ±ÅŸveriÅŸin onaylandÄ±','Alışverişin onaylandı'],['%s alÄ±ÅŸveriÅŸini onayladÄ±.','%s alışverişini onayladı.']];
const roles=['anon','authenticated','service_role'];
const signaturePattern=/^[a-z_][a-z0-9_]*\((?:[a-z]+(?:\[\])?(?:,[a-z]+(?:\[\])?)*)?\)$/;
const lf=text=>text.replaceAll('\r\n','\n');

export function validateObservedFunction(signature,observed,local) {
  assert(signaturePattern.test(signature));
  if(signature==='rls_auto_enable()') {
    assert.equal(local,undefined);assert.equal(digest(observed,'md5'),'6998ea6b4c2480f5d2e34b5dcf3f8d36');return;
  }
  assert(local,'Unexpected hosted function');let normalized=lf(observed);
  if(['create_chat_message_notification()','create_verified_purchase_notification()'].includes(signature)) {
    for(const [bad,good] of textFixes) normalized=normalized.replaceAll(bad,good);
  }
  assert.equal(normalized,lf(local),'Hosted function differs beyond reviewed newline/text changes');
}

// LOCAL FIXTURE ONLY. This reproduces a pinned read-only observation so the
// candidate can be rehearsed without widening the hosted project's permissions.
// The main runner also verifies Docker labels, loopback bindings and ownership.
export async function mirrorHostedProfile(db) {
  assert.equal(db.connectionParameters.host,'127.0.0.1');
  assert.equal(Number(db.connectionParameters.port),55432);
  const bytes=await readFile(fileURLToPath(new URL('../../docs/data/merchant_pilot_hosted_profile.json',import.meta.url)),'utf8');
  assert.equal(digest(lf(bytes)),profileSha,'Pinned hosted observation changed');
  const profile=JSON.parse(bytes);validateBaseline(JSON.stringify(profile.schema));
  const raw=await db.query('SELECT p.oid::regprocedure::text signature,pg_get_functiondef(p.oid) definition FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname=$1 AND p.prokind=$2 AND NOT EXISTS(SELECT 1 FROM pg_depend d WHERE d.classid=$3::regclass AND d.objid=p.oid AND d.deptype=$4)',['public','f','pg_proc','e']);
  const local=new Map(raw.rows.map(r=>[r.signature,r.definition]));
  assert.equal(local.size,49);assert.equal(Object.keys(profile.function_definitions).length,50);
  // Validate EVERY executable definition against current tracked migration
  // output before executing any copied statement. Unknown changes fail closed.
  for(const [name,definition] of Object.entries(profile.function_definitions)) validateObservedFunction(name,definition,local.get(name));
  await db.query('BEGIN');
  try {
    for(const definition of Object.values(profile.function_definitions)) await db.query(definition+';');
    for(const f of profile.schema.functions) {
      assert(signaturePattern.test(f.signature));
      for(const role of roles) {
        const current=(await db.query('SELECT has_function_privilege($1,$2,\'EXECUTE\') allowed',[role,'public.'+f.signature])).rows[0].allowed;
        if(current!==f[role]) await db.query(`${f[role]?'GRANT':'REVOKE'} EXECUTE ON FUNCTION public.${f.signature} ${f[role]?'TO':'FROM'} ${role}`);
      }
    }
    for(const p of profile.schema.table_privileges) {
      assert(/^[a-z_][a-z0-9_]*$/.test(p.table));assert(roles.includes(p.role));
      assert(['SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER','MAINTAIN'].includes(p.privilege));
      const current=(await db.query('SELECT has_table_privilege($1,$2,$3) allowed',[p.role,'public.'+p.table,p.privilege])).rows[0].allowed;
      if(current!==p.allowed) await db.query(`${p.allowed?'GRANT':'REVOKE'} ${p.privilege} ON public.${p.table} ${p.allowed?'TO':'FROM'} ${p.role}`);
    }
    for(const kind of ['TABLES','SEQUENCES','FUNCTIONS']) await db.query(`ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON ${kind} FROM PUBLIC,anon,authenticated,service_role`);
    await db.query('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT TRUNCATE,REFERENCES,TRIGGER,MAINTAIN ON TABLES TO anon,authenticated,service_role');
    await db.query("CREATE EVENT TRIGGER ensure_rls ON ddl_command_end WHEN TAG IN ('CREATE TABLE','CREATE TABLE AS','SELECT INTO') EXECUTE FUNCTION public.rls_auto_enable()");
    const actual=(await db.query(`SELECT (${schemaExpression})::text value`)).rows[0].value;
    assert.deepEqual(JSON.parse(actual),profile.schema,'Local hosted-profile mirror mismatch');
    assert.equal(digest(actual,'md5'),hostedSchemaMd5,'Captured hosted schema changed');
    await db.query('COMMIT');return {sha256_lf:profileSha,schema_md5:hostedSchemaMd5,scope:'LOCAL mirror of read-only Development metadata; no hosted execution'};
  } catch(error) {await db.query('ROLLBACK');throw error;}
}
