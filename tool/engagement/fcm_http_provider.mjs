// Server only. Use an injected short-lived OAuth supplier, never a client API key.
// Stable HTTP v1/token transport matches I0. AndroidConfigV2 is still preview.
export class FcmHttpProvider {
  constructor({projectId, accessToken, fetchImpl = fetch, enabled = false}) {
    if (projectId !== 'esnaftavar-development') throw new Error('fcm_project_denied');
    this.projectId = projectId;
    this.accessToken = accessToken;
    this.fetch = fetchImpl;
    this.configured = enabled === true && typeof accessToken === 'function';
  }
  async send(message, {signal} = {}) {
    if (!this.configured) return {outcome: 'unknown'};
    const data = message?.data;
    const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    const packages = {customer:'com.esnaftavar.app.dev', merchant:'com.esnaftavar.app.merchant.pilot'};
    if (!data || !uuid.test(data.notification_id ?? '') || !uuid.test(data.user_id ?? '') ||
        !uuid.test(data.delivery_id ?? '') || !Object.hasOwn(packages, data.app_role) ||
        typeof message.token !== 'string' || message.token.length < 1 ||
        message.token.length > 4096 || /[\s\x00-\x1f]/.test(message.token)) {
      return {outcome:'rejected', code:'invalid_request'};
    }
    try {
      const token = await this.accessToken({signal});
      if (typeof token !== 'string' || !token || /\s/.test(token) || signal?.aborted) {
        return {outcome:'unknown'};
      }
      const response = await this.fetch(`https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`, {
        method:'POST', redirect:'error', signal,
        headers:{Authorization:`Bearer ${token}`, 'Content-Type':'application/json'},
        body: JSON.stringify({message:{token:message.token,
          notification:{title:'EsnaftaVar', body:'Yeni bir bildirimin var.'},
          data:{notification_id:data.notification_id, user_id:data.user_id,
            app_role:data.app_role, delivery_id:data.delivery_id},
          android:{priority:'HIGH', ttl:'300s', restricted_package_name:packages[data.app_role],
            notification:{channel_id:'esnaftavar_service', icon:'ic_notification_esnaftavar',
              tag:data.delivery_id, visibility:'PRIVATE', default_sound:true}},
        }}),
      });
      const result = await response.json();
      if (response.status === 200 && typeof result?.name === 'string' &&
          result.name.startsWith(`projects/${this.projectId}/messages/`) &&
          result.name.length > `projects/${this.projectId}/messages/`.length) {
        return {outcome:'accepted'};
      }
      const detail = result?.error?.details;
      const unregistered = response.status === 404 && Array.isArray(detail) && detail.some(d =>
        d?.['@type'] === 'type.googleapis.com/google.firebase.fcm.v1.FcmError' && d.errorCode === 'UNREGISTERED');
      // INVALID_ARGUMENT does not prove an invalid token. Never disable a device
      // for a project mismatch, malformed payload, 429/5xx or an unknown reply.
      if (unregistered) return {outcome:'rejected', code:'token_unregistered'};
      if ([400,401,403,404].includes(response.status) && typeof result?.error?.status === 'string') {
        return {outcome:'rejected', code:'provider_rejected'};
      }
    } catch { /* No raw credential, token, body, or provider error is retained. */ }
    return {outcome:'unknown'};
  }
}
