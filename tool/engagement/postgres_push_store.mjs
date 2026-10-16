// Server-only injected pg Pool; no connection URL, provider binding or auto-run.
// A dedicated transaction/connection per operation guarantees begin commits
// before its token can reach a provider. The pool must not be an open transaction.
export class PostgresPushStore {
  constructor(pool) { this.pool = pool; }
  async #call(name, args) {
    let client, failed = false;
    try {
      client = await this.pool.connect();
      await client.query('BEGIN ISOLATION LEVEL READ COMMITTED');
      await client.query("SET LOCAL statement_timeout='10s'");
      await client.query("SET LOCAL lock_timeout='5s'");
      await client.query('SET LOCAL ROLE service_role');
      const placeholders = args.map((_, i) => '$' + (i + 1)).join(',');
      const result = await client.query('SELECT public.' + name + '(' + placeholders + ') result', args);
      await client.query('COMMIT');
      return result.rows[0].result;
    } catch {
      failed = true;
      if (client) await client.query('ROLLBACK').catch(() => {});
      // Do not expose SQL detail (may contain sensitive parameters).
      throw new Error('push_store_unavailable');
    } finally { client?.release(failed ? new Error('push_store_unavailable') : undefined); }
  }
  page(notificationId, after = null) { return this.#call('push_dispatch_page_i0', [notificationId, after]); }
  claim(notificationId, installationId) { return this.#call('claim_push_dispatch_i0', [notificationId, installationId]); }
  begin(claimId) { return this.#call('begin_push_dispatch_i0', [claimId]); }
  finish(claimId, outcome, invalidToken = false) { return this.#call('finish_push_dispatch_i0', [claimId, outcome, invalidToken]); }
  read(claimId) { return this.#call('read_push_dispatch_i0', [claimId]); }
  find(notificationId, installationId, role) {
    return this.#call('read_push_dispatch_i0', [null, notificationId, installationId, role]);
  }
}
