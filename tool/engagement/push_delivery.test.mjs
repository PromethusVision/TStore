import { test } from 'node:test';
import assert from 'node:assert/strict';
import { deliverExistingNotification } from './push_delivery.mjs';

function fixture(role = 'customer') {
  const notification = { id: 'fixture-notification', user_id: 'fixture-user', type: 'promotion',
    data: { app_role: role, delivery_purpose: 'marketing', campaign_id: 'fixture-campaign' } };
  const campaign = { is_active: true, content_version: 2, audience: 'general' };
  const preference = { marketing_enabled: true, service_enabled: true };
  const device = { user_id: notification.user_id, app_role: role, enabled: true,
    platform: 'android', installation_id: 'fixture-install', push_token: 'opaque-fixture-token' };
  const sent = [], disabled = [], failed = [], claims = new Set();
  const store = {
    notification: async () => notification, campaign: async () => campaign,
    role: async () => role, preferences: async () => preference, devices: async () => [device],
    claim: async (...parts) => { const key = parts.join(':'); if (claims.has(key)) return null; claims.add(key); return key; },
    complete: async () => {}, fail: async (id) => failed.push(id),
    disable: async (...args) => disabled.push(args),
  };
  const provider = { configured: true, send: async (message) => sent.push(message) };
  const run = () => deliverExistingNotification({ notificationId: notification.id, store, provider,
    now: new Date('2026-09-26T00:00:00Z') });
  return { notification, campaign, preference, device, store, provider, sent, disabled, failed, run };
}
test('unconfigured provider never reads store or sends', async () => {
  assert.deepEqual(await deliverExistingNotification({ provider: { configured: false } }),
    { status: 'pending_configuration', sent: 0 });
});
for (const role of ['customer', 'merchant']) test(`${role} uses same server-only delivery and durable idempotency`, async () => {
  const f = fixture(role);
  assert.equal((await f.run()).sent, 1); assert.equal((await f.run()).sent, 0);
  assert.equal(f.sent[0].data.app_role, role);
  assert.equal(f.sent[0].body, 'Yeni bir bildirimin var.');
  assert.ok(!JSON.stringify(f.sent[0].data).includes('token'));
});
test('marketing defaults to off and opt-out is honored', async () => {
  const f = fixture(); delete f.preference.marketing_enabled;
  assert.equal((await f.run()).status, 'opted_out');
  f.preference.marketing_enabled = false;
  assert.equal((await f.run()).sent, 0);
});
test('service preference applies without granting marketing consent', async () => {
  const f = fixture(); f.notification.type = 'chat'; f.notification.data = {};
  f.preference.marketing_enabled = false;
  assert.equal((await f.run()).sent, 1);
  const g = fixture(); g.notification.type = 'order'; g.notification.data = {};
  g.preference.service_enabled = false;
  assert.equal((await g.run()).status, 'opted_out');
});
test('promotion cannot claim transactional delivery and unknown system purpose fails closed', async () => {
  const f = fixture(); f.notification.data.delivery_purpose = 'service';
  assert.equal((await f.run()).status, 'rejected');
  f.notification.type = 'system'; delete f.notification.data.delivery_purpose;
  assert.equal((await f.run()).status, 'rejected');
});
for (const mismatch of ['user_id', 'app_role', 'enabled', 'platform']) test(`invalid device ${mismatch} is never sent`, async () => {
  const f = fixture(); f.device[mismatch] = mismatch === 'enabled' ? false : 'invalid';
  assert.equal((await f.run()).sent, 0);
});
test('notification role mismatch fails before selecting devices', async () => {
  const f = fixture(); f.notification.data.app_role = 'merchant';
  assert.equal((await f.run()).status, 'rejected');
});
for (const change of [ { is_active: false }, { end_date: '2026-09-25' },
  { start_date: '2026-09-27' }, { end_date: 'invalid' }, { city: 'fixture-city' },
  { district: 'fixture-district' }, { category_scope: 'fixture-category' }, { content_version: 1 } ]) {
  test(`ineligible campaign ${Object.keys(change)[0]} fails closed`, async () => {
    const f = fixture(); Object.assign(f.campaign, change);
    assert.equal((await f.run()).status, 'ineligible_campaign'); assert.equal(f.sent.length, 0);
  });
}
test('expired provider token is disabled and raw error is not persisted', async () => {
  const f = fixture(); f.provider.send = async () => { throw { code: 'token_unregistered', private: 'never-log' }; };
  assert.equal((await f.run()).sent, 0); assert.equal(f.disabled.length, 1);
  assert.equal(f.failed.length, 1); assert.ok(!JSON.stringify(f.failed).includes('never-log'));
  assert.equal((await f.run()).sent, 0);
});
