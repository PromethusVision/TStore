import { mkdir, writeFile, realpath } from 'node:fs/promises';
import { resolve } from 'node:path';
import { randomUUID, randomBytes } from 'node:crypto';
import assert from 'node:assert/strict';
import { root, command } from './local.mjs';
import { inside } from './safety.mjs';
import { connect, migrate, seed, nativeManagedSchema } from './fixture.mjs';
import { databaseChecks } from './postgres_checks.mjs';

// Native PostgreSQL proof is deliberately separate from managed Auth/Storage acceptance.
const base = resolve(root, '.buildlog/merchant-native');
let config, db, binary, directory, startAttempted=false, stage='binary';
try {
  assert.equal(process.platform, 'win32', 'This portable launcher targets Windows');
  binary = await realpath(resolve(process.argv[2]));
  assert.match(await command(resolve(binary, 'postgres.exe'), ['--version']), /PostgreSQL\) 17\./);
  directory = resolve(base, `run-${randomUUID()}`);
  await mkdir(directory, { recursive: true });
  await inside(base, directory);
  const data = resolve(directory, 'data'), password = randomBytes(32).toString('hex');
  await writeFile(resolve(directory, 'password.txt'), password, { flag: 'wx', mode: 0o600 });
  config = { host: '127.0.0.1', port: 55439, database: 'postgres', user: 'postgres', password, ssl: false };
  stage='initialize';
  await command(resolve(binary, 'initdb.exe'), ['-D', data, '-U', 'postgres', '--encoding=UTF8', '--locale=C',
    '--auth=scram-sha-256', '--pwfile', resolve(directory, 'password.txt')], directory, 180000);
  stage='start'; startAttempted=true;
  await command(resolve(binary, 'pg_ctl.exe'), ['-D', data, '-l', resolve(directory, 'server.log'),
    '-o', '-h 127.0.0.1 -p 55439 -c wal_level=logical', '-w', 'start'], directory, 60000, true);
  db = await connect(config);
  stage='acceptance';
  assert.equal(await realpath((await db.query('SHOW data_directory')).rows[0].data_directory), await realpath(data));
  await nativeManagedSchema(db);
  const manifest = await migrate(db);
  async function actor(id = randomUUID()) {
    await db.query("INSERT INTO auth.users(id,email) VALUES($1,$2) ON CONFLICT DO NOTHING", [id, `${id}@example.invalid`]);
    const sid = randomUUID();
    await db.query('INSERT INTO auth.sessions(id,user_id) VALUES($1,$2)', [sid, id]);
    return { id, claims: { sub: id, role: 'authenticated', session_id: sid }, installation: randomUUID() };
  }
  const fixture = await seed(db, await actor(), await actor(), await actor());
  fixture.session = id => actor(id);
  const checks = await databaseChecks(db, config, fixture);
  const evidence = { result: 'PASS', captured_at: new Date().toISOString(),
    runtime: (await db.query('SELECT version() AS version')).rows[0].version,
    evidence_class: 'native-postgresql-real-pgcrypto-independent-connections-synthetic-auth-storage-schema',
    managed_auth: 'OPEN', storage_http: 'OPEN', physical_two_device: 'OPEN', checks, migrations: manifest };
  await writeFile(resolve(directory, 'result.json'), JSON.stringify(evidence, null, 2)+'\n');
  await writeFile(resolve(root, 'docs/data/merchant_ab_native_acceptance.json'), JSON.stringify(evidence, null, 2)+'\n');
  console.log(`NATIVE_DATABASE_PROOF_PASS: ${checks.length} groups. Managed Auth/Storage are evidenced separately.`);
} catch (error) {
  // Synthetic DB only, but still avoid dumping SQL parameters, passwords or tokens.
  console.error(`NATIVE_DATABASE_PROOF_FAILED: ${stage}: ${error.code || error.name}`);
  if (directory) await writeFile(resolve(directory, 'failure.txt'), `${error.stack}\n${error.diagnostics || ''}`, { mode: 0o600 });
  process.exitCode = 1;
} finally {
  if (db) await db.end();
  if (startAttempted && directory && binary) {
    try { await command(resolve(binary, 'pg_ctl.exe'), ['-D', resolve(directory, 'data'), '-m', 'fast', '-w', 'stop'], directory); }
    catch { console.error('NATIVE_STOP_NOT_CONFIRMED: inspect the owned run directory.'); process.exitCode = 1; }
  }
}
