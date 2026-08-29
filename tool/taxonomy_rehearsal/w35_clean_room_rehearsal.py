#!/usr/bin/env python3
"""Wave 35 local-only canonical taxonomy migration rehearsal.

This harness uses only Python's standard library and a disposable SQLite
database. It exercises relational/transactional migration behavior without
accessing Supabase, Development, Production, Auth, Storage, or Realtime.

SQLite is deliberately reported as a compatibility fallback, not as proof of
PostgreSQL DDL, RLS, function, or query-planner behavior.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sqlite3
import statistics
import tempfile
import time
import unicodedata
import uuid
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Callable, Iterable


CANONICAL_VERSION = "canonical-v1-rehearsal"
LEGACY_VERSION = "legacy-rehearsal"
EXPECTED_LEVELS = {"L1": 24, "L2": 244, "L3": 1096, "L4": 199}
EXPECTED_NODES = 1563
EXPECTED_LEAVES = 1245
EXPECTED_LEGACY_LOCATORS = 651
EXPECTED_SUCCESSOR_EDGES = 1000
EXPECTED_ACTIVE_CANDIDATES = 313
EXPECTED_ASSIGNABLE_CANDIDATES = 247
EXPECTED_ACTIONS = {
    "KEEP": 62,
    "RENAME": 223,
    "MOVE": 73,
    "RENAME_AND_MOVE": 44,
    "MERGE": 7,
    "SPLIT": 210,
    "RETIRE": 1,
    "OUT": 7,
    "UNRESOLVED": 24,
}
EXPECTED_SPLIT_EDGES = 591


class RehearsalError(RuntimeError):
    pass


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def split_targets(value: str) -> list[str]:
    return [item.strip() for item in value.split("||") if item.strip()]


def check(condition: bool, message: str) -> None:
    if not condition:
        raise RehearsalError(message)


def canonical_name(row: dict[str, str]) -> str:
    level = int(row["LEVEL"][1:])
    return row[f"L{level}_NAME"].strip()


def rehearsal_slug(name: str, planning_key: str) -> str:
    folded = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    folded = re.sub(r"[^a-zA-Z0-9]+", "-", folded).strip("-").lower()
    return f"{folded or 'node'}-{planning_key[-6:].lower()}"


def validate_sources(
    manifest: list[dict[str, str]],
    registry: list[dict[str, str]],
    aliases: list[dict[str, str]],
) -> dict[str, Any]:
    check(len(manifest) == EXPECTED_NODES, "canonical node count mismatch")
    keys = [row["PLANNING_KEY"] for row in manifest]
    check(len(set(keys)) == EXPECTED_NODES, "duplicate planning key")
    by_key = {row["PLANNING_KEY"]: row for row in manifest}
    levels = Counter(row["LEVEL"] for row in manifest)
    check(dict(levels) == EXPECTED_LEVELS, f"level counts mismatch: {levels}")
    check(
        sum(row["LEAF_YN"] == "YES" for row in manifest) == EXPECTED_LEAVES,
        "leaf count mismatch",
    )

    for row in manifest:
        level = int(row["LEVEL"][1:])
        parent_key = row["PARENT_PLANNING_KEY"].strip()
        if level == 1:
            check(not parent_key, f"L1 has parent: {row['PLANNING_KEY']}")
        else:
            check(parent_key in by_key, f"missing parent: {row['PLANNING_KEY']}")
            parent_level = int(by_key[parent_key]["LEVEL"][1:])
            check(parent_level + 1 == level, "invalid parent level")
        check(level <= 4, "L5 detected")

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(key: str) -> None:
        if key in visited:
            return
        check(key not in visiting, f"cycle at {key}")
        visiting.add(key)
        parent = by_key[key]["PARENT_PLANNING_KEY"].strip()
        if parent:
            visit(parent)
        visiting.remove(key)
        visited.add(key)

    for key in keys:
        visit(key)

    children = Counter(
        row["PARENT_PLANNING_KEY"].strip()
        for row in manifest
        if row["PARENT_PLANNING_KEY"].strip()
    )
    derived_leaves = sum(children[row["PLANNING_KEY"]] == 0 for row in manifest)
    check(derived_leaves == EXPECTED_LEAVES, "derived leaf count mismatch")
    for row in manifest:
        expected_leaf = children[row["PLANNING_KEY"]] == 0
        check((row["LEAF_YN"] == "YES") == expected_leaf, "leaf/container conflict")

    check(len(registry) == EXPECTED_LEGACY_LOCATORS, "legacy registry count mismatch")
    check(
        len({row["LEGACY_NODE_ID"] for row in registry}) == EXPECTED_LEGACY_LOCATORS,
        "duplicate legacy locator",
    )
    registry_edges = 0
    registry_actions = Counter(row["FINAL_ACTION"] for row in registry)
    check(dict(registry_actions) == EXPECTED_ACTIONS, "legacy action count mismatch")
    split_edges = 0
    for row in registry:
        target_keys = split_targets(row["TARGET_PLANNING_KEYS"])
        check(
            len(target_keys) == int(row["SUCCESSOR_COUNT"]),
            f"successor count mismatch: {row['LEGACY_NODE_ID']}",
        )
        check(all(key in by_key for key in target_keys), "unknown canonical target")
        registry_edges += len(target_keys)
        if row["FINAL_ACTION"] == "SPLIT":
            split_edges += len(target_keys)
    check(registry_edges == EXPECTED_SUCCESSOR_EDGES, "successor edge mismatch")
    check(split_edges == EXPECTED_SPLIT_EDGES, "split successor edge mismatch")

    check(len(aliases) == EXPECTED_LEGACY_LOCATORS, "alias locator count mismatch")
    check(
        len({row["LEGACY_SLUG"] for row in aliases}) == EXPECTED_LEGACY_LOCATORS,
        "duplicate legacy alias slug",
    )
    alias_edges = 0
    for row in aliases:
        targets = split_targets(row["CANONICAL_PLANNING_KEY"])
        check(all(key in by_key for key in targets), "unknown alias target")
        alias_edges += len(targets)
    check(alias_edges == EXPECTED_SUCCESSOR_EDGES, "alias target edge mismatch")
    check(
        {row["LEGACY_SLUG"] for row in aliases}
        == {row["LEGACY_SLUG"] for row in registry},
        "alias/registry locator coverage mismatch",
    )

    return {
        "nodes": len(manifest),
        "levels": dict(levels),
        "leaves": derived_leaves,
        "legacy_locators": len(registry),
        "legacy_actions": dict(registry_actions),
        "split_successor_edges": split_edges,
        "successor_edges": registry_edges,
        "aliases": len(aliases),
    }


def connect(path: Path) -> sqlite3.Connection:
    connection = sqlite3.connect(path, isolation_level=None)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    connection.execute("PRAGMA journal_mode = DELETE")
    connection.execute("PRAGMA synchronous = FULL")
    check(connection.execute("PRAGMA foreign_keys").fetchone()[0] == 1, "FK off")
    return connection


def create_current_schema(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        BEGIN;
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL CHECK (length(trim(name)) > 0),
          description TEXT,
          image_url TEXT,
          parent_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
          sort_order INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX categories_parent_sort_idx
          ON categories(parent_id, sort_order);

        CREATE TABLE products (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL CHECK (length(trim(name)) > 0),
          category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
          price NUMERIC NOT NULL CHECK (price >= 0),
          stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
          is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
          attributes TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX products_category_idx ON products(category_id);

        CREATE TABLE shops (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
        );

        CREATE TABLE shop_products (
          id TEXT PRIMARY KEY,
          shop_id TEXT NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
          product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
          price NUMERIC NOT NULL CHECK (price >= 0),
          is_available INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1)),
          is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
          UNIQUE (shop_id, product_id)
        );
        CREATE INDEX shop_products_product_idx ON shop_products(product_id);

        CREATE TABLE reviews (
          id TEXT PRIMARY KEY,
          user_locator TEXT NOT NULL,
          product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
          rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
          comment TEXT
        );

        CREATE TABLE wishlist (
          id TEXT PRIMARY KEY,
          user_locator TEXT NOT NULL,
          product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
          UNIQUE (user_locator, product_id)
        );

        CREATE TABLE cart_items_v2 (
          id TEXT PRIMARY KEY,
          cart_locator TEXT NOT NULL,
          shop_product_id TEXT NOT NULL
            REFERENCES shop_products(id) ON DELETE RESTRICT,
          quantity INTEGER NOT NULL CHECK (quantity > 0)
        );

        CREATE TABLE verified_transaction_items (
          id TEXT PRIMARY KEY,
          transaction_locator TEXT NOT NULL,
          product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
          product_name_snapshot TEXT NOT NULL,
          unit_price_snapshot NUMERIC NOT NULL CHECK (unit_price_snapshot >= 0)
        );
        COMMIT;
        """
    )


def choose_rows(
    manifest: list[dict[str, str]], registry: list[dict[str, str]]
) -> tuple[dict[str, dict[str, str]], dict[str, str]]:
    by_key = {row["PLANNING_KEY"]: row for row in manifest}

    def is_safe(key: str) -> bool:
        row = by_key[key]
        return row["ASSIGNABLE_YN"] == "YES" and row["ACTIVE_CANDIDATE_YN"] == "YES"

    selected: dict[str, dict[str, str]] = {}
    for action in ("KEEP", "RENAME", "MOVE", "RENAME_AND_MOVE", "MERGE"):
        candidates = [row for row in registry if row["FINAL_ACTION"] == action]
        selected[action] = next(
            (
                row
                for row in candidates
                if len(split_targets(row["TARGET_PLANNING_KEYS"])) == 1
                and is_safe(split_targets(row["TARGET_PLANNING_KEYS"])[0])
            ),
            candidates[0],
        )

    split_candidates = [row for row in registry if row["FINAL_ACTION"] == "SPLIT"]
    selected["SPLIT"] = next(
        (
            row
            for row in split_candidates
            if any(is_safe(key) for key in split_targets(row["TARGET_PLANNING_KEYS"]))
        ),
        split_candidates[0],
    )
    for action in ("RETIRE", "OUT", "UNRESOLVED"):
        selected[action] = next(row for row in registry if row["FINAL_ACTION"] == action)

    policy_row = next(
        row
        for row in registry
        if split_targets(row["TARGET_PLANNING_KEYS"])
        and any(
            by_key[key]["POLICY_CLASS"] != "NORMAL"
            or by_key[key]["PROFESSIONAL_REVIEW_REQUIRED"] == "YES"
            for key in split_targets(row["TARGET_PLANNING_KEYS"])
        )
    )
    selected["POLICY"] = policy_row
    safe_targets = {
        action: next(
            (
                key
                for key in split_targets(row["TARGET_PLANNING_KEYS"])
                if is_safe(key)
            ),
            "",
        )
        for action, row in selected.items()
    }
    return selected, safe_targets


def seed_representative_data(
    connection: sqlite3.Connection,
    manifest: list[dict[str, str]],
    registry: list[dict[str, str]],
) -> list[dict[str, str]]:
    selected, safe_targets = choose_rows(manifest, registry)
    root_id = str(uuid.uuid4())
    shop_id = str(uuid.uuid4())
    connection.execute("BEGIN")
    connection.execute(
        "INSERT INTO categories(id, name, sort_order, is_active) VALUES (?, ?, 0, 1)",
        (root_id, "Synthetic Legacy Root"),
    )
    connection.execute(
        "INSERT INTO shops(id, name, is_active) VALUES (?, ?, 1)",
        (shop_id, "Synthetic Local Shop"),
    )

    legacy_category_ids: dict[str, str] = {}
    representative: list[dict[str, str]] = []

    def category_for(row: dict[str, str]) -> str:
        locator = row["LEGACY_NODE_ID"]
        if locator not in legacy_category_ids:
            category_id = str(uuid.uuid4())
            legacy_category_ids[locator] = category_id
            connection.execute(
                """
                INSERT INTO categories(id, name, parent_id, sort_order, is_active)
                VALUES (?, ?, ?, ?, 1)
                """,
                (category_id, f"Synthetic {row['FINAL_ACTION']} — {row['LEGACY_NAME']}", root_id, len(legacy_category_ids)),
            )
        return legacy_category_ids[locator]

    def add_product(
        role: str,
        row: dict[str, str],
        decision_state: str,
        target_key: str = "",
        decision_origin: str = "",
        demo_like: bool = False,
    ) -> dict[str, str]:
        product_id = str(uuid.uuid4())
        category_id = category_for(row)
        connection.execute(
            """
            INSERT INTO products(id, name, category_id, price, stock, is_active, attributes)
            VALUES (?, ?, ?, ?, ?, 1, ?)
            """,
            (
                product_id,
                f"Synthetic {role}",
                category_id,
                100 + len(representative),
                10,
                json.dumps({"synthetic": True, "demo_like": demo_like}),
            ),
        )
        listing_id = str(uuid.uuid4())
        connection.execute(
            """
            INSERT INTO shop_products(id, shop_id, product_id, price, is_available, is_active)
            VALUES (?, ?, ?, ?, 1, 1)
            """,
            (listing_id, shop_id, product_id, 110 + len(representative)),
        )
        spec = {
            "role": role,
            "product_id": product_id,
            "listing_id": listing_id,
            "legacy_category_id": category_id,
            "legacy_locator": row["LEGACY_NODE_ID"],
            "action": row["FINAL_ACTION"],
            "decision_state": decision_state,
            "target_key": target_key,
            "decision_origin": decision_origin,
        }
        representative.append(spec)
        return spec

    for action in ("KEEP", "RENAME", "MOVE", "RENAME_AND_MOVE", "MERGE"):
        row = selected[action]
        target = safe_targets[action]
        state = "APPROVED" if target else "POLICY_REVIEW"
        add_product(
            action.lower(),
            row,
            state,
            target,
            "AUTO_ONE_TO_ONE" if target else "POLICY_GATE",
        )

    split_row = selected["SPLIT"]
    add_product(
        "split-exact",
        split_row,
        "APPROVED",
        safe_targets["SPLIT"],
        "MANUAL_EXACT_SUCCESSOR",
    )
    add_product("split-manual", split_row, "MANUAL_REVIEW", "", "AMBIGUOUS_SPLIT")
    add_product("retire", selected["RETIRE"], "TOMBSTONE", "", "NO_SUCCESSOR")
    add_product("out", selected["OUT"], "OUT_OF_SCOPE", "", "NO_SUCCESSOR")
    add_product(
        "unresolved", selected["UNRESOLVED"], "MANUAL_REVIEW", "", "UNRESOLVED"
    )
    add_product("policy", selected["POLICY"], "POLICY_REVIEW", "", "POLICY_GATE")

    safe_demo_row = selected["RENAME"]
    safe_demo_target = safe_targets["RENAME"]
    add_product(
        "demo-like-a",
        safe_demo_row,
        "APPROVED",
        safe_demo_target,
        "AUTO_ONE_TO_ONE",
        demo_like=True,
    )
    add_product(
        "demo-like-b",
        safe_demo_row,
        "APPROVED",
        safe_demo_target,
        "AUTO_ONE_TO_ONE",
        demo_like=True,
    )

    first = representative[0]
    connection.execute(
        "INSERT INTO reviews VALUES (?, ?, ?, ?, ?)",
        (str(uuid.uuid4()), "synthetic-customer", first["product_id"], 5, "Synthetic review"),
    )
    connection.execute(
        "INSERT INTO wishlist VALUES (?, ?, ?)",
        (str(uuid.uuid4()), "synthetic-customer", first["product_id"]),
    )
    connection.execute(
        "INSERT INTO cart_items_v2 VALUES (?, ?, ?, ?)",
        (str(uuid.uuid4()), "synthetic-cart", first["listing_id"], 1),
    )
    connection.execute(
        "INSERT INTO verified_transaction_items VALUES (?, ?, ?, ?, ?)",
        (
            str(uuid.uuid4()),
            "synthetic-transaction",
            first["product_id"],
            "Synthetic snapshot",
            100,
        ),
    )
    connection.execute("COMMIT")
    return representative


def apply_additive_schema(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        BEGIN;
        ALTER TABLE categories ADD COLUMN source_key TEXT;
        ALTER TABLE categories ADD COLUMN slug TEXT;
        ALTER TABLE categories ADD COLUMN level INTEGER
          CHECK (level IS NULL OR level BETWEEN 1 AND 4);
        ALTER TABLE categories ADD COLUMN lifecycle_state TEXT
          CHECK (lifecycle_state IS NULL OR lifecycle_state IN ('staged', 'active', 'retired'));
        ALTER TABLE categories ADD COLUMN is_assignable INTEGER
          CHECK (is_assignable IS NULL OR is_assignable IN (0, 1));
        ALTER TABLE categories ADD COLUMN policy_class TEXT
          CHECK (policy_class IS NULL OR policy_class IN (
            'NORMAL', 'AGE_RESTRICTED', 'REGULATED', 'LEGAL_REVIEW_REQUIRED', 'EXCLUDED'
          ));
        ALTER TABLE categories ADD COLUMN professional_review_status TEXT
          CHECK (professional_review_status IS NULL OR professional_review_status IN (
            'not_required', 'pending', 'approved', 'rejected'
          ));
        ALTER TABLE categories ADD COLUMN taxonomy_version TEXT;

        CREATE UNIQUE INDEX categories_source_key_unique_idx
          ON categories(source_key) WHERE source_key IS NOT NULL;
        CREATE UNIQUE INDEX categories_slug_unique_idx
          ON categories(lower(slug)) WHERE slug IS NOT NULL;
        CREATE INDEX categories_version_level_order_idx
          ON categories(taxonomy_version, level, parent_id, sort_order);
        CREATE INDEX categories_public_tree_idx
          ON categories(parent_id, sort_order)
          WHERE is_active = 1 AND lifecycle_state = 'active';

        CREATE TABLE taxonomy_id_allocations (
          planning_key TEXT PRIMARY KEY,
          runtime_id TEXT NOT NULL UNIQUE,
          taxonomy_version TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE taxonomy_node_relationships (
          id TEXT PRIMARY KEY,
          predecessor_category_id TEXT REFERENCES categories(id) ON DELETE RESTRICT,
          predecessor_source_locator TEXT NOT NULL,
          successor_category_id TEXT REFERENCES categories(id) ON DELETE RESTRICT,
          action TEXT NOT NULL CHECK (action IN (
            'KEEP', 'RENAME', 'MOVE', 'RENAME_AND_MOVE', 'MERGE', 'SPLIT',
            'RETIRE', 'OUT', 'UNRESOLVED'
          )),
          target_state TEXT NOT NULL CHECK (target_state IN (
            'CANONICAL_FINAL', 'NO_TARGET_YET', 'POLICY_REVIEW', 'OUT_OF_SCOPE'
          )),
          classification_rule TEXT,
          confidence TEXT,
          taxonomy_version TEXT NOT NULL,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          CHECK (
            successor_category_id IS NOT NULL
            OR action IN ('RETIRE', 'OUT', 'UNRESOLVED')
          )
        );
        CREATE UNIQUE INDEX taxonomy_relationship_edge_unique_idx
          ON taxonomy_node_relationships(
            predecessor_source_locator,
            ifnull(successor_category_id, ''),
            action,
            taxonomy_version
          );
        CREATE INDEX taxonomy_relationships_successor_idx
          ON taxonomy_node_relationships(successor_category_id)
          WHERE successor_category_id IS NOT NULL;

        CREATE TABLE taxonomy_aliases (
          id TEXT PRIMARY KEY,
          alias_kind TEXT NOT NULL CHECK (alias_kind IN ('LEGACY_REDIRECT', 'SEARCH_SYNONYM')),
          alias_locator TEXT NOT NULL,
          alias_text TEXT,
          alias_slug TEXT,
          alias_path TEXT,
          source_alias_type TEXT,
          resolution_state TEXT NOT NULL CHECK (resolution_state IN (
            'RESOLVED', 'AMBIGUOUS', 'TOMBSTONE', 'UNRESOLVED'
          )),
          direct_target_category_id TEXT REFERENCES categories(id) ON DELETE RESTRICT,
          taxonomy_version TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE (alias_kind, alias_locator, taxonomy_version),
          CHECK (
            (resolution_state = 'RESOLVED' AND direct_target_category_id IS NOT NULL)
            OR (resolution_state <> 'RESOLVED' AND direct_target_category_id IS NULL)
          )
        );

        CREATE TABLE taxonomy_alias_targets (
          alias_id TEXT NOT NULL REFERENCES taxonomy_aliases(id) ON DELETE CASCADE,
          target_category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
          PRIMARY KEY (alias_id, target_category_id)
        );

        CREATE TABLE rehearsal_product_category_snapshot (
          product_id TEXT PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
          original_category_id TEXT REFERENCES categories(id) ON DELETE RESTRICT
        );

        CREATE TABLE rehearsal_product_decisions (
          product_id TEXT PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
          decision_state TEXT NOT NULL CHECK (decision_state IN (
            'APPROVED', 'MANUAL_REVIEW', 'POLICY_REVIEW', 'TOMBSTONE', 'OUT_OF_SCOPE'
          )),
          target_planning_key TEXT,
          decision_origin TEXT NOT NULL
        );

        CREATE TABLE rehearsal_product_quarantine (
          product_id TEXT PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
          reason TEXT NOT NULL,
          active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TRIGGER categories_prevent_cycle_update
        BEFORE UPDATE OF parent_id ON categories
        WHEN NEW.parent_id IS NOT NULL
        BEGIN
          SELECT RAISE(ABORT, 'category cycle')
          WHERE NEW.parent_id = NEW.id
             OR NEW.parent_id IN (
               WITH RECURSIVE descendants(id) AS (
                 SELECT id FROM categories WHERE parent_id = NEW.id
                 UNION ALL
                 SELECT c.id FROM categories c
                 JOIN descendants d ON c.parent_id = d.id
               )
               SELECT id FROM descendants
             );
        END;

        CREATE TRIGGER categories_parent_level_insert
        BEFORE INSERT ON categories
        WHEN NEW.parent_id IS NOT NULL AND NEW.level IS NOT NULL
        BEGIN
          SELECT RAISE(ABORT, 'category parent level mismatch')
          WHERE EXISTS (
            SELECT 1 FROM categories p
            WHERE p.id = NEW.parent_id
              AND p.level IS NOT NULL
              AND NEW.level <> p.level + 1
          );
        END;

        CREATE TRIGGER categories_parent_level_update
        BEFORE UPDATE OF parent_id, level ON categories
        WHEN NEW.parent_id IS NOT NULL AND NEW.level IS NOT NULL
        BEGIN
          SELECT RAISE(ABORT, 'category parent level mismatch')
          WHERE EXISTS (
            SELECT 1 FROM categories p
            WHERE p.id = NEW.parent_id
              AND p.level IS NOT NULL
              AND NEW.level <> p.level + 1
          );
        END;
        COMMIT;
        """
    )


def backfill_legacy_metadata(
    connection: sqlite3.Connection,
    representative: list[dict[str, str]],
) -> None:
    locator_by_category = {
        item["legacy_category_id"]: item["legacy_locator"] for item in representative
    }
    root_rows = connection.execute(
        "SELECT id, name FROM categories WHERE parent_id IS NULL"
    ).fetchall()
    connection.execute("BEGIN")
    for root in root_rows:
        connection.execute(
            """
            UPDATE categories SET source_key=?, slug=?, level=1,
              lifecycle_state='active', is_assignable=0, policy_class='NORMAL',
              professional_review_status='not_required', taxonomy_version=?
            WHERE id=?
            """,
            (f"legacy-root:{root['id']}", f"legacy-root-{root['id'][:8]}", LEGACY_VERSION, root["id"]),
        )
    for category_id, locator in locator_by_category.items():
        connection.execute(
            """
            UPDATE categories SET source_key=?, slug=?, level=2,
              lifecycle_state='active', is_assignable=1, policy_class='NORMAL',
              professional_review_status='not_required', taxonomy_version=?
            WHERE id=?
            """,
            (f"legacy:{locator}", f"legacy-{locator}", LEGACY_VERSION, category_id),
        )
    connection.execute("COMMIT")


def allocation_id(connection: sqlite3.Connection, planning_key: str) -> str:
    existing = connection.execute(
        "SELECT runtime_id FROM taxonomy_id_allocations WHERE planning_key=?",
        (planning_key,),
    ).fetchone()
    if existing:
        return existing[0]
    runtime_id = str(uuid.uuid4())
    connection.execute(
        "INSERT INTO taxonomy_id_allocations VALUES (?, ?, ?, CURRENT_TIMESTAMP)",
        (planning_key, runtime_id, CANONICAL_VERSION),
    )
    return runtime_id


def import_canonical(
    connection: sqlite3.Connection, manifest: list[dict[str, str]]
) -> dict[str, str]:
    for row in manifest:
        allocation_id(connection, row["PLANNING_KEY"])
    allocations = {
        row["planning_key"]: row["runtime_id"]
        for row in connection.execute(
            "SELECT planning_key, runtime_id FROM taxonomy_id_allocations"
        )
    }
    sibling_order: defaultdict[str, int] = defaultdict(int)
    for row in manifest:
        key = row["PLANNING_KEY"]
        parent_key = row["PARENT_PLANNING_KEY"].strip()
        sibling_order[parent_key] += 1
        runtime_id = allocations[key]
        parent_id = allocations[parent_key] if parent_key else None
        professional_status = (
            "pending" if row["PROFESSIONAL_REVIEW_REQUIRED"] == "YES" else "not_required"
        )
        existing = connection.execute(
            "SELECT id FROM categories WHERE source_key=?", (key,)
        ).fetchone()
        if existing:
            check(existing[0] == runtime_id, "canonical ID regenerated")
            connection.execute(
                """
                UPDATE categories SET name=?, parent_id=?, sort_order=?, slug=?, level=?,
                  lifecycle_state='staged', is_active=0, is_assignable=0,
                  policy_class=?, professional_review_status=?, taxonomy_version=?
                WHERE id=?
                """,
                (
                    canonical_name(row),
                    parent_id,
                    sibling_order[parent_key],
                    rehearsal_slug(canonical_name(row), key),
                    int(row["LEVEL"][1:]),
                    row["POLICY_CLASS"],
                    professional_status,
                    CANONICAL_VERSION,
                    runtime_id,
                ),
            )
        else:
            connection.execute(
                """
                INSERT INTO categories(
                  id, name, parent_id, sort_order, is_active, source_key, slug,
                  level, lifecycle_state, is_assignable, policy_class,
                  professional_review_status, taxonomy_version
                ) VALUES (?, ?, ?, ?, 0, ?, ?, ?, 'staged', 0, ?, ?, ?)
                """,
                (
                    runtime_id,
                    canonical_name(row),
                    parent_id,
                    sibling_order[parent_key],
                    key,
                    rehearsal_slug(canonical_name(row), key),
                    int(row["LEVEL"][1:]),
                    row["POLICY_CLASS"],
                    professional_status,
                    CANONICAL_VERSION,
                ),
            )
    return allocations


def target_state(row: dict[str, str]) -> str:
    if row["FINAL_ACTION"] == "OUT":
        return "OUT_OF_SCOPE"
    if row["RUNTIME_DISPOSITION"] == "POLICY_REVIEW":
        return "POLICY_REVIEW"
    if not split_targets(row["TARGET_PLANNING_KEYS"]):
        return "NO_TARGET_YET"
    return "CANONICAL_FINAL"


def import_relationships(
    connection: sqlite3.Connection,
    registry: list[dict[str, str]],
    allocations: dict[str, str],
    representative: list[dict[str, str]],
) -> None:
    predecessor_ids = {
        item["legacy_locator"]: item["legacy_category_id"] for item in representative
    }
    for row in registry:
        targets = split_targets(row["TARGET_PLANNING_KEYS"])
        edge_targets: list[str | None] = targets or [None]
        for target in edge_targets:
            successor_id = allocations[target] if target else None
            existing = connection.execute(
                """
                SELECT id FROM taxonomy_node_relationships
                WHERE predecessor_source_locator=?
                  AND ifnull(successor_category_id, '')=ifnull(?, '')
                  AND action=? AND taxonomy_version=?
                """,
                (
                    row["LEGACY_NODE_ID"],
                    successor_id,
                    row["FINAL_ACTION"],
                    CANONICAL_VERSION,
                ),
            ).fetchone()
            if existing:
                continue
            connection.execute(
                """
                INSERT INTO taxonomy_node_relationships(
                  id, predecessor_category_id, predecessor_source_locator,
                  successor_category_id, action, target_state,
                  classification_rule, confidence, taxonomy_version
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    str(uuid.uuid4()),
                    predecessor_ids.get(row["LEGACY_NODE_ID"]),
                    row["LEGACY_NODE_ID"],
                    successor_id,
                    row["FINAL_ACTION"],
                    target_state(row),
                    row["RUNTIME_DISPOSITION"],
                    "REHEARSAL_SOURCE_EXACT",
                    CANONICAL_VERSION,
                ),
            )


def alias_resolution(row: dict[str, str], target_keys: list[str]) -> str:
    if len(target_keys) == 1:
        return "RESOLVED"
    if len(target_keys) > 1:
        return "AMBIGUOUS"
    if row["SOURCE_ACTION"] in ("RETIRE", "OUT"):
        return "TOMBSTONE"
    return "UNRESOLVED"


def import_aliases(
    connection: sqlite3.Connection,
    aliases: list[dict[str, str]],
    allocations: dict[str, str],
) -> None:
    safe_synonym_sources: list[tuple[str, str, str]] = []
    for row in aliases:
        target_keys = split_targets(row["CANONICAL_PLANNING_KEY"])
        resolution = alias_resolution(row, target_keys)
        alias_row = connection.execute(
            """
            SELECT id FROM taxonomy_aliases
            WHERE alias_kind='LEGACY_REDIRECT' AND alias_locator=? AND taxonomy_version=?
            """,
            (row["LEGACY_SLUG"], CANONICAL_VERSION),
        ).fetchone()
        if alias_row:
            alias_id = alias_row[0]
        else:
            alias_id = str(uuid.uuid4())
            direct_target = allocations[target_keys[0]] if resolution == "RESOLVED" else None
            connection.execute(
                """
                INSERT INTO taxonomy_aliases(
                  id, alias_kind, alias_locator, alias_text, alias_slug, alias_path,
                  source_alias_type, resolution_state, direct_target_category_id,
                  taxonomy_version, is_active
                ) VALUES (?, 'LEGACY_REDIRECT', ?, ?, ?, ?, ?, ?, ?, ?, 1)
                """,
                (
                    alias_id,
                    row["LEGACY_SLUG"],
                    row["LEGACY_NAME"],
                    row["LEGACY_SLUG"],
                    row["LEGACY_PATH"],
                    row["ALIAS_TYPE"],
                    resolution,
                    direct_target,
                    CANONICAL_VERSION,
                ),
            )
        for key in target_keys:
            connection.execute(
                "INSERT OR IGNORE INTO taxonomy_alias_targets VALUES (?, ?)",
                (alias_id, allocations[key]),
            )
        if resolution == "RESOLVED" and len(safe_synonym_sources) < 3:
            safe_synonym_sources.append((row["LEGACY_SLUG"], row["LEGACY_NAME"], allocations[target_keys[0]]))

    for locator, name, target_id in safe_synonym_sources:
        synonym_locator = f"controlled-search:{locator}"
        if connection.execute(
            """
            SELECT 1 FROM taxonomy_aliases
            WHERE alias_kind='SEARCH_SYNONYM' AND alias_locator=? AND taxonomy_version=?
            """,
            (synonym_locator, CANONICAL_VERSION),
        ).fetchone():
            continue
        connection.execute(
            """
            INSERT INTO taxonomy_aliases(
              id, alias_kind, alias_locator, alias_text, source_alias_type,
              resolution_state, direct_target_category_id, taxonomy_version, is_active
            ) VALUES (?, 'SEARCH_SYNONYM', ?, ?, 'CONTROLLED_REHEARSAL_SYNONYM',
              'RESOLVED', ?, ?, 1)
            """,
            (str(uuid.uuid4()), synonym_locator, name, target_id, CANONICAL_VERSION),
        )


def seed_product_decisions(
    connection: sqlite3.Connection, representative: list[dict[str, str]]
) -> None:
    for item in representative:
        connection.execute(
            """
            INSERT OR IGNORE INTO rehearsal_product_category_snapshot(product_id, original_category_id)
            VALUES (?, ?)
            """,
            (item["product_id"], item["legacy_category_id"]),
        )
        connection.execute(
            """
            INSERT OR REPLACE INTO rehearsal_product_decisions(
              product_id, decision_state, target_planning_key, decision_origin
            ) VALUES (?, ?, ?, ?)
            """,
            (
                item["product_id"],
                item["decision_state"],
                item["target_key"] or None,
                item["decision_origin"],
            ),
        )


def activate_safe_candidates(
    connection: sqlite3.Connection, manifest: list[dict[str, str]]
) -> None:
    connection.execute(
        """
        UPDATE categories SET lifecycle_state='staged', is_active=0, is_assignable=0
        WHERE taxonomy_version=?
        """,
        (CANONICAL_VERSION,),
    )
    for row in manifest:
        if row["ACTIVE_CANDIDATE_YN"] != "YES":
            continue
        connection.execute(
            """
            UPDATE categories SET lifecycle_state='active', is_active=1, is_assignable=?
            WHERE source_key=? AND taxonomy_version=?
            """,
            (1 if row["ASSIGNABLE_YN"] == "YES" else 0, row["PLANNING_KEY"], CANONICAL_VERSION),
        )


def apply_product_reassignment(connection: sqlite3.Connection) -> dict[str, int]:
    counts = Counter()
    decisions = connection.execute(
        """
        SELECT d.*, p.category_id
        FROM rehearsal_product_decisions d JOIN products p ON p.id=d.product_id
        ORDER BY d.product_id
        """
    ).fetchall()
    for row in decisions:
        if row["decision_state"] == "APPROVED" and row["target_planning_key"]:
            target = connection.execute(
                """
                SELECT c.id, c.is_assignable, c.is_active, c.lifecycle_state,
                       c.policy_class, c.professional_review_status
                FROM taxonomy_id_allocations a JOIN categories c ON c.id=a.runtime_id
                WHERE a.planning_key=?
                """,
                (row["target_planning_key"],),
            ).fetchone()
            if (
                target
                and target["is_assignable"] == 1
                and target["is_active"] == 1
                and target["lifecycle_state"] == "active"
                and target["policy_class"] == "NORMAL"
                and target["professional_review_status"] == "not_required"
            ):
                connection.execute(
                    "UPDATE products SET category_id=? WHERE id=?",
                    (target["id"], row["product_id"]),
                )
                connection.execute(
                    "DELETE FROM rehearsal_product_quarantine WHERE product_id=?",
                    (row["product_id"],),
                )
                counts[
                    "manual_exact" if row["decision_origin"] == "MANUAL_EXACT_SUCCESSOR" else "auto_safe"
                ] += 1
                continue
        reason = row["decision_state"]
        connection.execute(
            """
            INSERT INTO rehearsal_product_quarantine(product_id, reason, active, updated_at)
            VALUES (?, ?, 1, CURRENT_TIMESTAMP)
            ON CONFLICT(product_id) DO UPDATE SET
              reason=excluded.reason, active=1, updated_at=CURRENT_TIMESTAMP
            """,
            (row["product_id"], reason),
        )
        if reason == "POLICY_REVIEW":
            counts["policy"] += 1
        elif reason in ("MANUAL_REVIEW",):
            counts["manual"] += 1
        else:
            counts["tombstone_or_out"] += 1
        counts["quarantine"] += 1
    return dict(counts)


def allocation_hash(connection: sqlite3.Connection) -> str:
    payload = "\n".join(
        f"{row['planning_key']}={row['runtime_id']}"
        for row in connection.execute(
            "SELECT planning_key, runtime_id FROM taxonomy_id_allocations ORDER BY planning_key"
        )
    )
    return hashlib.sha256(payload.encode()).hexdigest()


def validate_database(connection: sqlite3.Connection) -> dict[str, Any]:
    canonical = connection.execute(
        "SELECT id, parent_id, level, source_key FROM categories WHERE taxonomy_version=?",
        (CANONICAL_VERSION,),
    ).fetchall()
    check(len(canonical) == EXPECTED_NODES, "database canonical count mismatch")
    level_counts = Counter(f"L{row['level']}" for row in canonical)
    check(dict(level_counts) == EXPECTED_LEVELS, "database level count mismatch")
    ids = {row["id"] for row in canonical}
    parents = {row["id"]: row["parent_id"] for row in canonical}
    check(
        all(parent is None or parent in ids for parent in parents.values()),
        "database orphan",
    )
    for node_id in ids:
        seen: set[str] = set()
        cursor: str | None = node_id
        depth = 0
        while cursor is not None:
            check(cursor not in seen, "database cycle")
            seen.add(cursor)
            cursor = parents.get(cursor)
            depth += 1
            check(depth <= 4, "database L5/depth violation")
    child_parents = {
        row[0]
        for row in connection.execute(
            """
            SELECT DISTINCT parent_id FROM categories
            WHERE taxonomy_version=? AND parent_id IS NOT NULL
            """,
            (CANONICAL_VERSION,),
        )
    }
    check(len(ids - child_parents) == EXPECTED_LEAVES, "database leaf mismatch")

    active = connection.execute(
        "SELECT count(*) FROM categories WHERE taxonomy_version=? AND is_active=1",
        (CANONICAL_VERSION,),
    ).fetchone()[0]
    assignable = connection.execute(
        "SELECT count(*) FROM categories WHERE taxonomy_version=? AND is_assignable=1",
        (CANONICAL_VERSION,),
    ).fetchone()[0]
    check(active in (0, EXPECTED_ACTIVE_CANDIDATES), "unexpected active count")
    check(assignable in (0, EXPECTED_ASSIGNABLE_CANDIDATES), "unexpected assignable count")
    leakage = connection.execute(
        """
        SELECT count(*) FROM categories
        WHERE taxonomy_version=? AND is_active=1
          AND (policy_class <> 'NORMAL' OR professional_review_status <> 'not_required')
        """,
        (CANONICAL_VERSION,),
    ).fetchone()[0]
    check(leakage == 0, "policy/professional-review leakage")

    locator_count = connection.execute(
        "SELECT count(DISTINCT predecessor_source_locator) FROM taxonomy_node_relationships"
    ).fetchone()[0]
    edge_count = connection.execute(
        "SELECT count(*) FROM taxonomy_node_relationships WHERE successor_category_id IS NOT NULL"
    ).fetchone()[0]
    null_edge_count = connection.execute(
        "SELECT count(*) FROM taxonomy_node_relationships WHERE successor_category_id IS NULL"
    ).fetchone()[0]
    split_locator_count = connection.execute(
        """
        SELECT count(DISTINCT predecessor_source_locator)
        FROM taxonomy_node_relationships WHERE action='SPLIT'
        """
    ).fetchone()[0]
    split_edge_count = connection.execute(
        """
        SELECT count(*) FROM taxonomy_node_relationships
        WHERE action='SPLIT' AND successor_category_id IS NOT NULL
        """
    ).fetchone()[0]
    check(locator_count == EXPECTED_LEGACY_LOCATORS, "relationship locator mismatch")
    check(edge_count == EXPECTED_SUCCESSOR_EDGES, "relationship edge mismatch")
    check(null_edge_count == 32, "no-target relationship count mismatch")
    check(split_locator_count == 210, "split locator count mismatch")
    check(split_edge_count == EXPECTED_SPLIT_EDGES, "split edge count mismatch")

    legacy_alias_count = connection.execute(
        "SELECT count(*) FROM taxonomy_aliases WHERE alias_kind='LEGACY_REDIRECT'"
    ).fetchone()[0]
    alias_target_count = connection.execute(
        "SELECT count(*) FROM taxonomy_alias_targets"
    ).fetchone()[0]
    check(legacy_alias_count == EXPECTED_LEGACY_LOCATORS, "alias locator mismatch")
    check(alias_target_count == EXPECTED_SUCCESSOR_EDGES, "alias edge mismatch")
    return {
        "nodes": len(canonical),
        "levels": dict(level_counts),
        "leaves": len(ids - child_parents),
        "active": active,
        "assignable": assignable,
        "legacy_locators": locator_count,
        "successor_edges": edge_count,
        "no_target_relationships": null_edge_count,
        "split_locators": split_locator_count,
        "split_successor_edges": split_edge_count,
        "legacy_aliases": legacy_alias_count,
        "alias_targets": alias_target_count,
        "policy_leakage": leakage,
    }


def forward_cycle(
    connection: sqlite3.Connection,
    manifest: list[dict[str, str]],
    registry: list[dict[str, str]],
    aliases: list[dict[str, str]],
    representative: list[dict[str, str]],
) -> dict[str, Any]:
    connection.execute("BEGIN")
    try:
        allocations = import_canonical(connection, manifest)
        import_relationships(connection, registry, allocations, representative)
        import_aliases(connection, aliases, allocations)
        seed_product_decisions(connection, representative)
        before_counts = {
            "nodes": connection.execute(
                "SELECT count(*) FROM categories WHERE taxonomy_version=?",
                (CANONICAL_VERSION,),
            ).fetchone()[0],
            "relationships": connection.execute(
                "SELECT count(*) FROM taxonomy_node_relationships"
            ).fetchone()[0],
            "aliases": connection.execute("SELECT count(*) FROM taxonomy_aliases").fetchone()[0],
            "alias_targets": connection.execute(
                "SELECT count(*) FROM taxonomy_alias_targets"
            ).fetchone()[0],
            "allocation_hash": allocation_hash(connection),
        }

        # Second import in the same run is the idempotency attempt.
        allocations_again = import_canonical(connection, manifest)
        import_relationships(connection, registry, allocations_again, representative)
        import_aliases(connection, aliases, allocations_again)
        after_counts = {
            "nodes": connection.execute(
                "SELECT count(*) FROM categories WHERE taxonomy_version=?",
                (CANONICAL_VERSION,),
            ).fetchone()[0],
            "relationships": connection.execute(
                "SELECT count(*) FROM taxonomy_node_relationships"
            ).fetchone()[0],
            "aliases": connection.execute("SELECT count(*) FROM taxonomy_aliases").fetchone()[0],
            "alias_targets": connection.execute(
                "SELECT count(*) FROM taxonomy_alias_targets"
            ).fetchone()[0],
            "allocation_hash": allocation_hash(connection),
        }
        check(before_counts == after_counts, "idempotency changed counts/IDs")
        activate_safe_candidates(connection, manifest)
        reassignment = apply_product_reassignment(connection)
        db_validation = validate_database(connection)
        connection.execute("COMMIT")
        return {
            "idempotency": "PASS",
            "counts": after_counts,
            "reassignment": reassignment,
            "database": db_validation,
        }
    except Exception:
        connection.execute("ROLLBACK")
        raise


def rollback_cycle(connection: sqlite3.Connection) -> dict[str, Any]:
    connection.execute("BEGIN")
    try:
        connection.execute(
            """
            UPDATE products
            SET category_id=(
              SELECT s.original_category_id
              FROM rehearsal_product_category_snapshot s
              WHERE s.product_id=products.id
            )
            WHERE id IN (SELECT product_id FROM rehearsal_product_category_snapshot)
            """
        )
        connection.execute(
            """
            UPDATE categories SET lifecycle_state='staged', is_active=0, is_assignable=0
            WHERE taxonomy_version=?
            """,
            (CANONICAL_VERSION,),
        )
        connection.execute("UPDATE rehearsal_product_quarantine SET active=0")
        mismatch = connection.execute(
            """
            SELECT count(*) FROM products p
            JOIN rehearsal_product_category_snapshot s ON s.product_id=p.id
            WHERE p.category_id IS NOT s.original_category_id
            """
        ).fetchone()[0]
        check(mismatch == 0, "rollback product mapping mismatch")
        dangling = connection.execute(
            """
            SELECT count(*) FROM products p
            LEFT JOIN categories c ON c.id=p.category_id
            WHERE p.category_id IS NOT NULL AND c.id IS NULL
            """
        ).fetchone()[0]
        check(dangling == 0, "rollback dangling product category")
        db_validation = validate_database(connection)
        history_rows = connection.execute(
            "SELECT count(*) FROM taxonomy_node_relationships"
        ).fetchone()[0]
        tombstones = connection.execute(
            """
            SELECT count(*) FROM taxonomy_node_relationships
            WHERE successor_category_id IS NULL
            """
        ).fetchone()[0]
        connection.execute("COMMIT")
        return {
            "product_mapping_mismatches": mismatch,
            "dangling_product_categories": dangling,
            "history_rows_preserved": history_rows,
            "tombstones_preserved": tombstones,
            "database": db_validation,
        }
    except Exception:
        connection.execute("ROLLBACK")
        raise


def run_expected_db_failure(
    connection: sqlite3.Connection, name: str, operation: Callable[[], None]
) -> str:
    connection.execute("BEGIN")
    try:
        operation()
        connection.execute("COMMIT")
    except (sqlite3.IntegrityError, sqlite3.OperationalError, RehearsalError):
        if connection.in_transaction:
            connection.execute("ROLLBACK")
        return "PASS"
    raise RehearsalError(f"failure injection did not fail: {name}")


def failure_injection(
    connection: sqlite3.Connection,
    manifest: list[dict[str, str]],
    representative: list[dict[str, str]],
) -> dict[str, str]:
    results: dict[str, str] = {}
    canonical_row = connection.execute(
        "SELECT * FROM categories WHERE taxonomy_version=? LIMIT 1",
        (CANONICAL_VERSION,),
    ).fetchone()
    root = connection.execute(
        """
        SELECT id FROM categories
        WHERE taxonomy_version=? AND level=1 LIMIT 1
        """,
        (CANONICAL_VERSION,),
    ).fetchone()[0]
    descendant = connection.execute(
        """
        WITH RECURSIVE d(id) AS (
          SELECT id FROM categories WHERE parent_id=?
          UNION ALL
          SELECT c.id FROM categories c JOIN d ON c.parent_id=d.id
        ) SELECT id FROM d ORDER BY id DESC LIMIT 1
        """,
        (root,),
    ).fetchone()[0]

    def insert_category(**overrides: Any) -> None:
        values = {
            "id": str(uuid.uuid4()),
            "name": "Failure injection",
            "parent_id": root,
            "source_key": f"FAILURE-{uuid.uuid4()}",
            "slug": f"failure-{uuid.uuid4()}",
            "level": 2,
            "lifecycle_state": "staged",
            "is_assignable": 0,
            "policy_class": "NORMAL",
            "professional_review_status": "not_required",
            "taxonomy_version": "failure-injection",
        }
        values.update(overrides)
        connection.execute(
            """
            INSERT INTO categories(
              id, name, parent_id, is_active, source_key, slug, level,
              lifecycle_state, is_assignable, policy_class,
              professional_review_status, taxonomy_version
            ) VALUES (?, ?, ?, 0, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                values["id"], values["name"], values["parent_id"], values["source_key"],
                values["slug"], values["level"], values["lifecycle_state"],
                values["is_assignable"], values["policy_class"],
                values["professional_review_status"], values["taxonomy_version"],
            ),
        )

    results["missing_parent"] = run_expected_db_failure(
        connection,
        "missing_parent",
        lambda: insert_category(parent_id=str(uuid.uuid4())),
    )
    results["duplicate_slug"] = run_expected_db_failure(
        connection,
        "duplicate_slug",
        lambda: insert_category(slug=canonical_row["slug"]),
    )
    results["cycle"] = run_expected_db_failure(
        connection,
        "cycle",
        lambda: connection.execute("UPDATE categories SET parent_id=? WHERE id=?", (descendant, root)),
    )
    results["invalid_level"] = run_expected_db_failure(
        connection,
        "invalid_level",
        lambda: insert_category(level=5),
    )
    results["policy_unknown"] = run_expected_db_failure(
        connection,
        "policy_unknown",
        lambda: insert_category(policy_class="UNKNOWN"),
    )

    alias = connection.execute(
        "SELECT * FROM taxonomy_aliases WHERE alias_kind='LEGACY_REDIRECT' LIMIT 1"
    ).fetchone()
    results["duplicate_alias"] = run_expected_db_failure(
        connection,
        "duplicate_alias",
        lambda: connection.execute(
            """
            INSERT INTO taxonomy_aliases(
              id, alias_kind, alias_locator, alias_text, source_alias_type,
              resolution_state, direct_target_category_id, taxonomy_version
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                str(uuid.uuid4()), alias["alias_kind"], alias["alias_locator"],
                alias["alias_text"], alias["source_alias_type"], alias["resolution_state"],
                alias["direct_target_category_id"], alias["taxonomy_version"],
            ),
        ),
    )
    results["bad_product_category"] = run_expected_db_failure(
        connection,
        "bad_product_category",
        lambda: connection.execute(
            "UPDATE products SET category_id=? WHERE id=?",
            (str(uuid.uuid4()), representative[0]["product_id"]),
        ),
    )

    mutated = [dict(row) for row in manifest]
    mutated[1]["PARENT_PLANNING_KEY"] = "CANONICAL-MISSING"
    try:
        validate_sources(mutated, [], [])
    except RehearsalError:
        results["orphan_manifest"] = "PASS"
    else:
        raise RehearsalError("orphan manifest did not fail")

    split_manual_id = next(
        item["product_id"] for item in representative if item["role"] == "split-manual"
    )
    quarantined = connection.execute(
        "SELECT active, reason FROM rehearsal_product_quarantine WHERE product_id=?",
        (split_manual_id,),
    ).fetchone()
    check(quarantined and quarantined["active"] == 1, "split without decision not quarantined")
    results["split_without_decision"] = "PASS"

    marker = f"MID-FAILURE-{uuid.uuid4()}"
    connection.execute("BEGIN")
    try:
        insert_category(source_key=marker)
        raise RehearsalError("injected mid-migration failure")
    except RehearsalError:
        connection.execute("ROLLBACK")
    check(
        connection.execute("SELECT count(*) FROM categories WHERE source_key=?", (marker,)).fetchone()[0] == 0,
        "mid-migration partial write survived",
    )
    results["mid_migration_failure"] = "PASS"
    return results


def timed_query(
    connection: sqlite3.Connection,
    sql: str,
    parameters: Iterable[Any] = (),
    repeats: int = 100,
) -> dict[str, Any]:
    samples: list[float] = []
    row_count = 0
    parameters = tuple(parameters)
    for _ in range(repeats):
        start = time.perf_counter_ns()
        rows = connection.execute(sql, parameters).fetchall()
        samples.append((time.perf_counter_ns() - start) / 1_000_000)
        row_count = len(rows)
    ordered = sorted(samples)
    return {
        "rows": row_count,
        "repeats": repeats,
        "median_ms": round(statistics.median(samples), 4),
        "p95_ms": round(ordered[int(0.95 * (len(ordered) - 1))], 4),
    }


def query_sanity(connection: sqlite3.Connection) -> dict[str, dict[str, Any]]:
    product_category = connection.execute(
        """
        SELECT p.category_id
        FROM products p
        JOIN categories c ON c.id=p.category_id AND c.taxonomy_version=?
        WHERE NOT EXISTS (
          SELECT 1 FROM rehearsal_product_quarantine q
          WHERE q.product_id=p.id AND q.active=1
        )
        ORDER BY p.name
        LIMIT 1
        """,
        (CANONICAL_VERSION,),
    ).fetchone()
    check(product_category is not None, "no migrated product available for query sanity")
    root_id = product_category["category_id"]
    while True:
        parent = connection.execute(
            "SELECT parent_id FROM categories WHERE id=?", (root_id,)
        ).fetchone()[0]
        if parent is None:
            break
        root_id = parent
    leaf = connection.execute(
        """
        SELECT id FROM categories
        WHERE taxonomy_version=? AND is_assignable=1 AND is_active=1
        LIMIT 1
        """,
        (CANONICAL_VERSION,),
    ).fetchone()[0]
    alias_slug = connection.execute(
        """
        SELECT alias_slug FROM taxonomy_aliases
        WHERE alias_kind='LEGACY_REDIRECT' AND resolution_state='RESOLVED'
        LIMIT 1
        """
    ).fetchone()[0]
    return {
        "roots": timed_query(
            connection,
            "SELECT id, name FROM categories WHERE taxonomy_version=? AND level=1 ORDER BY sort_order",
            (CANONICAL_VERSION,),
        ),
        "children": timed_query(
            connection,
            "SELECT id, name FROM categories WHERE parent_id=? ORDER BY sort_order",
            (root_id,),
        ),
        "descendants": timed_query(
            connection,
            """
            WITH RECURSIVE d(id, level) AS (
              SELECT id, level FROM categories WHERE id=?
              UNION ALL
              SELECT c.id, c.level FROM categories c JOIN d ON c.parent_id=d.id
            ) SELECT id, level FROM d
            """,
            (root_id,),
        ),
        "breadcrumb": timed_query(
            connection,
            """
            WITH RECURSIVE trail(id, parent_id, name, level) AS (
              SELECT id, parent_id, name, level FROM categories WHERE id=?
              UNION ALL
              SELECT c.id, c.parent_id, c.name, c.level
              FROM categories c JOIN trail t ON t.parent_id=c.id
            ) SELECT id, name, level FROM trail ORDER BY level
            """,
            (leaf,),
        ),
        "products_by_descendant_scope": timed_query(
            connection,
            """
            WITH RECURSIVE d(id) AS (
              SELECT id FROM categories WHERE id=?
              UNION ALL
              SELECT c.id FROM categories c JOIN d ON c.parent_id=d.id
            )
            SELECT p.id, p.name FROM products p
            WHERE p.category_id IN (SELECT id FROM d)
              AND NOT EXISTS (
                SELECT 1 FROM rehearsal_product_quarantine q
                WHERE q.product_id=p.id AND q.active=1
              )
            """,
            (root_id,),
        ),
        "alias_lookup": timed_query(
            connection,
            """
            SELECT a.resolution_state, a.direct_target_category_id
            FROM taxonomy_aliases a
            WHERE a.alias_kind='LEGACY_REDIRECT' AND lower(a.alias_slug)=lower(?)
            """,
            (alias_slug,),
        ),
    }


def base_dependency_counts(connection: sqlite3.Connection) -> dict[str, int]:
    tables = (
        "categories",
        "products",
        "shops",
        "shop_products",
        "reviews",
        "wishlist",
        "cart_items_v2",
        "verified_transaction_items",
    )
    return {table: connection.execute(f"SELECT count(*) FROM {table}").fetchone()[0] for table in tables}


def run(repo_root: Path, db_path: Path) -> dict[str, Any]:
    manifest_path = repo_root / "docs" / "TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv"
    registry_path = repo_root / "docs" / "TAXONOMY_W34_FINAL_SPLIT_MERGE_REGISTRY.csv"
    aliases_path = repo_root / "docs" / "TAXONOMY_W34_ALIAS_REDIRECT_MANIFEST.csv"
    manifest = read_csv(manifest_path)
    registry = read_csv(registry_path)
    aliases = read_csv(aliases_path)
    source_validation = validate_sources(manifest, registry, aliases)

    connection = connect(db_path)
    try:
        create_current_schema(connection)
        representative = seed_representative_data(connection, manifest, registry)
        current_counts = base_dependency_counts(connection)
        apply_additive_schema(connection)
        backfill_legacy_metadata(connection, representative)

        forward_results: list[dict[str, Any]] = []
        rollback_results: list[dict[str, Any]] = []

        forward_results.append(forward_cycle(connection, manifest, registry, aliases, representative))
        rollback_results.append(rollback_cycle(connection))

        forward_results.append(forward_cycle(connection, manifest, registry, aliases, representative))
        failures = failure_injection(connection, manifest, representative)
        queries = query_sanity(connection)
        rollback_results.append(rollback_cycle(connection))

        final_counts = base_dependency_counts(connection)
        # Canonical category rows intentionally survive rollback as staged,
        # inactive history. Commercial/evidence dependencies must remain exact.
        protected_tables = set(current_counts) - {"categories"}
        check(
            all(current_counts[name] == final_counts[name] for name in protected_tables),
            "protected dependency counts changed after rollback",
        )
        final_db = validate_database(connection)
        check(final_db["active"] == 0 and final_db["assignable"] == 0, "final rollback not staged")
        foreign_key_failures = connection.execute("PRAGMA foreign_key_check").fetchall()
        check(not foreign_key_failures, "foreign key check failed")

        return {
            "environment": {
                "python": f"{__import__('sys').version_info.major}.{__import__('sys').version_info.minor}.{__import__('sys').version_info.micro}",
                "sqlite": sqlite3.sqlite_version,
                "database": "disposable local SQLite relational compatibility harness",
                "postgresql_server_available": False,
                "remote_access": False,
            },
            "source_validation": source_validation,
            "representative_products": len(representative),
            "representative_roles": [item["role"] for item in representative],
            "current_dependency_counts": current_counts,
            "forward_runs": len(forward_results),
            "rollback_runs": len(rollback_results),
            "forward_results": forward_results,
            "rollback_results": rollback_results,
            "failure_injection": failures,
            "query_sanity": queries,
            "final_dependency_counts": final_counts,
            "final_database": final_db,
            "foreign_key_check_rows": len(foreign_key_failures),
            "remote_access_performed": False,
        }
    finally:
        connection.close()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
    )
    parser.add_argument("--db", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--quiet", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.db:
        args.db.parent.mkdir(parents=True, exist_ok=True)
        result = run(args.repo_root.resolve(), args.db.resolve())
    else:
        with tempfile.TemporaryDirectory(prefix="esnaftavar-w35-") as temp_dir:
            result = run(args.repo_root.resolve(), Path(temp_dir) / "clean-room.sqlite3")
    output = json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output + "\n", encoding="utf-8")
    if not args.quiet:
        print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
