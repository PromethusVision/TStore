import {deliverExistingNotification} from './push_delivery.mjs';

const projectUrl = 'https://tnipyxnvhgelwdpykyez.supabase.co';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Every RPC request is its own committed READ COMMITTED PostgREST transaction.
// No retry middleware. No transaction spans a provider request.
export class DevelopmentRpcPushStore {
  constructor({url, serviceKey, fetchImpl = fetch}) {
    if (url !== projectUrl || typeof serviceKey !== 'string' || !serviceKey) {
      throw new Error('development_push_backend_denied');
    }
    this.fetch = fetchImpl;
    this.serviceKey = serviceKey;
  }
  async request(path, body) {
    try {
      const response = await this.fetch(`${projectUrl}/rest/v1/${path}`, {
        method:body === undefined ? 'GET':'POST', redirect:'error',
        signal:AbortSignal.timeout(15000),
        headers:{apikey:this.serviceKey, Authorization:`Bearer ${this.serviceKey}`,
          'Content-Type':'application/json'},
        ...(body === undefined ? {} : {body:JSON.stringify(body)}),
      });
      if (!response.ok) throw new Error();
      return await response.json();
    } catch { throw new Error('push_store_unavailable'); }
  }
  page(id,after=null) {return this.request('rpc/push_dispatch_page_i0',{p_notification_id:id,p_after:after});}
  claim(id,installation) {return this.request('rpc/claim_push_dispatch_i0',{p_notification_id:id,p_installation_id:installation});}
  begin(id) {return this.request('rpc/begin_push_dispatch_i0',{p_claim_id:id});}
  finish(id,outcome,invalid=false) {return this.request('rpc/finish_push_dispatch_i0',
    {p_claim_id:id,p_outcome:outcome,p_token_unregistered:invalid});}
  async notification(id) {
    if (!uuid.test(id)) return null;
    return this.request('rpc/read_push_notification_development_v1',{p_notification_id:id});
  }
}

/** @param {{enabled?:boolean, secret?:string, recipients?:string[], notBefore?:string,
 * store?:any, provider?:any, cryptoImpl?:Crypto, now?:()=>number}} options */
export function createDevelopmentPushWorker({enabled=false, secret, recipients=[], notBefore,
  store, provider, cryptoImpl=crypto, now=()=>Date.now()}) {
  // Small explicit cohort; a typo/empty scope never means every user or history.
  const ready = enabled === true && /^[a-f0-9]{64,128}$/i.test(secret ?? '') &&
    Array.isArray(recipients) && recipients.length > 0 && recipients.length <= 10 &&
    recipients.every(id => typeof id === 'string' && uuid.test(id)) &&
    typeof notBefore === 'string' && Number.isFinite(Date.parse(notBefore));
  const encoder = new TextEncoder();
  const reply = (status, value) => new Response(JSON.stringify(value), {
    status, headers:{'Content-Type':'application/json','Cache-Control':'no-store'},
  });
  return async request => {
    if (!ready) return reply(503,{status:'pending_configuration'});
    if (request.method !== 'POST') return reply(405,{status:'method_denied'});
    const supplied = request.headers.get('Authorization') ?? '';
    if (supplied.length > 160) return reply(401,{status:'unauthorized'});
    const hashes = await Promise.all([supplied,`Bearer ${secret}`].map(value =>
      cryptoImpl.subtle.digest('SHA-256',encoder.encode(value))));
    const a = new Uint8Array(hashes[0]), b = new Uint8Array(hashes[1]);
    let mismatch = 0;
    for (let i=0; i<a.length; i++) mismatch |= a[i]^b[i];
    if (mismatch) return reply(401,{status:'unauthorized'});
    try {
      // Database webhook envelope; all supplied record fields except the UUID
      // are ignored. Only the current server row decides scope and eligibility.
      const reader = request.body?.getReader();
      if (!reader) return reply(400,{status:'invalid_notification'});
      const chunks=[];let size=0;
      while (true) {
        const {done,value}=await reader.read();if(done)break;
        size+=value.byteLength;
        if(size>16384){await reader.cancel();return reply(413,{status:'request_too_large'});}
        chunks.push(value);
      }
      const bytes=new Uint8Array(size);let offset=0;
      for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.byteLength;}
      const body = JSON.parse(new TextDecoder().decode(bytes));
      const id = body?.record?.id ?? body?.notification_id;
      if (!uuid.test(id ?? '')) return reply(400,{status:'invalid_notification'});
      const row = await store.notification(id);
      const timestamp = Date.parse(row?.created_at);
      if (row?.id !== id || !recipients.includes(row.user_id) || row.type !== 'chat' ||
          !Number.isFinite(timestamp) || timestamp < Date.parse(notBefore) ||
          timestamp > now() || now()-timestamp > 300000) {
        return reply(200,{status:'outside_test_scope'});
      }
      const result = await deliverExistingNotification({notificationId:id,store,provider});
      // No identifiers, tokens, keys or backend error details in the response.
      return reply(200,{status:result.status,sent:result.sent,unknown:result.unknown ?? 0,
        failed:result.failed ?? 0,remaining:result.next != null});
    } catch { return reply(503,{status:'unavailable'}); }
  };
}
