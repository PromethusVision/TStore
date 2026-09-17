// No default operation and no generic apply-pending path. Never run remotely in W52J-B.
import { check, safeError } from './common.mjs';
import { productionSession, privateBackup } from './production.mjs';
import { apply0012, rollback0012, readPreflight, readPostflight } from './engine.mjs';

let db;
try {
  const [operation, ...args] = process.argv.slice(2);
  check(['preflight', 'apply-0012', 'postflight', 'rollback-0012'].includes(operation), 'EXPLICIT_OPERATION_REQUIRED');
  const options = {}; const allowed = ['project','bundle-hash','psql','ca','passfile','backup','backup-metadata'];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--production-authorized') { check(!options.authorized, 'DUPLICATE_OPTION'); options.authorized = true; continue; }
    const key = args[i].replace(/^--/, '');
    check(args[i].startsWith('--') && allowed.includes(key) && !Object.hasOwn(options,key) && args[i+1] && !args[i+1].startsWith('--'), 'INVALID_OPTION');
    options[key] = args[++i];
  }
  const backup = ['preflight','apply-0012'].includes(operation) ? privateBackup(options.backup, options['backup-metadata']) : null;
  db = productionSession({ ...options, bundleHash: options['bundle-hash'] });
  const result = operation === 'preflight' ? await readPreflight(db,backup) : operation === 'apply-0012' ? await apply0012(db,backup) : operation === 'postflight' ? await readPostflight(db) : await rollback0012(db);
  console.log(JSON.stringify({operation,...result}));
} catch (error) { console.error(JSON.stringify({result:'FAIL',code:safeError(error)})); process.exitCode=1; }
finally { if(db) await db.close(); }
