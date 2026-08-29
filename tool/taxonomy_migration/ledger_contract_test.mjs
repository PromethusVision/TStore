#!/usr/bin/env node
import {
  SUPABASE_LEDGER_CONTRACT, check, expectedMigrationLedgerRows,
  parseRepositoryMigrationFilename, validateMigrationLedgerRows,
} from './lib.mjs';

async function rejects(name, expectedMessage, operation) {
  try {
    await operation();
  } catch (error) {
    const message = String(error.message);
    check(message.includes(expectedMessage), `LEDGER_TEST_WRONG_ERROR:${name}:${message}`);
    return { name, result: 'PASS', rejected_with: message };
  }
  throw new Error(`LEDGER_TEST_DID_NOT_FAIL:${name}`);
}

const repositoryFiles = SUPABASE_LEDGER_CONTRACT.map((row) => row.repository_file);
const expected = expectedMigrationLedgerRows(repositoryFiles);
const first = expected[0];
const results = [];

validateMigrationLedgerRows(expected, expected);
results.push({ name: 'exact_9_version_name_pairs', result: 'PASS' });

const reordered = [...expected].reverse();
validateMigrationLedgerRows(reordered, expected);
results.push({ name: 'reordered_exact_pairs', result: 'PASS' });

results.push(await rejects('same_version_wrong_name', 'MIGRATION_LEDGER_PAIR_MISMATCH', () => {
  const rows = structuredClone(expected);
  rows[0].name = '0001_wrong_name';
  return validateMigrationLedgerRows(rows, expected);
}));
results.push(await rejects('same_name_wrong_version', 'MIGRATION_LEDGER_PAIR_MISMATCH', () => {
  const rows = structuredClone(expected);
  rows[0].version = '20990101010101';
  return validateMigrationLedgerRows(rows, expected);
}));
results.push(await rejects('missing_migration', 'MIGRATION_LEDGER_PAIR_MISMATCH', () => (
  validateMigrationLedgerRows(expected.slice(1), expected)
)));
results.push(await rejects('unexpected_migration', 'MIGRATION_LEDGER_PAIR_MISMATCH', () => (
  validateMigrationLedgerRows([
    ...expected,
    { version: '20991231235959', name: '9999_unexpected_migration' },
  ], expected)
)));
results.push(await rejects('duplicate_version', 'DUPLICATE_LEDGER_VERSION', () => (
  validateMigrationLedgerRows([
    ...expected,
    { version: first.version, name: '9998_duplicate_version' },
  ], expected)
)));
results.push(await rejects('duplicate_name', 'DUPLICATE_LEDGER_NAME', () => (
  validateMigrationLedgerRows([
    ...expected,
    { version: '20991231235958', name: first.name },
  ], expected)
)));
results.push(await rejects('duplicate_pair', 'DUPLICATE_LEDGER_PAIR', () => (
  validateMigrationLedgerRows([...expected, first], expected)
)));
results.push(await rejects('full_filename_in_name', 'MALFORMED_LEDGER_NAME', () => {
  const rows = structuredClone(expected);
  rows[0].name = first.repository_file;
  return validateMigrationLedgerRows(rows, expected);
}));
results.push(await rejects('malformed_ledger_row', 'MALFORMED_LEDGER_VERSION', () => {
  const rows = structuredClone(expected);
  rows[0].version = 'malformed';
  return validateMigrationLedgerRows(rows, expected);
}));
results.push(await rejects('malformed_repository_filename', 'MALFORMED_MIGRATION_FILENAME', () => (
  parseRepositoryMigrationFilename('202608120001_0001_bad.sql')
)));
results.push(await rejects('repository_path_forbidden', 'MIGRATION_FILENAME_PATH_FORBIDDEN', () => (
  parseRepositoryMigrationFilename('supabase/migrations/20260812000100_0001_core_auth_catalog.sql')
)));

check(results.every((item) => item.result === 'PASS'), 'LEDGER_CONTRACT_TEST_FAILURE');
process.stdout.write(`${JSON.stringify({
  status: 'PASS',
  baseline_pairs: expected.length,
  cases: results.length,
  results,
  remote_access_performed: false,
}, null, 2)}\n`);
