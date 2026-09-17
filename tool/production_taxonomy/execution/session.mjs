// One persistent psql connection: checks, payload, ledger and commit share a transaction.
import { spawn } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { check, literal, safeError } from './common.mjs';

export const psqlFlags = ['-X', '-q', '-A', '-t', '-w', '-v', 'ON_ERROR_STOP=1', '-v', 'VERBOSITY=verbose', '-P', 'pager=off', '-f', '-'];
export class PsqlSession {
  constructor(command, args, transport, environment = process.env) {
    this.transport = Object.freeze(transport);
    this.pending = null; this.buffer = ''; this.stderr = ''; this.closed = false;
    this.child = spawn(command, args, { env: environment, windowsHide: true, stdio: ['pipe', 'pipe', 'pipe'] });
    this.child.stdout.setEncoding('utf8'); this.child.stderr.setEncoding('utf8');
    this.child.stdout.on('data', text => {
      this.buffer = (this.buffer + text).replaceAll('\r\n', '\n');
      if (!this.pending) return;
      const end = this.buffer.indexOf(this.pending.marker + '\n');
      if (end < 0) return;
      const output = this.buffer.slice(0, end).replaceAll('\r\n', '\n').trim();
      this.buffer = this.buffer.slice(end + this.pending.marker.length + 1);
      clearTimeout(this.pending.timer);
      const pending = this.pending; this.pending = null; pending.resolve(output);
    });
    this.child.stderr.on('data', text => { this.stderr = (this.stderr + text).slice(-8000); });
    const failed = () => {
      this.closed = true;
      if (this.pending) {
        clearTimeout(this.pending.timer);
        const error = new Error(this.stderr.match(/W52(?:JB|H)_[A-Z0-9_]+/)?.[0] ?? `W52JB_PSQL_${this.stderr.match(/ERROR:\s+([0-9A-Z]{5}):/)?.[1] ?? 'FAILED'}`);
        const pending = this.pending; this.pending = null; pending.reject(error);
      }
    };
    this.child.on('error', failed); this.child.on('exit', failed);
    this.child.stdin.on('error', failed);
  }
  async exec(sql) {
    check(!this.pending && !this.closed, 'SESSION_NOT_AVAILABLE');
    check(!/^\s*\\/m.test(sql), 'SQL_METACOMMAND_FORBIDDEN');
    this.stderr = '';
    const marker = `W52JB_END_${randomBytes(18).toString('hex')}`;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending = null; this.child.kill(); reject(new Error('W52JB_SESSION_TIMEOUT'));
      }, 180000);
      this.pending = { resolve, reject, marker, timer };
      this.child.stdin.write(`${sql.trimEnd()}\n;\n\\echo ${marker}\n`);
    });
  }
  async query(query, values = []) {
    const bound = query.replace(/\$(\d+)/g, (_, n) => literal(values[Number(n) - 1]));
    const output = await this.exec(`SELECT coalesce(jsonb_agg(to_jsonb(w52jb_q)), '[]'::jsonb) FROM (${bound}) w52jb_q;`);
    try { return { rows: JSON.parse(output) }; } catch { throw new Error('W52JB_QUERY_RESPONSE'); }
  }
  async close() {
    if (this.closed) return;
    try { await this.exec('ROLLBACK;'); } catch (error) { this.lastCloseError = safeError(error); }
    this.child.stdin.end();
  }
}
