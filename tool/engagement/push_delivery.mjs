// Server-only, provider-independent dispatcher. No endpoint and no auto-sender.
// Wire a trusted queue to an existing notifications row after separate deployment.
// No credentials in this module. The future FCM adapter gets a short-lived server
// access token from its environment's secret manager, never from Flutter.
export async function deliverExistingNotification({ notificationId, store, provider, now = new Date() }) {
  if (!provider.configured) return { status: 'pending_configuration', sent: 0 };
  const notification = await store.notification(notificationId);
  if (!notification || !['order', 'chat', 'promotion', 'system'].includes(notification.type)) {
    return { status: 'rejected', sent: 0 };
  }
  const role = await store.role(notification.user_id);
  if (!['customer', 'merchant'].includes(role) ||
      (notification.data?.app_role && notification.data.app_role !== role)) {
    return { status: 'rejected', sent: 0 };
  }
  const purpose = notification.data?.delivery_purpose ??
    (notification.type === 'promotion' ? 'marketing' :
      ['order', 'chat'].includes(notification.type) ? 'service' : null);
  // Unknown/general system content needs an explicit server-authored purpose.
  if (!['service', 'marketing'].includes(purpose) ||
      (notification.type === 'promotion' && purpose !== 'marketing')) {
    return { status: 'rejected', sent: 0 };
  }
  const preferences = await store.preferences(notification.user_id, role);
  if (purpose === 'marketing' ? preferences?.marketing_enabled !== true :
      preferences?.service_enabled === false) return { status: 'opted_out', sent: 0 };
  const campaignId = notification.data?.campaign_id;
  if (campaignId) {
    const campaign = await store.campaign(campaignId); // Same public.banners record.
    const dateInvalid = (date) => date != null && !Number.isFinite(Date.parse(date));
    if (!campaign || !campaign.is_active || campaign.content_version !== 2 ||
        campaign.audience !== 'general' || campaign.city || campaign.district || campaign.category_scope ||
        dateInvalid(campaign.start_date) || dateInvalid(campaign.end_date) ||
        (campaign.start_date && Date.parse(campaign.start_date) > now.getTime()) ||
        (campaign.end_date && Date.parse(campaign.end_date) < now.getTime())) {
      return { status: 'ineligible_campaign', sent: 0 };
    }
  }
  const devices = await store.devices(notification.user_id, role);
  let sent = 0;
  for (const device of devices) {
    if (!device.enabled || device.user_id !== notification.user_id || device.app_role !== role ||
        !['android', 'ios'].includes(device.platform) || !device.push_token) continue;
    // Store's durable claim must be atomic and recipient-scoped. Failed sends
    // stay failed/uncertain for explicit retry, never blind immediate duplicate.
    const claim = await store.claim(notification.id, device.installation_id, role);
    if (!claim) continue;
    try {
      // Generic lock-screen copy; authoritative private content is read after auth.
      await provider.send({ token: device.push_token,
        title: 'EsnaftaVar', body: 'Yeni bir bildirimin var.',
        data: { notification_id: notification.id, user_id: notification.user_id, app_role: role } });
      await store.complete(claim);
      sent++;
    } catch (error) {
      if (error?.code === 'token_unregistered') await store.disable(device.installation_id, role);
      await store.fail(claim); // Do not persist raw errors, tokens or provider bodies.
    }
  }
  return { status: 'processed', sent };
}
