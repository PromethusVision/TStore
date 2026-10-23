// WebCrypto works in Node and the hosted Edge runtime. No disk or log output.
// Caller supplies an explicitly approved server secret; no auto-discovery of
// developer credentials, broad default service accounts or Production projects.
export function googleServiceToken({credentials, fetchImpl = fetch, cryptoImpl = crypto,
  now = () => Date.now()}) {
  if (credentials?.type !== 'service_account' || credentials.project_id !== 'esnaftavar-development' ||
      !/^[a-z][a-z0-9-]{5,29}@esnaftavar-development\.iam\.gserviceaccount\.com$/.test(credentials.client_email ?? '') ||
      typeof credentials.private_key !== 'string' ||
      !credentials.private_key.startsWith('-----BEGIN PRIVATE KEY-----')) {
    throw new Error('fcm_credential_denied');
  }
  const encoder = new TextEncoder();
  const b64 = bytes => btoa(String.fromCharCode(...bytes)).replaceAll('+','-').replaceAll('/','_').replace(/=+$/,'');
  const json = object => b64(encoder.encode(JSON.stringify(object)));
  let cached, expires = 0, inFlight;
  async function mint({signal} = {}) {
    if (cached && expires > now() + 60000) return cached;
    if (inFlight) return inFlight;
    inFlight = (async () => {
      try {
        const keyBytes = Uint8Array.from(atob(credentials.private_key
          .replace('-----BEGIN PRIVATE KEY-----','').replace('-----END PRIVATE KEY-----','').replace(/\s/g,'')), c => c.charCodeAt(0));
        const key = await cryptoImpl.subtle.importKey('pkcs8', keyBytes,
          {name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['sign']);
        const issued = Math.floor(now()/1000);
        const unsigned = `${json({alg:'RS256',typ:'JWT'})}.${json({iss:credentials.client_email,
          scope:'https://www.googleapis.com/auth/firebase.messaging',
          aud:'https://oauth2.googleapis.com/token',iat:issued,exp:issued+3600})}`;
        const signature = await cryptoImpl.subtle.sign('RSASSA-PKCS1-v1_5',key,encoder.encode(unsigned));
        const response = await fetchImpl('https://oauth2.googleapis.com/token',{
          method:'POST',redirect:'error',signal,
          headers:{'Content-Type':'application/x-www-form-urlencoded'},
          body:new URLSearchParams({grant_type:'urn:ietf:params:oauth:grant-type:jwt-bearer',
            assertion:`${unsigned}.${b64(new Uint8Array(signature))}`}).toString(),
        });
        const value = await response.json();
        if (!response.ok || typeof value.access_token !== 'string' || !value.access_token ||
            /\s/.test(value.access_token) || value.token_type?.toLowerCase() !== 'bearer' ||
            !Number.isFinite(value.expires_in) || value.expires_in < 60 || value.expires_in > 3600) {
          throw new Error('fcm_auth_unavailable');
        }
        cached = value.access_token;
        expires = now() + value.expires_in*1000;
        return cached;
      } catch { throw new Error('fcm_auth_unavailable'); }
    })();
    try { return await inFlight; } finally { inFlight = null; }
  }
  return mint;
}
