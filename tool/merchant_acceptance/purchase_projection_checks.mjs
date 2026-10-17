import assert from 'node:assert/strict';

export async function purchaseProjectionChecks(db) {
  const checks = [];
  const check = async (name, action) => {
    await action(); checks.push({name, result:'PASS'}); console.log('PASS '+name);
  };
  await check('purchase projection helper remains private to server modules', async () => {
    for (const role of ['anon','authenticated','service_role']) {
      const value = await db.query("SELECT has_function_privilege($1,'public._purchase_read_b(uuid)','EXECUTE') allowed", [role]);
      assert.equal(value.rows[0].allowed, false);
    }
    const helper = (await db.query("SELECT prosecdef,proconfig FROM pg_proc WHERE oid='public._purchase_read_b(uuid)'::regprocedure")).rows[0];
    assert.equal(helper.prosecdef, true);
    assert(helper.proconfig.some(v => v === 'search_path=""'));
  });
  await check('all existing purchase classifications omit customer and confirmer identifiers', async () => {
    const rows = (await db.query('SELECT public._purchase_read_b(id) p FROM public.verified_transactions')).rows;
    assert(rows.length > 0);
    for (const {p} of rows) {
      assert.equal('customer_user_id' in p, false);
      assert.equal('confirmed_by_user_id' in p, false);
      assert.equal('email' in p, false);
      assert.equal('phone' in p, false);
    }
    const kinds = new Set(rows.map(r => r.p.terms_classification));
    assert(kinds.has('quote_only_b_v1')); assert(kinds.has('coupon_checkout_e_v1'));
  });
  await check('minimized projection preserves original header, quantities and exact coupon arithmetic', async () => {
    const mismatches = await db.query(`SELECT count(*)::int n
      FROM public.verified_transactions v
      CROSS JOIN LATERAL (SELECT public._purchase_read_b(v.id) p) x
      WHERE x.p->>'id'<>v.id::text OR x.p->>'shop_id'<>v.shop_id::text
      OR (x.p->>'total_amount')::numeric<>v.total_amount
      OR (x.p->>'item_count')::int<>v.item_count
      OR jsonb_array_length(x.p->'items')<>(SELECT count(*) FROM public.verified_transaction_items i WHERE i.verified_transaction_id=v.id)
      OR (x.p->>'terms_classification'='coupon_checkout_e_v1'
        AND ((x.p->>'final_sale_minor')::bigint<>(x.p->>'ev_coupon_minor')::bigint+(x.p->>'customer_payment_minor')::bigint
          OR x.p->>'coupon_restoration_executed'<>'false'))`);
    assert.equal(mismatches.rows[0].n, 0);
  });
  return checks;
}
