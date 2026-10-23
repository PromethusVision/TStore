// Deployment is a separate approval. This function is inert without the exact
// Development endpoint, an explicit cohort/cutover and approved server secrets.
import { FcmHttpProvider } from '../../../tool/engagement/fcm_http_provider.mjs';
import { googleServiceToken } from '../../../tool/engagement/google_service_token.mjs';
import { DevelopmentRpcPushStore, createDevelopmentPushWorker } from '../../../tool/engagement/development_push_worker.mjs';

let handler = createDevelopmentPushWorker({});
try {
  if (Deno.env.get('ESNAFTAVAR_PUSH_ENABLED') === 'true') {
    const credentials = JSON.parse(Deno.env.get('ESNAFTAVAR_FCM_SERVICE_ACCOUNT') ?? '{}');
    const provider = new FcmHttpProvider({projectId: credentials.project_id,
      accessToken: googleServiceToken({credentials}), enabled:true});
    const store = new DevelopmentRpcPushStore({url:Deno.env.get('SUPABASE_URL'),
      serviceKey:Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')});
    handler = createDevelopmentPushWorker({enabled:true, store, provider,
      secret:Deno.env.get('ESNAFTAVAR_PUSH_WORKER_SECRET'),
      recipients:JSON.parse(Deno.env.get('ESNAFTAVAR_PUSH_TEST_USERS') ?? '[]'),
      notBefore:Deno.env.get('ESNAFTAVAR_PUSH_NOT_BEFORE')});
  }
} catch { /* Fail closed without emitting configuration or credential data. */ }
Deno.serve(handler);
