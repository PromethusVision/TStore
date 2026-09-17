// The only remote transport. Importing this module performs no connection.
import { readFileSync, realpathSync } from 'node:fs';
import { isAbsolute, relative } from 'node:path';
import { spawnSync } from 'node:child_process';
import { PsqlSession, psqlFlags } from './session.mjs';
import { check, project, root, validateBackup } from './common.mjs';
import { verifyBundle } from './seal.mjs';

export function productionSession(options) {
  check(options.authorized === true, 'FUTURE_PRODUCTION_AUTHORIZATION_REQUIRED');
  check(options.project === project, 'TARGET_PROJECT');
  verifyBundle(options.bundleHash);
  for (const path of [options.psql, options.ca, options.passfile]) check(path && isAbsolute(path), 'ABSOLUTE_PRIVATE_INPUT_REQUIRED');
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !/^PG/i.test(key)));
  Object.assign(env, { PGHOST: `db.${project}.supabase.co`, PGPORT: '5432', PGDATABASE: 'postgres', PGUSER: 'postgres',
    PGSSLMODE: 'verify-full', PGSSLROOTCERT: options.ca, PGPASSFILE: options.passfile,
    PGCONNECT_TIMEOUT: '15', PGAPPNAME: 'w52jb-reviewed-0012', PGOPTIONS: '-c timezone=UTC -c datestyle=ISO' });
  const tool = spawnSync(options.psql, ['--version'], { encoding: 'utf8', windowsHide: true });
  check(tool.status === 0 && /\b17\.\d+/.test(tool.stdout), 'PSQL_17_REQUIRED');
  readFileSync(options.ca); // Existence/readability only; no credential content is read here.
  return new PsqlSession(options.psql, ['-h', env.PGHOST, '-p', '5432', '-U', 'postgres', '-d', 'postgres', ...psqlFlags],
    { kind: 'PRODUCTION_DIRECT_TLS_VERIFY_FULL', project_ref: project, verified: true, hostname: env.PGHOST }, env);
}

export function privateBackup(archive, metadata) {
  for (const path of [archive, metadata]) {
    check(path && isAbsolute(path), 'BACKUP_EXTERNAL_PATH_REQUIRED');
    const rel = relative(realpathSync(root), realpathSync(path));
    check(rel.startsWith('..') || isAbsolute(rel), 'BACKUP_MUST_BE_OUTSIDE_REPOSITORY');
  }
  return validateBackup(JSON.parse(readFileSync(metadata, 'utf8')), readFileSync(archive));
}
