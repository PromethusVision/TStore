// ADB operates only the exact named task emulator. No default device, physical
// phone, public network, arbitrary shell command or production build fallback.
import assert from 'node:assert/strict';
import {readFile, writeFile, realpath, access} from 'node:fs/promises';
import {resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {readRun, command, root} from './local.mjs';
import {digest} from './pilot_preparation_contract.mjs';
import {nativeActivity, nativePackage, nativeSerial, assertOwnedDevice, assertOffline,
  uiNodes, selectNode, center, safeInput, assertSyntheticLogin} from './native_contract.mjs';

export async function nativeDevice(run, sdk) {
  const base = await realpath(sdk);
  const adb = await realpath(resolve(base, 'platform-tools', process.platform === 'win32' ? 'adb.exe' : 'adb'));
  const call = args => command(adb, ['-s', nativeSerial, ...args], undefined, 60000);
  const own = async () => assertOwnedDevice(await call(['emu', 'avd', 'name']), run.project);
  const offline = async () => {
    await own();
    assertOffline(await call(['shell', 'settings', 'get', 'global', 'airplane_mode_on']),
      await call(['shell', 'dumpsys', 'connectivity']));
  };
  await own();
  const out = resolve(run.dir, 'native');
  const fixture = JSON.parse(await readFile(resolve(out, 'fixture.json'), 'utf8'));
  assert.equal(fixture.kind, 'merchant-native-local-v1');
  assert.equal(fixture.project, run.project);
  for (const key of ['merchant', 'customer', 'other']) assertSyntheticLogin(fixture[key]);
  const redact = value => {
    for (const key of ['merchant', 'customer', 'other']) {
      value = value.replaceAll(fixture[key].email, `[${key}-synthetic-email]`).replaceAll(fixture[key].password, '[synthetic-password]');
    }
    return value;
  };
  const screen = async () => {
    await offline();
    await call(['shell', 'uiautomator', 'dump', '/data/local/tmp/native-merchant.xml']);
    await call(['pull', '/data/local/tmp/native-merchant.xml', resolve(out, 'screen.xml')]);
    return uiNodes(await readFile(resolve(out, 'screen.xml'), 'utf8'));
  };
  const tapNode = async node => {
    await offline();
    await call(['shell', 'input', 'tap', ...center(node).map(String)]);
  };
  const tap = async label => tapNode(selectNode(await screen(), label));
  const input = async (index, value) => {
    const edits = (await screen()).filter(n => n.class === 'android.widget.EditText' && n.enabled === 'true');
    assert(Number.isSafeInteger(index) && index >= 0 && index < edits.length);
    await tapNode(edits[index]);
    // Select all on the observed field; no guessing of screen coordinates.
    await call(['shell', 'input', 'keyevent', '--longpress', 'KEYCODE_MOVE_END']);
    await call(['shell', 'input', 'keycombination', '113', '29']); // CTRL+A
    await call(['shell', 'input', 'keyevent', 'KEYCODE_DEL']);
    await call(['shell', 'input', 'text', safeInput(value)]);
  };
  const capture = async name => {
    assert.match(name, /^[a-z][a-z0-9-]{0,70}$/);
    for (const ext of ['png', 'xml']) {
      await assert.rejects(access(resolve(out, name + '.' + ext)), {code: 'ENOENT'}, 'Never overwrite observations');
    }
    await screen();
    await call(['shell', 'screencap', '-p', '/data/local/tmp/native-merchant.png']);
    await call(['pull', '/data/local/tmp/native-merchant.png', resolve(out, 'screen.png')]);
    const png = await readFile(resolve(out, 'screen.png'));
    const xml = await readFile(resolve(out, 'screen.xml'));
    await writeFile(resolve(out, name + '.png'), png, {flag: 'wx'});
    await writeFile(resolve(out, name + '.xml'), xml, {flag: 'wx', mode: 0o600});
    return {screen_sha256: digest(png), xml_sha256: digest(xml)};
  };
  return {call, own, offline, screen, tap, input, capture, fixture, redact, out};
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  let run;
  try {
    run = await readRun(process.argv[2]);
    const device = await nativeDevice(run, process.argv[3]);
    const {call, offline, fixture} = device;
    const action = process.argv[4], args = process.argv.slice(5);
    if (action === 'isolate') {
      await call(['shell', 'cmd', 'connectivity', 'airplane-mode', 'enable']);
      await call(['shell', 'svc', 'wifi', 'disable']);
      await call(['shell', 'svc', 'data', 'disable']);
      // Android tears down networks asynchronously. Never proceed on the flag
      // alone; a bounded wait still requires the full observed isolation state.
      for (let i = 0; i < 20; i++) {
        try { await offline(); break; } catch (error) {
          if (i === 19) throw error;
          await new Promise(r => setTimeout(r, 500));
        }
      }
      await offline();
      await call(['shell', 'settings', 'put', 'system', 'screen_off_timeout', '1800000']);
      await call(['shell', 'input', 'keyevent', 'KEYCODE_WAKEUP']);
      await call(['shell', 'wm', 'dismiss-keyguard']);
    } else {
      await offline();
      if (action === 'screen') {
        console.log(device.redact(JSON.stringify((await device.screen()).filter(n =>
          n['content-desc'] || n.text || n.class === 'android.widget.EditText').map(n => ({
          text: n.text || n['content-desc'] || '(empty input)', type: n.class.split('.').at(-1),
          bounds: n.bounds, enabled: n.enabled, checked: n.checked})))));
      } else if (action === 'tap') await device.tap(args[0]);
      else if (action === 'tab') {
        const labels = ['Özet', 'Ürünler', 'QR', 'Bildirim', 'Hesap'];
        const index = Number(args[0]);
        assert(Number.isInteger(index) && index >= 0 && index < labels.length);
        await device.tap(`${labels[index]}\nTab ${index + 1} of 5`);
      }
      else if (action === 'input') await device.input(Number(args[0]), args[1]);
      else if (action === 'scroll') {
        assert(['down', 'up'].includes(args[0]));
        const scrollables = (await device.screen()).filter(n => n.scrollable === 'true');
        assert.equal(scrollables.length, 1, 'One observed scroll surface required');
        const bounds = scrollables[0].bounds.match(/\d+/g).map(Number);
        const x = Math.floor((bounds[0] + bounds[2]) / 2);
        const a = Math.floor(bounds[1] + (bounds[3] - bounds[1]) * .8);
        const b = Math.floor(bounds[1] + (bounds[3] - bounds[1]) * .2);
        await call(['shell', 'input', 'swipe', String(x), String(args[0] === 'down' ? a : b),
          String(x), String(args[0] === 'down' ? b : a), '400']);
      }
      else if (action === 'login') {
        assert(['merchant', 'customer', 'other'].includes(args[0]));
        await device.input(0, fixture[args[0]].email);
        await device.input(1, fixture[args[0]].password);
        await call(['shell', 'input', 'keyevent', 'KEYCODE_BACK']);
        await device.tap('Giriş yap');
      } else if (action === 'back') await call(['shell', 'input', 'keyevent', 'KEYCODE_BACK']);
      else if (action === 'photo-fixture') {
        const path = await realpath(resolve(root, 'assets/logos/esnaftavar-logo.png'));
        assert.equal(path, resolve(root, 'assets/logos/esnaftavar-logo.png'));
        await call(['push', path, '/sdcard/Download/native-pilot.png']);
        await call(['shell', 'am', 'broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d', 'file:///sdcard/Download/native-pilot.png']);
      }
      else if (action === 'home') await call(['shell', 'input', 'keyevent', 'KEYCODE_HOME']);
      else if (action === 'launch') await call(['shell', 'am', 'start', '-W', '-n', nativeActivity]);
      else if (action === 'restart') {
        await call(['shell', 'am', 'force-stop', nativePackage]);
        await call(['shell', 'am', 'start', '-W', '-n', nativeActivity]);
      } else if (action === 'disconnect') await call(['reverse', '--remove', 'tcp:55431']);
      else if (action === 'connect') await call(['reverse', 'tcp:55431', 'tcp:55431']);
      else if (action === 'capture') console.log(JSON.stringify(await device.capture(args[0])));
      else if (action === 'stop') await call(['emu', 'kill']);
      else throw new Error('Unsupported native operation');
    }
    if (action !== 'screen') console.log('NATIVE_ACTION_PASS: ' + action);
  } catch (error) {
    if (run) await writeFile(resolve(run.dir, 'native-device-failure.txt'), error.stack + '\n' + (error.diagnostics ?? ''), {mode: 0o600});
    console.error('NATIVE_ACTION_FAILED: see private local diagnostics; no other device attempted.');
    process.exitCode = 1;
  }
}
