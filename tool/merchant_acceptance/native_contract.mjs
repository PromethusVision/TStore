import assert from 'node:assert/strict';

export const nativePackage = 'com.esnaftavar.app.merchant.dev';
export const nativeActivity = nativePackage + '/com.esnaftavar.app.MainActivity';
export const nativePort = 5582;
export const nativeSerial = `emulator-${nativePort}`;
export function avdName(project) {
  assert.match(project, /^ev-merchant-ab-[a-f0-9]{12}$/);
  return 'merchant_native_' + project.slice(-12);
}
export function assertOwnedDevice(output, project) {
  assert.deepEqual(output.trim().split(/\s+/), [avdName(project), 'OK'],
    'Refuse an existing phone or a different emulator');
}
export function assertOffline(airplane, connectivity) {
  assert.equal(airplane.trim(), '1');
  assert.match(connectivity, /Active default network:\s*none/);
  assert.match(connectivity, /Current Networks:\s*Status for known UIDs:/);
}
const entities = {amp: '&', lt: '<', gt: '>', quot: '"', apos: "'"};
export function xmlText(text) {
  return text.replace(/&(#x[0-9a-fA-F]+|#\d+|amp|lt|gt|quot|apos);/g, (_, name) =>
    name[0] === '#' ? String.fromCodePoint(parseInt(name.slice(name[1] === 'x' ? 2 : 1), name[1] === 'x' ? 16 : 10)) : entities[name]);
}
export function uiNodes(xml) {
  assert.match(xml, /<hierarchy\b/);
  return [...xml.matchAll(/<node\b([^>]+)>/g)].map(match =>
    Object.fromEntries([...match[1].matchAll(/([\w-]+)="([^"]*)"/g)].map(a => [a[1], xmlText(a[2])])));
}
export function center(node) {
  const m = /^\[(\d+),(\d+)\]\[(\d+),(\d+)\]$/.exec(node?.bounds ?? '');
  assert(m, 'Observed bounds required');
  const [x1, y1, x2, y2] = m.slice(1).map(Number);
  assert(x2 > x1 && y2 > y1 && x2 <= 10000 && y2 <= 10000);
  return [Math.floor((x1 + x2) / 2), Math.floor((y1 + y2) / 2)];
}
export function selectNode(nodes, label) {
  const found = nodes.filter(n => (n['content-desc'] === label || n.text === label) && n.enabled === 'true');
  assert.equal(found.length, 1, 'Expected one observed enabled element');
  center(found[0]);
  return found[0];
}
export function assertSyntheticLogin(login) {
  assert.match(login?.email ?? '', /^[a-f0-9-]{36}@example\.invalid$/);
  assert.match(login?.password ?? '', /^[a-f0-9]{48}$/);
}
export function safeInput(value) {
  // No shell metacharacters, Unicode keyboard injection or real credential input.
  assert.match(value, /^[a-zA-Z0-9@.,_ -]{1,150}$/);
  assert(!value.includes('%'));
  return value.replaceAll(' ', '%s');
}
export const nativeChecks = Object.freeze([
  'native login and owned onboarding',
  'listing price persists through process restart',
  'local notification preferences persist through restart',
  'connection loss denies stale workspace and retry recovers',
  'in-memory draft survives background and resume',
  'native gallery publishes owned bytes and renders photo',
  'photo persists through process restart and Customer download',
  'availability and deactivation agree with Customer reads',
  'logout persists through restart and Customer role is denied',
  'other merchant sees only own workspace and preferences',
  'original merchant returns to persisted listing and inbox',
]);
export function validateNativeChecks(checks) {
  assert.deepEqual(checks.map(x => ({name: x.name, result: x.result})),
    nativeChecks.map(name => ({name, result: 'PASS'})));
  for (const item of checks) {
    assert.match(item.screen_sha256, /^[a-f0-9]{64}$/);
    assert.match(item.xml_sha256, /^[a-f0-9]{64}$/);
  }
}
