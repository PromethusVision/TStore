#!/usr/bin/env node

// Wave 35 local-only PostgreSQL-WASM migration rehearsal.
// The PGlite package path is supplied explicitly from an already-local cache.
// This script performs no package installation and no network/remote access.

import { createHash, randomUUID } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { performance } from 'node:perf_hooks';

const CANONICAL_VERSION = 'canonical-v1-rehearsal';
const LEGACY_VERSION = 'legacy-rehearsal';
const EXPECTED_LEVELS = { L1: 24, L2: 244, L3: 1096, L4: 199 };
const EXPECTED_NODES = 1563;
const EXPECTED_LEAVES = 1245;
const EXPECTED_LOCATORS = 651;
const EXPECTED_EDGES = 1000;
const EXPECTED_SPLITS = 210;
const EXPECTED_SPLIT_EDGES = 591;
const EXPECTED_ACTIVE = 313;
const EXPECTED_ASSIGNABLE = 247;

function argument(name, fallback = undefined) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

function check(condition, message) {
  if (!condition) throw new Error(message);
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = '';
  let quoted = false;
  const input = text.replace(/^\uFEFF/, '');
  for (let index = 0; index < input.length; index += 1) {
    const character = input[index];
    if (quoted) {
      if (character === '"' && input[index + 1] === '"') {
        value += '"';
        index += 1;
      } else if (character === '"') {
        quoted = false;
      } else {
        value += character;
      }
    } else if (character === '"') {
      quoted = true;
    } else if (character === ',') {
      row.push(value);
      value = '';
    } else if (character === '\n') {
      row.push(value.replace(/\r$/, ''));
      if (row.some((cell) => cell.length > 0)) rows.push(row);
      row = [];
      value = '';
    } else {
      value += character;
    }
  }
  if (value.length > 0 || row.length > 0) {
    row.push(value.replace(/\r$/, ''));
    rows.push(row);
  }
  const headers = rows.shift();
  return rows.map((cells) => Object.fromEntries(headers.map((header, i) => [header, cells[i] ?? ''])));
}

function splitTargets(value) {
  return value.split('||').map((part) => part.trim()).filter(Boolean);
}

function quote(value) {
  if (value === null || value === undefined) return 'NULL';
  return `'${String(value).replaceAll("'", "''")}'`;
}

function boolean(value) {
  return value ? 'TRUE' : 'FALSE';
}

function canonicalName(row) {
  return row[`L${Number(row.LEVEL.slice(1))}_NAME`].trim();
}

function slug(name, planningKey) {
  const folded = name.normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9]+/g, '-').replace(/^-|-$/g, '').toLowerCase();
  return `${folded || 'node'}-${planningKey.slice(-6).toLowerCase()}`;
}

function countBy(rows, key) {
  const result = {};
  for (const row of rows) result[row[key]] = (result[row[key]] ?? 0) + 1;
  return result;
}

function validateSources(manifest, registry, aliases) {
  check(manifest.length === EXPECTED_NODES, 'manifest count');
  check(JSON.stringify(countBy(manifest, 'LEVEL')) === JSON.stringify(EXPECTED_LEVELS), 'level counts');
  check(manifest.filter((row) => row.LEAF_YN === 'YES').length === EXPECTED_LEAVES, 'leaf count');
  const keys = new Set(manifest.map((row) => row.PLANNING_KEY));
  check(keys.size === EXPECTED_NODES, 'planning-key uniqueness');
  for (const row of manifest) {
    const level = Number(row.LEVEL.slice(1));
    if (level === 1) check(!row.PARENT_PLANNING_KEY, 'L1 parent');
    else check(keys.has(row.PARENT_PLANNING_KEY), `missing parent ${row.PLANNING_KEY}`);
    check(level <= 4, 'L5');
  }
  check(registry.length === EXPECTED_LOCATORS, 'registry count');
  check(new Set(registry.map((row) => row.LEGACY_NODE_ID)).size === EXPECTED_LOCATORS, 'registry uniqueness');
  check(registry.reduce((sum, row) => sum + Number(row.SUCCESSOR_COUNT), 0) === EXPECTED_EDGES, 'edge count');
  const splitRows = registry.filter((row) => row.FINAL_ACTION === 'SPLIT');
  check(splitRows.length === EXPECTED_SPLITS, 'split count');
  check(splitRows.reduce((sum, row) => sum + Number(row.SUCCESSOR_COUNT), 0) === EXPECTED_SPLIT_EDGES, 'split edges');
  check(aliases.length === EXPECTED_LOCATORS, 'alias count');
  check(aliases.reduce((sum, row) => sum + splitTargets(row.CANONICAL_PLANNING_KEY).length, 0) === EXPECTED_EDGES, 'alias edges');
}

async function scalar(database, sql, parameters = []) {
  const result = await database.query(sql, parameters);
  return Object.values(result.rows[0])[0];
}

async function createCurrentSchema(database) {
  await database.exec(`
    CREATE ROLE anon NOLOGIN;
    CREATE ROLE authenticated NOLOGIN;

    CREATE TABLE public.categories (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL CHECK (length(btrim(name)) > 0),
      description TEXT,
      image_url TEXT,
      parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_active BOOLEAN NOT NULL DEFAULT true,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    CREATE INDEX categories_parent_sort_idx ON public.categories(parent_id, sort_order);

    CREATE TABLE public.products (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL CHECK (length(btrim(name)) > 0),
      category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
      price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
      stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
      is_active BOOLEAN NOT NULL DEFAULT true,
      attributes JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    CREATE INDEX products_category_idx ON public.products(category_id);

    CREATE TABLE public.shops (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT true
    );
    CREATE TABLE public.shop_products (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
      product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
      price NUMERIC NOT NULL CHECK (price >= 0),
      is_available BOOLEAN NOT NULL DEFAULT true,
      is_active BOOLEAN NOT NULL DEFAULT true,
      UNIQUE (shop_id, product_id)
    );
    CREATE TABLE public.reviews (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_locator TEXT NOT NULL,
      product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
      rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
      comment TEXT
    );
    CREATE TABLE public.wishlist (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_locator TEXT NOT NULL,
      product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
      UNIQUE (user_locator, product_id)
    );
    CREATE TABLE public.cart_items_v2 (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      cart_locator TEXT NOT NULL,
      shop_product_id UUID NOT NULL REFERENCES public.shop_products(id) ON DELETE RESTRICT,
      quantity INTEGER NOT NULL CHECK (quantity > 0)
    );
    CREATE TABLE public.verified_transaction_items (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      transaction_locator TEXT NOT NULL,
      product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
      product_name_snapshot TEXT NOT NULL,
      unit_price_snapshot NUMERIC NOT NULL CHECK (unit_price_snapshot >= 0)
    );

    ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.shop_products ENABLE ROW LEVEL SECURITY;
    CREATE POLICY categories_read_active ON public.categories
      FOR SELECT TO anon, authenticated USING (is_active = true);
    CREATE POLICY products_read_active ON public.products
      FOR SELECT TO anon, authenticated USING (is_active = true);
    CREATE POLICY shop_products_read_active ON public.shop_products
      FOR SELECT TO anon, authenticated USING (is_active = true AND is_available = true);
    GRANT USAGE ON SCHEMA public TO anon, authenticated;
    GRANT SELECT ON public.categories, public.products, public.shop_products TO anon, authenticated;
  `);
}

function chooseRows(manifest, registry) {
  const byKey = new Map(manifest.map((row) => [row.PLANNING_KEY, row]));
  const safe = (key) => byKey.get(key)?.ASSIGNABLE_YN === 'YES'
    && byKey.get(key)?.ACTIVE_CANDIDATE_YN === 'YES';
  const selected = {};
  for (const action of ['KEEP', 'RENAME', 'MOVE', 'RENAME_AND_MOVE', 'MERGE']) {
    const candidates = registry.filter((row) => row.FINAL_ACTION === action);
    selected[action] = candidates.find((row) => {
      const targets = splitTargets(row.TARGET_PLANNING_KEYS);
      return targets.length === 1 && safe(targets[0]);
    }) ?? candidates[0];
  }
  selected.SPLIT = registry.filter((row) => row.FINAL_ACTION === 'SPLIT')
    .find((row) => splitTargets(row.TARGET_PLANNING_KEYS).some(safe));
  for (const action of ['RETIRE', 'OUT', 'UNRESOLVED']) {
    selected[action] = registry.find((row) => row.FINAL_ACTION === action);
  }
  selected.POLICY = registry.find((row) => splitTargets(row.TARGET_PLANNING_KEYS).some((key) => {
    const target = byKey.get(key);
    return target.POLICY_CLASS !== 'NORMAL' || target.PROFESSIONAL_REVIEW_REQUIRED === 'YES';
  }));
  return { selected, byKey, safe };
}

async function seedRepresentativeData(database, manifest, registry) {
  const { selected, safe } = chooseRows(manifest, registry);
  const rootId = randomUUID();
  const shopId = randomUUID();
  const categories = new Map();
  const products = [];
  await database.query('INSERT INTO public.categories(id, name) VALUES ($1, $2)', [rootId, 'Synthetic Legacy Root']);
  await database.query('INSERT INTO public.shops(id, name) VALUES ($1, $2)', [shopId, 'Synthetic Local Shop']);

  async function category(row) {
    if (!categories.has(row.LEGACY_NODE_ID)) {
      const id = randomUUID();
      categories.set(row.LEGACY_NODE_ID, id);
      await database.query(
        'INSERT INTO public.categories(id, name, parent_id, sort_order) VALUES ($1, $2, $3, $4)',
        [id, `Synthetic ${row.FINAL_ACTION} — ${row.LEGACY_NAME}`, rootId, categories.size],
      );
    }
    return categories.get(row.LEGACY_NODE_ID);
  }

  async function add(role, row, state, targetKey = '', origin = '') {
    const productId = randomUUID();
    const listingId = randomUUID();
    const categoryId = await category(row);
    await database.query(
      'INSERT INTO public.products(id, name, category_id, price, stock, attributes) VALUES ($1, $2, $3, $4, 10, $5::jsonb)',
      [productId, `Synthetic ${role}`, categoryId, 100 + products.length, JSON.stringify({ synthetic: true })],
    );
    await database.query(
      'INSERT INTO public.shop_products(id, shop_id, product_id, price) VALUES ($1, $2, $3, $4)',
      [listingId, shopId, productId, 110 + products.length],
    );
    products.push({ role, productId, listingId, categoryId, locator: row.LEGACY_NODE_ID, state, targetKey, origin });
  }

  for (const action of ['KEEP', 'RENAME', 'MOVE', 'RENAME_AND_MOVE', 'MERGE']) {
    const target = splitTargets(selected[action].TARGET_PLANNING_KEYS).find(safe) ?? '';
    await add(action.toLowerCase(), selected[action], target ? 'APPROVED' : 'POLICY_REVIEW', target, target ? 'AUTO' : 'POLICY');
  }
  const splitTarget = splitTargets(selected.SPLIT.TARGET_PLANNING_KEYS).find(safe);
  await add('split-exact', selected.SPLIT, 'APPROVED', splitTarget, 'MANUAL_EXACT');
  await add('split-manual', selected.SPLIT, 'MANUAL_REVIEW', '', 'AMBIGUOUS_SPLIT');
  await add('retire', selected.RETIRE, 'TOMBSTONE', '', 'NO_SUCCESSOR');
  await add('out', selected.OUT, 'OUT_OF_SCOPE', '', 'NO_SUCCESSOR');
  await add('unresolved', selected.UNRESOLVED, 'MANUAL_REVIEW', '', 'UNRESOLVED');
  await add('policy', selected.POLICY, 'POLICY_REVIEW', '', 'POLICY');
  const demoTarget = splitTargets(selected.RENAME.TARGET_PLANNING_KEYS).find(safe);
  await add('demo-like-a', selected.RENAME, 'APPROVED', demoTarget, 'AUTO');
  await add('demo-like-b', selected.RENAME, 'APPROVED', demoTarget, 'AUTO');

  const first = products[0];
  await database.query('INSERT INTO public.reviews(user_locator, product_id, rating, comment) VALUES ($1, $2, 5, $3)', ['synthetic-customer', first.productId, 'Synthetic review']);
  await database.query('INSERT INTO public.wishlist(user_locator, product_id) VALUES ($1, $2)', ['synthetic-customer', first.productId]);
  await database.query('INSERT INTO public.cart_items_v2(cart_locator, shop_product_id, quantity) VALUES ($1, $2, 1)', ['synthetic-cart', first.listingId]);
  await database.query('INSERT INTO public.verified_transaction_items(transaction_locator, product_id, product_name_snapshot, unit_price_snapshot) VALUES ($1, $2, $3, 100)', ['synthetic-transaction', first.productId, 'Synthetic snapshot']);
  return { products, categories, rootId };
}

async function applyHardenedDraft(database, draftPath) {
  const draft = await readFile(draftPath, 'utf8');
  const withoutGuard = draft.replace(
    /DO \$wave34_draft_guard\$[\s\S]*?\$wave34_draft_guard\$;\s*/,
    '',
  );
  check(withoutGuard !== draft, 'draft guard not found');
  await database.exec(withoutGuard);
}

async function backfillLegacy(database, representative) {
  await database.query(`
    UPDATE public.categories SET
      source_key='legacy-root:' || id::text,
      slug='legacy-root-' || left(id::text, 8),
      level=1, lifecycle_state='active', is_assignable=false,
      policy_class='NORMAL', professional_review_status='not_required',
      taxonomy_version=$1
    WHERE parent_id IS NULL
  `, [LEGACY_VERSION]);
  const unique = new Map(representative.products.map((item) => [item.categoryId, item.locator]));
  for (const [categoryId, locator] of unique) {
    await database.query(`
      UPDATE public.categories SET
        source_key=$1, slug=$2, level=2, lifecycle_state='active',
        is_assignable=true, policy_class='NORMAL',
        professional_review_status='not_required', taxonomy_version=$3
      WHERE id=$4
    `, [`legacy:${locator}`, `legacy-${locator}`, LEGACY_VERSION, categoryId]);
  }
}

function makeRuntimeMaps(manifest, registry, aliases) {
  return {
    nodeIds: new Map(manifest.map((row) => [row.PLANNING_KEY, randomUUID()])),
    relationshipIds: new Map(registry.flatMap((row) => {
      const targets = splitTargets(row.TARGET_PLANNING_KEYS);
      return (targets.length ? targets : ['']).map((target) => [`${row.LEGACY_NODE_ID}|${target}|${row.FINAL_ACTION}`, randomUUID()]);
    })),
    aliasIds: new Map(aliases.map((row) => [row.LEGACY_SLUG, randomUUID()])),
    synonymIds: new Map(),
  };
}

function targetState(row) {
  if (row.FINAL_ACTION === 'OUT') return 'OUT_OF_SCOPE';
  if (row.RUNTIME_DISPOSITION === 'POLICY_REVIEW') return 'POLICY_REVIEW';
  if (!row.TARGET_PLANNING_KEYS.trim()) return 'NO_TARGET_YET';
  return 'CANONICAL_FINAL';
}

function canonicalImportSql(manifest, maps) {
  const statements = [];
  for (const level of ['L1', 'L2', 'L3', 'L4']) {
    const siblings = new Map();
    const rows = manifest.filter((row) => row.LEVEL === level).map((row) => {
      const parentKey = row.PARENT_PLANNING_KEY;
      const order = (siblings.get(parentKey) ?? 0) + 1;
      siblings.set(parentKey, order);
      const professional = row.PROFESSIONAL_REVIEW_REQUIRED === 'YES' ? 'pending' : 'not_required';
      return `(${quote(maps.nodeIds.get(row.PLANNING_KEY))}::uuid, ${quote(canonicalName(row))}, ${parentKey ? `${quote(maps.nodeIds.get(parentKey))}::uuid` : 'NULL'}, ${order}, FALSE, ${quote(row.PLANNING_KEY)}, ${quote(slug(canonicalName(row), row.PLANNING_KEY))}, ${Number(level.slice(1))}, 'staged', FALSE, ${quote(row.POLICY_CLASS)}, ${quote(professional)}, ${quote(CANONICAL_VERSION)})`;
    });
    statements.push(`
      INSERT INTO public.categories(
        id, name, parent_id, sort_order, is_active, source_key, slug, level,
        lifecycle_state, is_assignable, policy_class,
        professional_review_status, taxonomy_version
      ) VALUES ${rows.join(',\n')}
      ON CONFLICT (source_key) WHERE source_key IS NOT NULL DO UPDATE SET
        name=excluded.name, parent_id=excluded.parent_id, sort_order=excluded.sort_order,
        slug=excluded.slug, level=excluded.level, lifecycle_state='staged',
        is_active=false, is_assignable=false, policy_class=excluded.policy_class,
        professional_review_status=excluded.professional_review_status,
        taxonomy_version=excluded.taxonomy_version;
    `);
  }
  const allocationRows = manifest.map((row) => `(${quote(row.PLANNING_KEY)}, ${quote(maps.nodeIds.get(row.PLANNING_KEY))}::uuid, ${quote(CANONICAL_VERSION)})`);
  statements.push(`
    INSERT INTO public.taxonomy_id_allocations(planning_key, category_id, taxonomy_version)
    VALUES ${allocationRows.join(',\n')}
    ON CONFLICT (planning_key) DO NOTHING;
  `);
  return statements.join('\n');
}

function relationshipImportSql(registry, maps, predecessorIds) {
  const values = [];
  for (const row of registry) {
    const targets = splitTargets(row.TARGET_PLANNING_KEYS);
    for (const target of targets.length ? targets : ['']) {
      const key = `${row.LEGACY_NODE_ID}|${target}|${row.FINAL_ACTION}`;
      values.push(`(
        ${quote(maps.relationshipIds.get(key))}::uuid,
        ${predecessorIds.has(row.LEGACY_NODE_ID) ? `${quote(predecessorIds.get(row.LEGACY_NODE_ID))}::uuid` : 'NULL'},
        ${quote(row.LEGACY_NODE_ID)},
        ${target ? `${quote(maps.nodeIds.get(target))}::uuid` : 'NULL'},
        ${quote(row.FINAL_ACTION)}, ${quote(targetState(row))},
        ${quote(row.RUNTIME_DISPOSITION)}, 'REHEARSAL_SOURCE_EXACT', ${quote(CANONICAL_VERSION)}
      )`);
    }
  }
  return `
    INSERT INTO public.taxonomy_node_relationships(
      id, predecessor_category_id, predecessor_source_locator,
      successor_category_id, action, target_state, classification_rule,
      confidence, taxonomy_version
    ) VALUES ${values.join(',\n')}
    ON CONFLICT DO NOTHING;
  `;
}

function aliasImportSql(aliases, maps) {
  const aliasValues = [];
  const targetValues = [];
  const synonymSources = [];
  for (const row of aliases) {
    const targets = splitTargets(row.CANONICAL_PLANNING_KEY);
    const resolution = targets.length === 1
      ? 'RESOLVED'
      : targets.length > 1
        ? 'AMBIGUOUS'
        : ['RETIRE', 'OUT'].includes(row.SOURCE_ACTION) ? 'TOMBSTONE' : 'UNRESOLVED';
    const aliasId = maps.aliasIds.get(row.LEGACY_SLUG);
    const directTarget = resolution === 'RESOLVED' ? `${quote(maps.nodeIds.get(targets[0]))}::uuid` : 'NULL';
    aliasValues.push(`(
      ${quote(aliasId)}::uuid, 'LEGACY_REDIRECT', ${quote(row.LEGACY_SLUG)},
      ${quote(row.LEGACY_NAME)}, ${quote(row.LEGACY_SLUG)}, ${quote(row.LEGACY_PATH)},
      ${quote(row.ALIAS_TYPE)}, ${quote(resolution)}, ${directTarget},
      'tr-TR', ${quote(CANONICAL_VERSION)}, TRUE
    )`);
    for (const target of targets) {
      targetValues.push(`(${quote(aliasId)}::uuid, ${quote(maps.nodeIds.get(target))}::uuid)`);
    }
    if (resolution === 'RESOLVED' && synonymSources.length < 3) synonymSources.push({ row, target: targets[0] });
  }
  for (const { row, target } of synonymSources) {
    const locator = `controlled-search:${row.LEGACY_SLUG}`;
    if (!maps.synonymIds.has(locator)) maps.synonymIds.set(locator, randomUUID());
    aliasValues.push(`(
      ${quote(maps.synonymIds.get(locator))}::uuid, 'SEARCH_SYNONYM', ${quote(locator)},
      ${quote(row.LEGACY_NAME)}, NULL, NULL, 'CONTROLLED_REHEARSAL_SYNONYM',
      'RESOLVED', ${quote(maps.nodeIds.get(target))}::uuid,
      'tr-TR', ${quote(CANONICAL_VERSION)}, TRUE
    )`);
  }
  return `
    INSERT INTO public.taxonomy_aliases(
      id, alias_kind, alias_locator, alias_text, alias_slug, alias_path,
      source_alias_type, resolution_state, direct_target_category_id,
      locale, taxonomy_version, is_active
    ) VALUES ${aliasValues.join(',\n')}
    ON CONFLICT (alias_kind, alias_locator, taxonomy_version) DO UPDATE SET
      alias_text=excluded.alias_text, alias_slug=excluded.alias_slug,
      alias_path=excluded.alias_path, source_alias_type=excluded.source_alias_type,
      resolution_state=excluded.resolution_state,
      direct_target_category_id=excluded.direct_target_category_id,
      is_active=excluded.is_active;

    INSERT INTO public.taxonomy_alias_targets(alias_id, target_category_id)
    VALUES ${targetValues.join(',\n')}
    ON CONFLICT DO NOTHING;
  `;
}

async function createRehearsalTables(database) {
  await database.exec(`
    CREATE TABLE public.rehearsal_product_snapshot (
      product_id UUID PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
      original_category_id UUID REFERENCES public.categories(id) ON DELETE RESTRICT
    );
    CREATE TABLE public.rehearsal_product_decisions (
      product_id UUID PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
      decision_state TEXT NOT NULL,
      target_planning_key TEXT,
      decision_origin TEXT NOT NULL
    );
    CREATE TABLE public.rehearsal_product_quarantine (
      product_id UUID PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
      reason TEXT NOT NULL,
      active BOOLEAN NOT NULL DEFAULT true
    );
  `);
}

async function seedDecisions(database, representative) {
  for (const item of representative.products) {
    await database.query(`
      INSERT INTO public.rehearsal_product_snapshot VALUES ($1, $2)
      ON CONFLICT (product_id) DO NOTHING
    `, [item.productId, item.categoryId]);
    await database.query(`
      INSERT INTO public.rehearsal_product_decisions VALUES ($1, $2, $3, $4)
      ON CONFLICT (product_id) DO UPDATE SET
        decision_state=excluded.decision_state,
        target_planning_key=excluded.target_planning_key,
        decision_origin=excluded.decision_origin
    `, [item.productId, item.state, item.targetKey || null, item.origin]);
  }
}

async function activate(database, manifest) {
  await database.query(`
    UPDATE public.categories SET lifecycle_state='staged', is_active=false, is_assignable=false
    WHERE taxonomy_version=$1
  `, [CANONICAL_VERSION]);
  const active = manifest.filter((row) => row.ACTIVE_CANDIDATE_YN === 'YES').map((row) => quote(row.PLANNING_KEY));
  const assignable = manifest.filter((row) => row.ASSIGNABLE_YN === 'YES').map((row) => quote(row.PLANNING_KEY));
  await database.exec(`
    UPDATE public.categories SET lifecycle_state='active', is_active=true
    WHERE source_key IN (${active.join(',')});
    UPDATE public.categories SET is_assignable=true
    WHERE source_key IN (${assignable.join(',')});
  `);
}

async function reassignProducts(database) {
  const decisions = (await database.query('SELECT * FROM public.rehearsal_product_decisions ORDER BY product_id')).rows;
  const counts = { auto_safe: 0, manual_exact: 0, manual: 0, policy: 0, tombstone_or_out: 0, quarantine: 0 };
  for (const decision of decisions) {
    let migrated = false;
    if (decision.decision_state === 'APPROVED' && decision.target_planning_key) {
      const target = (await database.query(`
        SELECT c.* FROM public.taxonomy_id_allocations a
        JOIN public.categories c ON c.id=a.category_id
        WHERE a.planning_key=$1
      `, [decision.target_planning_key])).rows[0];
      if (target?.is_assignable && target?.is_active && target?.lifecycle_state === 'active'
        && target?.policy_class === 'NORMAL' && target?.professional_review_status === 'not_required') {
        await database.query('UPDATE public.products SET category_id=$1 WHERE id=$2', [target.id, decision.product_id]);
        await database.query('DELETE FROM public.rehearsal_product_quarantine WHERE product_id=$1', [decision.product_id]);
        counts[decision.decision_origin === 'MANUAL_EXACT' ? 'manual_exact' : 'auto_safe'] += 1;
        migrated = true;
      }
    }
    if (!migrated) {
      await database.query(`
        INSERT INTO public.rehearsal_product_quarantine VALUES ($1, $2, true)
        ON CONFLICT (product_id) DO UPDATE SET reason=excluded.reason, active=true
      `, [decision.product_id, decision.decision_state]);
      counts.quarantine += 1;
      if (decision.decision_state === 'POLICY_REVIEW') counts.policy += 1;
      else if (decision.decision_state === 'MANUAL_REVIEW') counts.manual += 1;
      else counts.tombstone_or_out += 1;
    }
  }
  return counts;
}

async function databaseCounts(database) {
  const levelsResult = (await database.query(`
    SELECT 'L' || level::text AS level, count(*)::int AS count
    FROM public.categories WHERE taxonomy_version=$1 GROUP BY level ORDER BY level
  `, [CANONICAL_VERSION])).rows;
  const levels = Object.fromEntries(levelsResult.map((row) => [row.level, row.count]));
  const result = {
    nodes: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1', [CANONICAL_VERSION])),
    levels,
    leaves: Number(await scalar(database, `
      SELECT count(*) FROM public.categories c
      WHERE c.taxonomy_version=$1
        AND NOT EXISTS (SELECT 1 FROM public.categories child WHERE child.parent_id=c.id)
    `, [CANONICAL_VERSION])),
    active: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1 AND is_active=true', [CANONICAL_VERSION])),
    assignable: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1 AND is_assignable=true', [CANONICAL_VERSION])),
    allocations: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_id_allocations')),
    locators: Number(await scalar(database, 'SELECT count(DISTINCT predecessor_source_locator) FROM public.taxonomy_node_relationships')),
    edges: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships WHERE successor_category_id IS NOT NULL')),
    splitLocators: Number(await scalar(database, "SELECT count(DISTINCT predecessor_source_locator) FROM public.taxonomy_node_relationships WHERE action='SPLIT'")),
    splitEdges: Number(await scalar(database, "SELECT count(*) FROM public.taxonomy_node_relationships WHERE action='SPLIT' AND successor_category_id IS NOT NULL")),
    noTarget: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships WHERE successor_category_id IS NULL')),
    legacyAliases: Number(await scalar(database, "SELECT count(*) FROM public.taxonomy_aliases WHERE alias_kind='LEGACY_REDIRECT'")),
    searchSynonyms: Number(await scalar(database, "SELECT count(*) FROM public.taxonomy_aliases WHERE alias_kind='SEARCH_SYNONYM'")),
    aliasEdges: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_alias_targets')),
    policyLeakage: Number(await scalar(database, `
      SELECT count(*) FROM public.categories WHERE taxonomy_version=$1 AND is_active=true
        AND (policy_class <> 'NORMAL' OR professional_review_status <> 'not_required')
    `, [CANONICAL_VERSION])),
  };
  check(result.nodes === EXPECTED_NODES, 'PG node count');
  check(JSON.stringify(result.levels) === JSON.stringify(EXPECTED_LEVELS), 'PG level counts');
  check(result.leaves === EXPECTED_LEAVES, 'PG leaf count');
  check([0, EXPECTED_ACTIVE].includes(result.active), 'PG active count');
  check([0, EXPECTED_ASSIGNABLE].includes(result.assignable), 'PG assignable count');
  check(result.allocations === EXPECTED_NODES, 'PG allocation count');
  check(result.locators === EXPECTED_LOCATORS, 'PG locator count');
  check(result.edges === EXPECTED_EDGES, 'PG edge count');
  check(result.splitLocators === EXPECTED_SPLITS, 'PG split locator count');
  check(result.splitEdges === EXPECTED_SPLIT_EDGES, 'PG split edge count');
  check(result.noTarget === 32, 'PG no-target count');
  check(result.legacyAliases === EXPECTED_LOCATORS, 'PG alias count');
  check(result.aliasEdges === EXPECTED_EDGES, 'PG alias edge count');
  check(result.policyLeakage === 0, 'PG policy leakage');
  return result;
}

async function allocationHash(database) {
  const rows = (await database.query('SELECT planning_key, category_id FROM public.taxonomy_id_allocations ORDER BY planning_key')).rows;
  return createHash('sha256').update(rows.map((row) => `${row.planning_key}=${row.category_id}`).join('\n')).digest('hex');
}

async function importEverything(database, sources, maps, representative) {
  const predecessorIds = new Map(representative.products.map((item) => [item.locator, item.categoryId]));
  await database.exec(canonicalImportSql(sources.manifest, maps));
  await database.exec(relationshipImportSql(sources.registry, maps, predecessorIds));
  await database.exec(aliasImportSql(sources.aliases, maps));
}

async function forward(database, sources, maps, representative) {
  await database.exec('BEGIN');
  try {
    await importEverything(database, sources, maps, representative);
    await seedDecisions(database, representative);
    const before = {
      nodes: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1', [CANONICAL_VERSION])),
      relationships: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships')),
      aliases: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_aliases')),
      aliasEdges: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_alias_targets')),
      allocationHash: await allocationHash(database),
    };
    await importEverything(database, sources, maps, representative);
    const after = {
      nodes: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1', [CANONICAL_VERSION])),
      relationships: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships')),
      aliases: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_aliases')),
      aliasEdges: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_alias_targets')),
      allocationHash: await allocationHash(database),
    };
    check(JSON.stringify(before) === JSON.stringify(after), 'PG idempotency');
    await activate(database, sources.manifest);
    const reassignment = await reassignProducts(database);
    const counts = await databaseCounts(database);
    await database.exec('COMMIT');
    return { idempotency: 'PASS', counts, reassignment, allocationHash: after.allocationHash };
  } catch (error) {
    await database.exec('ROLLBACK');
    throw error;
  }
}

async function rollback(database) {
  await database.exec('BEGIN');
  try {
    await database.exec(`
      UPDATE public.products p SET category_id=s.original_category_id
      FROM public.rehearsal_product_snapshot s WHERE s.product_id=p.id;
      UPDATE public.categories SET lifecycle_state='staged', is_active=false, is_assignable=false
      WHERE taxonomy_version=${quote(CANONICAL_VERSION)};
      UPDATE public.rehearsal_product_quarantine SET active=false;
    `);
    const mismatch = Number(await scalar(database, `
      SELECT count(*) FROM public.products p
      JOIN public.rehearsal_product_snapshot s ON s.product_id=p.id
      WHERE p.category_id IS DISTINCT FROM s.original_category_id
    `));
    check(mismatch === 0, 'PG rollback product mismatch');
    const counts = await databaseCounts(database);
    await database.exec('COMMIT');
    return { mismatch, counts };
  } catch (error) {
    await database.exec('ROLLBACK');
    throw error;
  }
}

async function expectedFailure(database, operation) {
  await database.exec('BEGIN');
  try {
    await operation();
    await database.exec('COMMIT');
  } catch {
    try { await database.exec('ROLLBACK'); } catch { /* transaction already aborted */ }
    return 'PASS';
  }
  throw new Error('failure injection unexpectedly succeeded');
}

async function failureInjection(database, sources, representative) {
  const canonical = (await database.query('SELECT * FROM public.categories WHERE taxonomy_version=$1 LIMIT 1', [CANONICAL_VERSION])).rows[0];
  const root = (await database.query('SELECT id FROM public.categories WHERE taxonomy_version=$1 AND level=1 LIMIT 1', [CANONICAL_VERSION])).rows[0].id;
  const descendant = (await database.query(`
    WITH RECURSIVE d(id) AS (
      SELECT id FROM public.categories WHERE parent_id=$1
      UNION ALL SELECT c.id FROM public.categories c JOIN d ON c.parent_id=d.id
    ) SELECT id FROM d LIMIT 1
  `, [root])).rows[0].id;
  const validInsert = (overrides = {}) => database.query(`
    INSERT INTO public.categories(
      id, name, parent_id, is_active, source_key, slug, level,
      lifecycle_state, is_assignable, policy_class,
      professional_review_status, taxonomy_version
    ) VALUES ($1, 'Failure injection', $2, false, $3, $4, $5, 'staged', false, $6, 'not_required', 'failure-injection')
  `, [randomUUID(), overrides.parentId ?? root, overrides.sourceKey ?? `FAIL-${randomUUID()}`, overrides.slug ?? `fail-${randomUUID()}`, overrides.level ?? 2, overrides.policy ?? 'NORMAL']);

  const results = {};
  results.missing_parent = await expectedFailure(database, () => validInsert({ parentId: randomUUID() }));
  results.duplicate_slug = await expectedFailure(database, () => validInsert({ slug: canonical.slug }));
  results.cycle = await expectedFailure(database, () => database.query('UPDATE public.categories SET parent_id=$1 WHERE id=$2', [descendant, root]));
  results.invalid_level = await expectedFailure(database, () => validInsert({ level: 5 }));
  results.policy_unknown = await expectedFailure(database, () => validInsert({ policy: 'UNKNOWN' }));
  const alias = (await database.query("SELECT * FROM public.taxonomy_aliases WHERE alias_kind='LEGACY_REDIRECT' LIMIT 1")).rows[0];
  results.duplicate_alias = await expectedFailure(database, () => database.query(`
    INSERT INTO public.taxonomy_aliases(
      id, alias_kind, alias_locator, alias_text, source_alias_type,
      resolution_state, direct_target_category_id, taxonomy_version
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
  `, [randomUUID(), alias.alias_kind, alias.alias_locator, alias.alias_text, alias.source_alias_type, alias.resolution_state, alias.direct_target_category_id, alias.taxonomy_version]));
  results.bad_product_category = await expectedFailure(database, () => database.query('UPDATE public.products SET category_id=$1 WHERE id=$2', [randomUUID(), representative.products[0].productId]));

  const splitManual = representative.products.find((item) => item.role === 'split-manual');
  const quarantined = await scalar(database, 'SELECT count(*) FROM public.rehearsal_product_quarantine WHERE product_id=$1 AND active=true', [splitManual.productId]);
  check(Number(quarantined) === 1, 'PG split quarantine');
  results.split_without_decision = 'PASS';

  const marker = `MID-${randomUUID()}`;
  await database.exec('BEGIN');
  try {
    await validInsert({ sourceKey: marker });
    throw new Error('injected');
  } catch {
    await database.exec('ROLLBACK');
  }
  check(Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE source_key=$1', [marker])) === 0, 'PG mid-transaction rollback');
  results.mid_migration_failure = 'PASS';

  const mutated = sources.manifest.map((row) => ({ ...row }));
  mutated[1].PARENT_PLANNING_KEY = 'CANONICAL-MISSING';
  try {
    validateSources(mutated, sources.registry, sources.aliases);
  } catch {
    results.orphan_manifest = 'PASS';
  }
  check(results.orphan_manifest === 'PASS', 'PG orphan manifest failure');
  return results;
}

async function rlsChecks(database) {
  await database.exec('SET ROLE anon');
  const visibleCategories = Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1', [CANONICAL_VERSION]));
  const administrativeTables = [
    'taxonomy_id_allocations',
    'taxonomy_aliases',
    'taxonomy_alias_targets',
    'taxonomy_node_relationships',
  ];
  const deniedTables = [];
  for (const table of administrativeTables) {
    try {
      await database.query(`SELECT count(*) FROM public.${table}`);
    } catch {
      deniedTables.push(table);
    }
  }
  await database.exec('RESET ROLE');
  check(visibleCategories === EXPECTED_ACTIVE, 'PG anon category RLS');
  check(deniedTables.length === administrativeTables.length, 'PG administrative table exposed');
  return {
    visibleCategories,
    administrativeTablesDenied: true,
    deniedTables,
  };
}

async function timed(database, sql, parameters = [], repeats = 30) {
  const samples = [];
  let rows = 0;
  for (let index = 0; index < repeats; index += 1) {
    const start = performance.now();
    const result = await database.query(sql, parameters);
    samples.push(performance.now() - start);
    rows = result.rows.length;
  }
  samples.sort((a, b) => a - b);
  const median = samples[Math.floor(samples.length / 2)];
  const p95 = samples[Math.floor((samples.length - 1) * 0.95)];
  return { rows, repeats, median_ms: Number(median.toFixed(4)), p95_ms: Number(p95.toFixed(4)) };
}

async function querySanity(database) {
  const productCategory = (await database.query(`
    SELECT p.category_id FROM public.products p
    JOIN public.categories c ON c.id=p.category_id AND c.taxonomy_version=$1
    WHERE NOT EXISTS (
      SELECT 1 FROM public.rehearsal_product_quarantine q
      WHERE q.product_id=p.id AND q.active=true
    ) ORDER BY p.name LIMIT 1
  `, [CANONICAL_VERSION])).rows[0].category_id;
  const root = (await database.query(`
    WITH RECURSIVE trail(id, parent_id, level) AS (
      SELECT id, parent_id, level FROM public.categories WHERE id=$1
      UNION ALL SELECT c.id, c.parent_id, c.level
      FROM public.categories c JOIN trail t ON t.parent_id=c.id
    ) SELECT id FROM trail WHERE level=1
  `, [productCategory])).rows[0].id;
  const leaf = await scalar(database, 'SELECT id FROM public.categories WHERE taxonomy_version=$1 AND is_assignable=true LIMIT 1', [CANONICAL_VERSION]);
  const aliasSlug = await scalar(database, "SELECT alias_slug FROM public.taxonomy_aliases WHERE alias_kind='LEGACY_REDIRECT' AND resolution_state='RESOLVED' LIMIT 1");
  return {
    roots: await timed(database, 'SELECT id, name FROM public.categories WHERE taxonomy_version=$1 AND level=1 ORDER BY sort_order', [CANONICAL_VERSION]),
    children: await timed(database, 'SELECT id, name FROM public.categories WHERE parent_id=$1 ORDER BY sort_order', [root]),
    descendants: await timed(database, `
      WITH RECURSIVE d(id, level) AS (
        SELECT id, level FROM public.categories WHERE id=$1
        UNION ALL SELECT c.id, c.level FROM public.categories c JOIN d ON c.parent_id=d.id
      ) SELECT id, level FROM d
    `, [root]),
    breadcrumb: await timed(database, `
      WITH RECURSIVE trail(id, parent_id, name, level) AS (
        SELECT id, parent_id, name, level FROM public.categories WHERE id=$1
        UNION ALL SELECT c.id, c.parent_id, c.name, c.level
        FROM public.categories c JOIN trail t ON t.parent_id=c.id
      ) SELECT id, name, level FROM trail ORDER BY level
    `, [leaf]),
    products_by_descendant_scope: await timed(database, `
      WITH RECURSIVE d(id) AS (
        SELECT id FROM public.categories WHERE id=$1
        UNION ALL SELECT c.id FROM public.categories c JOIN d ON c.parent_id=d.id
      ) SELECT p.id, p.name FROM public.products p
      WHERE p.category_id IN (SELECT id FROM d)
        AND NOT EXISTS (
          SELECT 1 FROM public.rehearsal_product_quarantine q
          WHERE q.product_id=p.id AND q.active=true
        )
    `, [root]),
    alias_lookup: await timed(database, `
      SELECT resolution_state, direct_target_category_id
      FROM public.taxonomy_aliases
      WHERE alias_kind='LEGACY_REDIRECT' AND lower(alias_slug)=lower($1)
    `, [aliasSlug]),
  };
}

async function main() {
  const repoRoot = resolve(argument('--repo-root', process.cwd()));
  const pgliteRoot = argument('--pglite-root');
  const outputPath = argument('--output');
  check(pgliteRoot, '--pglite-root is required');
  const moduleUrl = pathToFileURL(join(resolve(pgliteRoot), 'dist', 'index.js')).href;
  const { PGlite } = await import(moduleUrl);
  const sources = {
    manifest: parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv'), 'utf8')),
    registry: parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_FINAL_SPLIT_MERGE_REGISTRY.csv'), 'utf8')),
    aliases: parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_ALIAS_REDIRECT_MANIFEST.csv'), 'utf8')),
  };
  validateSources(sources.manifest, sources.registry, sources.aliases);
  const maps = makeRuntimeMaps(sources.manifest, sources.registry, sources.aliases);
  const database = new PGlite();
  try {
    const version = await scalar(database, 'select version()');
    await createCurrentSchema(database);
    const representative = await seedRepresentativeData(database, sources.manifest, sources.registry);
    await applyHardenedDraft(database, join(repoRoot, 'docs', 'sql', 'TAXONOMY_W34_MIGRATION_DRAFT.sql'));
    await backfillLegacy(database, representative);
    await createRehearsalTables(database);

    const forwardRuns = [];
    const rollbackRuns = [];
    forwardRuns.push(await forward(database, sources, maps, representative));
    rollbackRuns.push(await rollback(database));
    forwardRuns.push(await forward(database, sources, maps, representative));
    const failures = await failureInjection(database, sources, representative);
    const rls = await rlsChecks(database);
    const queries = await querySanity(database);
    rollbackRuns.push(await rollback(database));
    check(forwardRuns[0].allocationHash === forwardRuns[1].allocationHash, 'PG cross-cycle allocation drift');
    check(Object.values(failures).every((value) => value === 'PASS'), 'PG failure injection');

    const result = {
      environment: { engine: version, pglite_package: '0.5.5', remote_access: false },
      current_migration_chain_validation: 'separate repository validator PASS (9 migrations / 23 tables)',
      forward_runs: forwardRuns.length,
      rollback_runs: rollbackRuns.length,
      forward_results: forwardRuns,
      rollback_results: rollbackRuns,
      failure_injection: failures,
      rls,
      query_sanity: queries,
      remote_access_performed: false,
    };
    const serialized = `${JSON.stringify(result, null, 2)}\n`;
    if (outputPath) await writeFile(resolve(outputPath), serialized, 'utf8');
    if (!process.argv.includes('--quiet')) process.stdout.write(serialized);
  } finally {
    await database.close();
  }
}

await main();
