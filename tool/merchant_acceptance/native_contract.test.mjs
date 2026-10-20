import test from 'node:test';
import assert from 'node:assert/strict';
import {assertOwnedDevice, assertOffline, assertSyntheticLogin, safeInput, uiNodes, selectNode, center, validateNativeChecks, nativeChecks} from './native_contract.mjs';

const project = 'ev-merchant-ab-012345abcdef';
test('only the named task emulator is accepted', () => {
  assertOwnedDevice('merchant_native_012345abcdef\r\nOK\r\n', project);
  for (const value of ['Pixel_5\nOK', 'merchant_native_012345abcdef\nOK\nextra', 'merchant_native_123456abcdef\nOK']) {
    assert.throws(() => assertOwnedDevice(value, project));
  }
  assert.throws(() => assertOwnedDevice('', '../other'));
});
test('airplane flag alone cannot certify isolation', () => {
  const offline = 'Active default network: none\nCurrent Networks:\nStatus for known UIDs:';
  assertOffline('1', offline);
  assert.throws(() => assertOffline('0', offline));
  assert.throws(() => assertOffline('1', offline.replace('none', '100')));
  assert.throws(() => assertOffline('1', offline.replace('Status', 'NetworkAgentInfo\nStatus')));
});
test('observed Android XML selectors decode Turkish and reject ambiguity', () => {
  const xml = '<hierarchy><node text="" content-desc="Ürün &amp; fiyat" enabled="true" bounds="[10,20][100,80]"/><node text="Giriş" enabled="false" bounds="[0,0][50,50]"/></hierarchy>';
  const nodes = uiNodes(xml);
  assert.deepEqual(center(selectNode(nodes, 'Ürün & fiyat')), [55, 50]);
  assert.throws(() => selectNode(nodes, 'Giriş'));
  assert.throws(() => selectNode([...nodes, nodes[0]], 'Ürün & fiyat'));
  assert.throws(() => center({bounds: '[0,0][0,0]'}));
});
test('credential input accepts only generated local fixture identities', () => {
  const login = {email: '00000000-0000-4000-8000-000000000001@example.invalid', password: 'a'.repeat(48)};
  assertSyntheticLogin(login);
  assert.throws(() => assertSyntheticLogin({...login, email: 'real@example.com'}));
  assert.throws(() => assertSyntheticLogin({...login, password: 'real-password'}));
});
test('Android input rejects shell syntax and unbounded input', () => {
  assert.equal(safeInput('Native pilot 123.45'), 'Native%spilot%s123.45');
  for (const text of ['$(id)', '`id`', 'a;b', 'a|b', 'x\n', '%s', 'a'.repeat(151)]) {
    assert.throws(() => safeInput(text));
  }
});
test('partial/reordered or unverifiable native observations cannot pass', () => {
  const checks = nativeChecks.map(name => ({name, result: 'PASS', screen_sha256: 'a'.repeat(64), xml_sha256: 'b'.repeat(64)}));
  validateNativeChecks(checks);
  assert.throws(() => validateNativeChecks(checks.slice(1)));
  assert.throws(() => validateNativeChecks([...checks].reverse()));
  assert.throws(() => validateNativeChecks(checks.map(x => ({...x, result: 'SKIP'}))));
  assert.throws(() => validateNativeChecks(checks.map(x => ({...x, screen_sha256: ''}))));
});
