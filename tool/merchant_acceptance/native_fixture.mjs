// Fresh, owned loopback fixture for the actual Android application. Reuses the
// reviewed installation/cohort/publication contracts, never a hosted seed path.
import assert from 'node:assert/strict';
import {readFile, writeFile, mkdir} from 'node:fs/promises';
import {resolve, dirname} from 'node:path';
import {randomUUID, randomBytes} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {readRun, credentials, runtimeEvidence, root, command} from './local.mjs';
import {connect, migrate} from './fixture.mjs';
import {localUrl, requestJson} from './safety.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression, taxonomyExpression, loadDelta, schemaPlan, projectRef, projectUrl, digest} from './pilot_preparation_contract.mjs';
import {loadRepair, repairPlan} from './pilot_launch_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {cohortTemplate, observationSql} from './pilot_cohort_contract.mjs';
import {publicationTemplate, publicationObservationSql, loadPublication, publicationSchemaPlan, publicationSources} from './pilot_publication_contract.mjs';
import {verifiedInstalledProfile, mirrorInstalledPublicationProfile, installedSchemaMd5, installedReceipt} from './pilot_installed_profile.mjs';
import {installedCohortPlans, installedPublicationPlan} from './pilot_installed_contract.mjs';
import {fixtureBaselineCommit} from './pilot_ui_contract.mjs';

export async function nativeDatabase(run) {
  const status = await credentials(run);
  const url = localUrl(status.DB_URL, 'db');
  return {status, db: await connect({host: '127.0.0.1', port: Number(url.port),
    database: 'postgres', user: 'postgres', password: decodeURIComponent(url.password), ssl: false})};
}

export async function prepareNativeFixture(run) {
  const {status, db} = await nativeDatabase(run);
  try {
    // Exclusive directory also refuses accidental continuation of a partial run.
    const out = resolve(run.dir, 'native');
    await mkdir(out);
    const scalar = async sql => (await db.query(sql)).rows[0].value;
    const schema = () => scalar(`SELECT (${schemaExpression})::text value`);
    const apply = async plan => {
      await db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)", [plan.plan.sha256]);
      await db.query(plan.sql);
    };
    const observe = async sql => {
      const results = await db.query(sql);
      return JSON.parse(results.find(r => r.rows?.[0]?.observation_text).rows[0].observation_text);
    };
    const target = {project_ref: projectRef, project_url: projectUrl};
    const historical = resolve(out, 'historical');
    await mkdir(historical);
    for (const path of [...publicationSources, installedReceipt, 'docs/data/merchant_pilot_publication_acceptance.json']) {
      const content = await command('git', ['show', fixtureBaselineCommit + ':' + path]);
      await mkdir(dirname(resolve(historical, path)), {recursive: true});
      await writeFile(resolve(historical, path), content, {flag: 'wx'});
    }
    await verifiedInstalledProfile(historical);
    const migrations = await migrate(db, {coreOnly: true, baselineOnly: true});
    await mirrorHostedProfile(db);
    await apply(schemaPlan(target, await schema(), await loadDelta(root)));
    await mirrorPostAProfile(db);
    const prior = JSON.parse(await readFile(resolve(root, 'docs/data/merchant_pilot_test_installation.json'), 'utf8'));
    await apply(repairPlan(target, prior, await loadRepair(root)));
    await apply(publicationSchemaPlan(target, await loadPublication(root)));
    await mirrorInstalledPublicationProfile(db, historical);
    assert.equal(digest(await schema(), 'md5'), installedSchemaMd5);
    const request = (path, actor, body, method) =>
      requestJson(status.API_URL, path, actor?.token, status.ANON_KEY, body, method);
    const actors = [];
    for (let i = 0; i < 4; i++) {
      // Deliberately synthetic and easy for Android's ASCII input command.
      const login = {email: randomUUID() + '@example.invalid', password: randomBytes(24).toString('hex')};
      const created = await requestJson(status.API_URL, '/auth/v1/admin/users',
        status.SERVICE_ROLE_KEY, status.SERVICE_ROLE_KEY, {...login, email_confirm: true});
      assert.equal(created.status, 200);
      const signed = await request('/auth/v1/token?grant_type=password', null, login);
      assert.equal(signed.status, 200);
      actors.push({id: created.data.id, token: signed.data.access_token, login});
    }
    const [publisher, merchant, other, customer] = actors;
    const taxonomy = await scalar(`SELECT (${taxonomyExpression})::text value`);
    const category = categoryInventory(target, taxonomy).find(x => x.eligible).id;
    const intake = cohortTemplate();
    intake.accounts = [publisher, merchant, other].map((a, i) => ({
      slot: 'merchant-0' + (i + 1), role: 'merchant', user_id: a.id,
      identity_review_ref: 'synthetic-local-android-review'}));
    intake.accounts.push({slot: 'customer-01', role: 'customer', user_id: customer.id,
      identity_review_ref: 'synthetic-local-android-review'});
    intake.category_leaf_ids = [category];
    for (const plan of Object.values(installedCohortPlans(target, taxonomy, intake, await observe(observationSql(intake))))) {
      await apply(plan);
    }
    const publisherShop = randomUUID(), foreignShop = randomUUID();
    for (const [actor, id] of [[publisher, publisherShop], [other, foreignShop]]) {
      assert((await request('/rest/v1/shops', actor, {id, owner_user_id: actor.id, name: 'Native fixture shop'})).ok);
    }
    await db.query("NOTIFY pgrst,'reload schema'");
    let ready = false;
    for (let i = 0; i < 30; i++) {
      if ((await request('/rest/v1/rpc/merchant_catalog_categories_v1', publisher, {p_shop_id: publisherShop})).ok) {
        ready = true; break;
      }
      await new Promise(r => setTimeout(r, 200));
    }
    assert(ready);
    const product = randomUUID(), productName = 'Native pilot kalem';
    const submitted = await request('/rest/v1/rpc/merchant_submit_product_v1', publisher, {
      p_shop_id: publisherShop, p_request_id: randomUUID(),
      p_draft: {name: productName, brand: '', model: 'Native', variant: 'Mavi',
        gtin: '0000000000017', canonical_category_id: category, product_type: 'shared_catalog_product'}});
    assert(submitted.ok);
    const publication = {...publicationTemplate(), batch_id: randomUUID(),
      compatibility_review_ref: 'local-android-only', items: [{
        submission_id: submitted.data.submission.id, product_id: product, brand_id: null,
        create: true, kind: 'physical_good', review_ref: 'synthetic-local-android-review'}]};
    await apply(installedPublicationPlan(target, publication, await observe(publicationObservationSql(publication))));
    const notification = randomUUID(), foreignNotification = randomUUID();
    await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Native pilot bildirimi','Yerel prova','system'),($3,$4,'Foreign private notice','Gorunmemeli','system')",
      [notification, merchant.id, foreignNotification, other.id]);
    await writeFile(resolve(out, 'fixture.json'), JSON.stringify({
      kind: 'merchant-native-local-v1', project: run.project, url: status.API_URL,
      merchant: {...merchant.login, id: merchant.id}, other: {...other.login, id: other.id},
      customer: {...customer.login, id: customer.id}, product, productName,
      foreignShop, notification, foreignNotification,
    }, null, 2), {flag: 'wx', mode: 0o600});
    // Only the local anonymous key enters this disposable APK; no server key.
    await writeFile(resolve(out, 'build.json'), JSON.stringify({
      SUPABASE_DEVELOPMENT_URL: status.API_URL, SUPABASE_DEVELOPMENT_ANON_KEY: status.ANON_KEY,
    }), {flag: 'wx', mode: 0o600});
    await writeFile(resolve(out, 'services.json'), JSON.stringify({
      services: await runtimeEvidence(run), migrations, installed_schema_md5: installedSchemaMd5,
      input_scope: 'Four synthetic accounts and one physical product; owned loopback only',
    }, null, 2), {flag: 'wx'});
  } finally { await db.end(); }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  let run;
  try {
    assert.equal(process.argv.length, 3);
    run = await readRun(process.argv[2]);
    await prepareNativeFixture(run);
    console.log('NATIVE_FIXTURE_READY: owned loopback only; private inputs suppressed.');
  } catch (error) {
    if (run) await writeFile(resolve(run.dir, 'native-failure.txt'), error.stack + '\n' + (error.diagnostics ?? ''), {mode: 0o600});
    console.error('NATIVE_FIXTURE_FAILED: no remote fallback or reset.');
    process.exitCode = 1;
  }
}
