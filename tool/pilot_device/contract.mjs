import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

export const project = 'tnipyxnvhgelwdpykyez';
export const endpoint = `https://${project}.supabase.co`;
export const rehearsalKey = 'sb_publishable_syntheticPilotOnly12345';
export const ownerCertificate = '3b83d98ab8d32e0f3b9930fa837636e0e9e13219784ffca39cef8cae82a6669b';
export const capabilities = ['QR_CLAIMS_V2_ENABLED', 'REWARD_EARNING_V1_ENABLED',
  'COUPON_CHECKOUT_V1_ENABLED', 'TRUST_COMMERCE_V1_ENABLED', 'REVIEWS_V2_ENABLED',
  'MERCHANT_STATEMENT_V1_ENABLED', 'MERCHANT_PROMOTION_V1_ENABLED', 'MERCHANT_PUSH_SCHEMA_LOCAL_ENABLED'];
export const applications = {
  customer: {flavor:'development', target:'lib/main_development.dart', id:'com.esnaftavar.app.dev',
    label:'EsnaftaVar Dev', callback:'io.supabase.tstore'},
  merchant: {flavor:'merchantPilot', target:'lib/main_merchant_pilot.dart', id:'com.esnaftavar.app.merchant.pilot',
    label:'EsnaftaVar Esnaf Pilot', callback:'com.esnaftavar.app.merchant.pilot'},
};
export const sha = bytes => createHash('sha256').update(bytes).digest('hex');
export const json = value => JSON.stringify(value, null, 2)+'\n';
export const slug = value => typeof value === 'string' && /^[a-z][a-z0-9-]{2,60}$/.test(value);
export const digestPattern = /^[a-f0-9]{64}$/;

export function scanPayload(bytes,key) {
  assert(Buffer.isBuffer(bytes)&&bytes.length>0&&typeof key==='string'&&key.length>10);
  return {backend_url_present:bytes.includes(Buffer.from(endpoint)),
    supplied_client_key_present:bytes.includes(Buffer.from(key)),
    catalog_price_marker_present:bytes.includes(Buffer.from('_catalog_price_contract')),
    scan_scope:'REQUIRED_LITERALS_ONLY_NOT_BEHAVIOR_OR_SECRET_PROOF'};
}

// The external input is flat and string-only. Reject duplicates, including
// escaped spellings, before JSON.parse can discard the first value.
export function parseInput(text) {
  assert.equal(typeof text, 'string'); assert(text.length <= 16000);
  const value = JSON.parse(text); assert(value && !Array.isArray(value) && typeof value === 'object');
  const token = /\s*"((?:[^"\\\x00-\x1f]|\\(?:["\\/bfnrt]|u[0-9a-fA-F]{4}))*)"\s*:\s*"((?:[^"\\\x00-\x1f]|\\(?:["\\/bfnrt]|u[0-9a-fA-F]{4}))*)"\s*/y;
  const body = text.trim(); assert(body.startsWith('{') && body.endsWith('}'));
  let offset=1; const keys=new Set();
  while (offset<body.length-1) {
    token.lastIndex=offset; const match=token.exec(body); assert(match);
    const key=JSON.parse('"'+match[1]+'"'); assert(!keys.has(key)); keys.add(key);
    offset=token.lastIndex; if(body[offset]===',') { offset++; assert(body.slice(offset,-1).trim()); } else break;
  }
  assert.equal(body.slice(offset).trim(), '}');
  assert.deepEqual([...keys].sort(), ['MERCHANT_PILOT_ANON_KEY','MERCHANT_PILOT_ENABLED','MERCHANT_PILOT_URL']);
  assert(Object.values(value).every(v=>typeof v==='string'));
  assert.equal(value.MERCHANT_PILOT_ENABLED,'true'); assert.equal(value.MERCHANT_PILOT_URL,endpoint);
  const key=value.MERCHANT_PILOT_ANON_KEY;
  assert.equal(key,key.trim()); assert(key.length<8000);
  assert(!/sb_secret_|service_role|placeholder|example|dummy|change_?me|replace|your[_-]|[<>]/i.test(key));
  if (!/^sb_publishable_[A-Za-z0-9_-]{12,}$/.test(key)) {
    assert(/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(key));
    const claims=JSON.parse(Buffer.from(key.split('.')[1],'base64url').toString());
    assert.equal(claims.role,'anon'); assert.equal(claims.ref,project);
  }
  return value;
}

export function pairDefines(input) {
  parseInput(json(input));
  const disabled=Object.fromEntries(capabilities.map(k=>[k,'false']));
  return {
    customer:{SUPABASE_DEVELOPMENT_URL:endpoint, SUPABASE_DEVELOPMENT_ANON_KEY:input.MERCHANT_PILOT_ANON_KEY,
      ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY:'false', ...disabled},
    merchant:{...input,...disabled},
  };
}

// Parse only Android SDK aapt's indentation tree; never accept a source manifest
// as evidence of the packaged binary.
export function xmlTree(text) {
  const root={name:'root',attributes:{},children:[]}; const stack=[{indent:-1,node:root}];
  for(const line of text.split(/\r?\n/)) {
    const element=/^(\s*)E: ([^\s(]+)/.exec(line);
    if(element) {
      const indent=element[1].length;
      while(stack.at(-1).indent>=indent)stack.pop();
      const node={name:element[2],attributes:{},children:[]}; stack.at(-1).node.children.push(node); stack.push({indent,node});
    } else {
      const attr=/^\s*A: ([^\s=(]+)(?:\([^)]*\))?=(.*)$/.exec(line);
      if(attr) { assert(!Object.hasOwn(stack.at(-1).node.attributes,attr[1])); stack.at(-1).node.attributes[attr[1]]=attr[2]; }
    }
  }
  return root;
}
const literal=v=>typeof v==='string' ? /^"([^"]*)"/.exec(v)?.[1] : undefined;
const bool=(v,expected)=>v === `(type 0x12)0x${expected?'ffffffff':'0'}` || v === String(expected);
const descendants=(node,name)=>node.children.flatMap(n=>[...(n.name===name?[n]:[]),...descendants(n,name)]);

export function inspectMetadata(role, mode, badging, treeText, signing) {
  assert(Object.hasOwn(applications,role)); assert(['debug','release'].includes(mode));
  const expected=applications[role];
  const pack=/^package: name='([^']+)' versionCode='([0-9]+)' versionName='([^']+)'/m.exec(badging); assert(pack);
  assert.equal(pack[1],expected.id); assert.equal(/^application-label:'([^']+)'/m.exec(badging)?.[1],expected.label);
  assert.match(badging,/native-code:.*'arm64-v8a'/);
  const tree=xmlTree(treeText), manifest=descendants(tree,'manifest'); assert.equal(manifest.length,1);
  assert.equal(literal(manifest[0].attributes.package),expected.id);
  const apps=descendants(tree,'application'); assert.equal(apps.length,1); const app=apps[0];
  assert(bool(app.attributes['android:allowBackup'],false));
  assert(bool(app.attributes['android:usesCleartextTraffic'],false));
  if(mode==='release')assert(app.attributes['android:debuggable']===undefined||bool(app.attributes['android:debuggable'],false));
  const debuggable=bool(app.attributes['android:debuggable'],true);
  assert.equal(debuggable,mode==='debug');
  const main=descendants(app,'activity').filter(a=>literal(a.attributes['android:name'])==='com.esnaftavar.app.MainActivity');
  assert.equal(main.length,1);assert(bool(main[0].attributes['android:exported'],true));
  const deepLink=main[0].children.filter(n=>n.name==='meta-data'&&literal(n.attributes['android:name'])==='flutter_deeplinking_enabled');
  assert.equal(deepLink.length,1);assert(bool(deepLink[0].attributes['android:value'],false));
  const viewFilters=descendants(tree,'intent-filter').filter(f=>f.children.some(n=>n.name==='action'&&literal(n.attributes['android:name'])==='android.intent.action.VIEW'));
  assert.equal(viewFilters.length,1);
  const filter=viewFilters[0];
  assert(main[0].children.includes(filter));
  assert.deepEqual(filter.children.filter(n=>n.name==='category').map(n=>literal(n.attributes['android:name'])).sort(),
    ['android.intent.category.BROWSABLE','android.intent.category.DEFAULT']);
  const data=filter.children.filter(n=>n.name==='data'); assert.equal(data.length,1);
  assert.deepEqual(Object.keys(data[0].attributes).sort(),['android:host','android:scheme']);
  assert.equal(literal(data[0].attributes['android:scheme']),expected.callback);
  assert.equal(literal(data[0].attributes['android:host']),'login-callback');
  const permissions=descendants(tree,'uses-permission').map(n=>literal(n.attributes['android:name']));
  for(const permission of ['INTERNET','CAMERA','ACCESS_COARSE_LOCATION','ACCESS_FINE_LOCATION']) assert(permissions.includes('android.permission.'+permission));
  const certificates=[...signing.matchAll(/^Signer #\d+ certificate SHA-256 digest: ([a-fA-F0-9]{64})\r?$/gm)].map(m=>m[1].toLowerCase());
  assert.equal(certificates.length,1); assert.match(signing,/^Verifies\r?$/m);
  if(mode==='release')assert.equal(certificates[0],ownerCertificate);
  return {role,application_id:pack[1],label:expected.label,callback:`${expected.callback}://login-callback/`,
    version_code:Number(pack[2]),version_name:pack[3],debuggable,certificate_sha256:certificates[0],mode,abi:'arm64-v8a'};
}

export const fieldCases = [
  ['access','merchant_login'],['access','wrong_role_denied'],['access','recovery_mail_and_callback'],
  ['access','account_switch_and_restart'],['catalog','onboarding_and_profile'],['catalog','listing_price_availability'],
  ['catalog','photo_and_customer_visibility'],['catalog','catalog_zero_not_offer'],['purchase','two_device_qr'],
  ['purchase','wrong_shop_expired_replay'],['purchase','slow_network_reconciliation'],['purchase','private_history_and_inbox'],
];
export function fieldTemplate(bundle) {
  return {kind:'esnaftavar-pilot-device-observation-v1',bundle_id:bundle.bundle_id,project_ref:project,
    artifacts:Object.fromEntries(bundle.artifacts.map(a=>[a.role,a.sha256])),
    device_aliases:{customer:null,merchant:null},cases:fieldCases.map(([group,id])=>({group,id,result:'OPEN',observed_at:null,evidence_sha256:null})),
    real_mail:'OPEN',provider_delivery:'OPEN',support_owner:'OPEN',withdrawal_runbook:'OPEN',owner_opening:'OPEN'};
}
export function assessField(bundle,observation) {
  const template=fieldTemplate(bundle);
  assert.deepEqual(Object.keys(observation).sort(),Object.keys(template).sort());
  assert.equal(observation.kind,template.kind); assert.equal(observation.bundle_id,bundle.bundle_id);
  assert.equal(observation.project_ref,project); assert.deepEqual(observation.artifacts,template.artifacts);
  assert.deepEqual(Object.keys(observation.device_aliases).sort(),['customer','merchant']);
  for(const value of Object.values(observation.device_aliases)) assert(value===null||/^(customer|merchant)-device-[1-9][0-9]?$/.test(value));
  assert.equal(observation.cases.length,fieldCases.length);
  observation.cases.forEach((c,i)=>{
    assert.deepEqual(Object.keys(c).sort(),Object.keys(template.cases[i]).sort());
    assert.equal(c.id,fieldCases[i][1]);assert.equal(c.group,fieldCases[i][0]);
    assert(['OPEN','PASS','FAIL'].includes(c.result));
    if(c.result==='OPEN'){assert.equal(c.observed_at,null);assert.equal(c.evidence_sha256,null);}
    else {assert(digestPattern.test(c.evidence_sha256));assert(/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/.test(c.observed_at));
      assert(Number.isFinite(Date.parse(c.observed_at)));assert(Date.parse(c.observed_at)>=Date.parse(bundle.created_at));
      assert(Date.parse(c.observed_at)<=Date.now());assert(Object.values(observation.device_aliases).every(Boolean));}
  });
  for(const key of ['real_mail','provider_delivery','support_owner','withdrawal_runbook','owner_opening']) assert.equal(observation[key],'OPEN');
  // Human observations are review material. They cannot certify provider, legal,
  // owner authorization, or final release, even with twelve supplied PASS rows.
  return {kind:'esnaftavar-pilot-field-review-v1',bundle_id:bundle.bundle_id,
    observed_pass:observation.cases.filter(c=>c.result==='PASS').length,
    observed_fail:observation.cases.filter(c=>c.result==='FAIL').length,
    observed_open:observation.cases.filter(c=>c.result==='OPEN').length,
    evidence_class:'MANUAL_REPORTED_NOT_INDEPENDENTLY_VERIFIED',
    compile_rehearsal:bundle.purpose==='compile-rehearsal',pilot_ready:false,remote_authorized:false,
    owner_opening:'OPEN',provider_delivery:'OPEN',signed_distribution:bundle.mode==='release'?'ARTIFACT_ONLY':'OPEN'};
}
