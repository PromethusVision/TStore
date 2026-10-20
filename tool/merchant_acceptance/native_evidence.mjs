// Verifies observed local files and packages a sanitized, source-bound record.
// Screenshots/JSON are reproducible evidence, not signed human acceptance.
import assert from 'node:assert/strict';
import {readFile, writeFile, readdir, realpath, copyFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {readRun, root, command, credentials} from './local.mjs';
import {digest} from './pilot_preparation_contract.mjs';
import {sourceSnapshot, run as binaryCommand} from '../pilot_device/build_pair.mjs';
import {nativeChecks, validateNativeChecks, nativePackage, uiNodes, selectNode, assertOffline} from './native_contract.mjs';
import {nativeDevice} from './native_device.mjs';

const proofPath = 'docs/data/merchant_pilot_native_operations_acceptance.json';
const captures = ['step01-onboarding', 'step02-listing-restart', 'step03-preferences-restart',
  'step04-network-recovered', 'step05-draft-resume', 'step06-native-photo', 'step07-photo-restart',
  'step08-reactivated', 'step09-customer-denied', 'step10-other-preferences', 'step11-original-inbox'];
const labels = ['Native Pilot Magaza', 'Native pilot kalem\n123,45 TL\nStokta var',
  'Bildirim tercihleri', 'Native Pilot Magaza', '234.56', 'Ana fotoğraf\nYayında',
  'Ana fotoğraf\nYayında', 'Native pilot kalem\n234,56 TL\nStokta var',
  'Bu hesabın esnaf yetkisi henüz yok. Onaylı esnaf hesabınızla giriş yapın.',
  'Bildirim tercihleri', 'Native pilot bildirimi\nYerel prova'];
const serviceLabel = 'Hizmet bildirimleri\nAlışveriş ve mesaj gelişmeleri için mobil bildirim tercihi.';
async function toolSources() {
  const dir = resolve(root, 'tool/merchant_acceptance');
  const files = (await readdir(dir)).filter(x => /^native_.*\.(mjs|ps1)$/.test(x)).sort();
  const sources = [];
  for (const file of files) {
    const path = resolve(dir, file);
    assert.equal(await realpath(path), path);
    sources.push({path: 'tool/merchant_acceptance/' + file,
      sha256_lf: digest((await readFile(path, 'utf8')).replaceAll('\r\n', '\n'))});
  }
  return sources;
}
let local;
try {
  const action = process.argv[2];
  if (action === 'verify') {
    assert.equal(process.argv.length, 3);
    const proof = JSON.parse(await readFile(resolve(root, proofPath), 'utf8'));
    assert.equal(proof.kind, 'merchant-native-operations-local-v1');
    assert.equal(proof.result, 'PASS');
    assert.equal(proof.runtime_sources.sha256, (await sourceSnapshot(root)).sha256);
    assert.deepEqual(proof.tool_sources, await toolSources());
    validateNativeChecks(proof.checks);
    assert.equal(proof.remote_access, 'NONE');
    assert.equal(proof.distribution_ready, false);
    assert.equal(proof.physical_two_device, 'OPEN');
    assert.equal(proof.artifact.package, nativePackage);
    console.log('NATIVE_EVIDENCE_FRESH: source/shape only; not physical or release authority.');
  } else {
    assert.equal(action, 'record');
    assert.equal(process.argv.length, 6);
    local = await readRun(process.argv[3]);
    const sdk = await realpath(process.argv[4]), java = await realpath(process.argv[5]);
    const device = await nativeDevice(local, sdk);
    await device.offline();
    const snapshot = await sourceSnapshot(root);
    // This acceptance deliberately uses the unchanged integrated runtime.
    // Any runtime edit requires a new explicitly reviewed build/rehearsal.
    await command('git', ['diff', '--exit-code', '0c1ad8d5', '--', 'lib', 'android', 'assets', 'pubspec.yaml', 'pubspec.lock']);
    const built = resolve(root, 'build/app/outputs/flutter-apk/app-merchantdevelopment-debug.apk');
    const tools = resolve(sdk, 'build-tools/35.0.0');
    const badging = await command(resolve(tools, 'aapt.exe'), ['dump', 'badging', built]);
    const manifest = await command(resolve(tools, 'aapt.exe'), ['dump', 'xmltree', built, 'AndroidManifest.xml']);
    assert.match(badging, /package: name='com\.esnaftavar\.app\.merchant\.dev' versionCode='5' versionName='1\.0\.0'/);
    assert.match(badging, /application-debuggable/);
    assert.match(badging, /native-code:.*'x86_64'/);
    assert.match(manifest, /android:allowBackup.*0x0/);
    assert.match(manifest, /android:usesCleartextTraffic.*0x0/);
    const signing = await command(java, ['-jar', resolve(tools, 'lib/apksigner.jar'), 'verify', '--verbose', '--print-certs', built]);
    const certificate = /certificate SHA-256 digest:\s*([a-fA-F0-9]{64})/.exec(signing)?.[1]?.toLowerCase();
    assert(certificate);
    const status = await credentials(local);
    const payload = await binaryCommand(resolve(process.env.ProgramFiles ?? 'C:/Program Files', '7-Zip/7z.exe'),
      ['x', '-so', built, 'assets/flutter_assets/kernel_blob.bin'], {binary: true, maxBytes: 400 * 1024 * 1024});
    assert(payload.includes(Buffer.from(status.API_URL)));
    assert(payload.includes(Buffer.from(status.ANON_KEY)));
    assert(!payload.includes(Buffer.from(status.SERVICE_ROLE_KEY)));
    for (const actor of ['merchant', 'other', 'customer']) {
      assert(!payload.includes(Buffer.from(device.fixture[actor].password)));
      assert(!payload.includes(Buffer.from(device.fixture[actor].email)));
    }
    const artifact = {package: nativePackage, version: '1.0.0+5', mode: 'debug',
      target: 'android-x64', entrypoint: 'lib/main_merchant_development.dart',
      bytes: (await readFile(built)).length, sha256: digest(await readFile(built)), certificate_sha256: certificate,
      configured_backend: 'owned loopback 127.0.0.1:55431', client_key_scope: 'local anonymous role only',
      server_credentials_in_payload: false, fixture_accounts_in_payload: false};
    const xml = async name => uiNodes(await readFile(resolve(device.out, name + '.xml'), 'utf8'));
    const checks = [];
    for (let i = 0; i < captures.length; i++) {
      selectNode(await xml(captures[i]), labels[i]);
      checks.push({name: nativeChecks[i], result: 'PASS',
        screen_sha256: digest(await readFile(resolve(device.out, captures[i] + '.png'))),
        xml_sha256: digest(await readFile(resolve(device.out, captures[i] + '.xml')))});
    }
    validateNativeChecks(checks);
    assert.equal(selectNode(await xml(captures[2]), serviceLabel).checked, 'false');
    assert.equal(selectNode(await xml(captures[9]), serviceLabel).checked, 'true');
    assert.equal(selectNode(await xml('state-original-preferences'), serviceLabel).checked, 'false');
    selectNode(await xml('fault-offline-gate'), 'Hesabını doğrula');
    selectNode(await xml('state-logout-restart'), 'Giriş yap');
    selectNode(await xml('state-other-empty'), 'Henüz ürün eklemedin. Katalogdan ilk ürününü seç.');
    selectNode(await xml('state-original-listing'), 'Native pilot kalem\n234,56 TL\nStokta var');
    const observations = {};
    for (const name of ['observe-price', 'observe-unsaved-draft', 'observe-photo', 'observe-unavailable', 'observe-inactive', 'observe-reactivated', 'observe-final']) {
      const record = JSON.parse(await readFile(resolve(device.out, name + '.json'), 'utf8'));
      assert.equal(record.listing_count, 1);
      assert.equal(record.central_price_sentinel, 0);
      assert.equal(record.decisions_enabled, false);
      assert.equal(record.verified_purchases, 0);
      assert.equal(record.foreign_shop_and_notice_unchanged, true);
      const price = ['observe-price', 'observe-unsaved-draft'].includes(name) ? '123.45' : '234.56';
      assert.equal(record.listings[0].price, price);
      const unavailable = name === 'observe-unavailable', inactive = name === 'observe-inactive';
      assert.equal(record.listings[0].is_active, !inactive);
      assert.equal(record.listings[0].is_available, !unavailable);
      assert.equal(record.customer_offers.length, unavailable || inactive ? 0 : 1);
      if (['observe-photo', 'observe-reactivated', 'observe-final'].includes(name)) {
        assert.equal(record.customer_media_count, 1);
        assert.equal(record.customer_downloads[0].sha256, digest(await readFile(resolve(root, 'assets/logos/esnaftavar-logo.png'))));
      }
      observations[name] = record;
    }
    const pid = (await device.call(['shell', 'pidof', nativePackage])).trim();
    assert.match(pid, /^\d+$/);
    const logs = await device.call(['logcat', '-d', '--pid=' + pid]);
    assert(!/FATAL EXCEPTION|Unhandled Exception|A RenderFlex overflowed|\[ERROR:flutter/i.test(logs));
    await writeFile(resolve(device.out, 'final-process.log'), device.redact(logs), {flag: 'wx', mode: 0o600});
    assertOffline(await device.call(['shell', 'settings', 'get', 'global', 'airplane_mode_on']),
      await device.call(['shell', 'dumpsys', 'connectivity']));
    await copyFile(built, resolve(device.out, 'merchant-local-x64.apk'), 1);
    const record = {kind: 'merchant-native-operations-local-v1', result: 'PASS', captured_at: new Date().toISOString(),
      runtime_commit: '0c1ad8d5', runtime_sources: {sha256: snapshot.sha256, file_count: snapshot.files.length},
      tool_sources: await toolSources(), artifact, checks, database_observations: observations,
      services: JSON.parse(await readFile(resolve(device.out, 'services.json'), 'utf8')),
      emulator: {api: 35, profile: 'Pixel 5 x86_64', airplane_mode: true, wifi_and_cellular: false,
        transport: 'ADB reverse tcp:55431 only', camera: 'disabled', process_log_errors: 0},
      remote_access: 'NONE', production_writes: 'NONE', development_hosted_writes: 'NONE',
      physical_two_device: 'OPEN', distribution_ready: false,
      limits: ['Local Merchant development entrypoint, not the hosted merchantPilot recovery bootstrap',
        'Android emulator gallery and disk persistence, not physical vendor hardware or camera',
        'No external email, push provider, real cohort, QR purchase or release acceptance',
        'Observed screenshots plus DB/HTTP checks; not a signed attestation']};
    await writeFile(resolve(root, proofPath), JSON.stringify(record, null, 2) + '\n', {flag: 'wx'});
    console.log('NATIVE_OPERATIONS_LOCAL_PASS: 11 native checkpoints and 7 independent server observations.');
  }
} catch (error) {
  if (local) await writeFile(resolve(local.dir, 'native-evidence-failure.txt'), error.stack + '\n' + (error.diagnostics ?? ''), {mode: 0o600});
  console.error('NATIVE_EVIDENCE_REFUSED: incomplete/stale local evidence; no remote fallback.');
  process.exitCode = 1;
}
