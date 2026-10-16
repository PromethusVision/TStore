// Trusted service lane only. No endpoint, scheduler, real provider or credentials.
// The store commits begin() as UNKNOWN before external I/O. Never retry a send.
export async function deliverExistingNotification({
  notificationId, store, provider, after = null, timeoutMs = 15000,
}) {
  if (provider?.configured !== true) return { status: 'pending_configuration', sent: 0 };
  if (!Number.isInteger(timeoutMs) || timeoutMs < 1 || timeoutMs > 60000) {
    throw new RangeError('push_timeout_invalid');
  }
  const page = await store.page(notificationId, after);
  if (page.status !== 'ready') return { status: page.status, sent: 0 };
  const result = { status: 'processed', sent: 0, unknown: 0, failed: 0, cancelled: 0, skipped: 0,
    next: page.installations.length === 100 ? page.installations.at(-1) : null };
  for (const installation of page.installations) {
    const claim = await store.claim(notificationId, installation);
    if (!claim) { result.skipped++; continue; }
    // If begin's commit acknowledgement is lost, stop here; no provider call.
    const target = await store.begin(claim);
    if (!target) { result.cancelled++; continue; }
    let response, timer;
    const abort = new AbortController();
    try {
      response = await Promise.race([
        provider.send({ token: target.token, title: 'EsnaftaVar', body: 'Yeni bir bildirimin var.',
          data: { notification_id: target.notification_id, user_id: target.user_id, app_role: target.app_role,
            delivery_id: claim } },
        { signal: abort.signal }),
        new Promise((_, reject) => {
          timer = setTimeout(() => { abort.abort(); reject(new Error('push_timeout')); }, timeoutMs);
        }),
      ]);
    } catch {
      // Exceptions (including timeouts) do not prove rejection. Never retain raw errors.
      response = { outcome: 'unknown' };
    } finally { clearTimeout(timer); }
    const outcome = response?.outcome === 'accepted' ? 'provider_accepted'
      : response?.outcome === 'rejected' ? 'failed' : 'unknown';
    try {
      const recorded = await store.finish(claim, outcome,
        outcome === 'failed' && response.code === 'token_unregistered');
      if (recorded !== outcome) { result.unknown++; continue; }
      if (outcome === 'provider_accepted') result.sent++;
      else if (outcome === 'failed') result.failed++;
      else result.unknown++;
    } catch {
      // Provider acceptance and persistence are separate. The durable UNKNOWN
      // claim survives a lost DB acknowledgement; no disable or second send.
      result.unknown++;
    }
  }
  return result;
}
