import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql',
  ).readAsStringSync();
  final rollback = File(
    'tool/production_preview_bridge/rollback.sql',
  ).readAsStringSync();
  final functions = RegExp(
    r'CREATE FUNCTION public\.(\w+)\(',
  ).allMatches(migration).map((m) => m[1]!).toSet();
  test('applied 0012 remains byte-equivalent after LF normalization', () {
    final frozen = File(
      'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql',
    ).readAsStringSync().replaceAll('\r\n', '\n');
    expect(
      sha256.convert(utf8.encode(frozen)).toString(),
      'a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834',
    );
  });
  test(
    '0013 is additive and has exactly the reviewed public facade and private helpers',
    () {
      expect(functions, {
        '_w52kb_assert_contract_v2',
        '_w52kb_visible_v2',
        '_w52kb_assignable',
        '_w52kb_node_json_v2',
        '_w52kb_path_json_v2',
        'taxonomy_capabilities_v2',
        'taxonomy_roots_v2',
        'taxonomy_children_v2',
        'taxonomy_descendants_v2',
        'taxonomy_exact_leaf_v2',
        'taxonomy_breadcrumb_v2',
        'taxonomy_resolve_alias_v2',
        'taxonomy_search_context_v2',
        'production_preview_mappings_v1',
        'production_preview_products_v1',
      });
      expect(migration, isNot(contains('CREATE OR REPLACE')));
      expect(
        migration,
        isNot(matches(RegExp(r'\b(?:DROP|TRUNCATE)\s', caseSensitive: false))),
      );
      expect(
        migration,
        isNot(
          matches(
            RegExp(
              r'^\s*(?:INSERT INTO|UPDATE|DELETE FROM)\s',
              multiLine: true,
            ),
          ),
        ),
      );
      expect(migration, contains('W52KB_EXISTING_CONTRACT_REFUSED'));
      expect(migration, contains("current_setting('server_version')<>'17.6'"));
      expect(migration, contains("SET LOCAL lock_timeout='3s';"));
      expect(migration, contains("SET LOCAL statement_timeout='120s';"));
      expect(
        RegExp(r'^BEGIN;$', multiLine: true).allMatches(migration).length,
        1,
      );
      expect(
        RegExp(r'^COMMIT;$', multiLine: true).allMatches(migration).length,
        1,
      );
    },
  );
  test('allowlist defaults deny, expires, and has no client-access policy', () {
    expect(migration, contains('enabled boolean NOT NULL DEFAULT false'));
    expect(migration, contains('REFERENCES auth.users(id) ON DELETE CASCADE'));
    expect(migration, contains("expires_at<=granted_at+interval '30 days'"));
    expect(
      migration,
      contains(
        'ALTER TABLE production_preview_private.testers ENABLE ROW LEVEL SECURITY',
      ),
    );
    expect(
      migration,
      contains(
        'REVOKE ALL ON production_preview_private.testers FROM PUBLIC,anon,authenticated,service_role',
      ),
    );
    expect(migration, isNot(contains('CREATE POLICY')));
    expect(migration, contains("auth.role() IS DISTINCT FROM 'authenticated'"));
    expect(
      migration,
      contains(
        't.user_id=auth.uid() AND t.enabled AND t.granted_at<=now() AND t.expires_at>now()',
      ),
    );
  });
  test(
    'every function is stable with fixed path; product reads retain caller RLS',
    () {
      final blocks = migration.split('CREATE FUNCTION public.').skip(1);
      expect(blocks.length, 15);
      for (final block in blocks) {
        expect(
          block,
          matches(RegExp(r'\bSTABLE\s+SECURITY\s+(?:DEFINER|INVOKER)')),
        );
        expect(
          block,
          contains(RegExp(r'SET search_path\s*=\s*pg_catalog,\s*public')),
        );
      }
      expect(migration, contains('LANGUAGE plpgsql STABLE SECURITY INVOKER'));
      expect(
        migration,
        contains(
          "REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role",
        ),
      );
      expect(
        migration,
        contains('GRANT EXECUTE ON FUNCTION %s TO authenticated'),
      );
      expect(migration, contains('W52KB_PUBLIC_ACTIVATION_MUST_REMAIN_OFF'));
      expect(migration, contains('W52KB_MAPPING_INCOMPLETE'));
    },
  );
  test(
    'rollback removes exactly 0013 functions and allowlist without CASCADE',
    () {
      expect(
        RegExp(
          r'DROP FUNCTION public\.(\w+)\(',
        ).allMatches(rollback).map((m) => m[1]!).toSet(),
        functions,
      );
      expect(
        RegExp(
          r'DROP TABLE (\S+) RESTRICT;',
        ).allMatches(rollback).map((m) => m[1]!),
        ['production_preview_private.testers'],
      );
      expect(
        rollback,
        contains('DROP SCHEMA production_preview_private RESTRICT;'),
      );
      expect(rollback, isNot(contains('CASCADE')));
      expect(rollback, isNot(contains('DELETE FROM')));
      expect(rollback, isNot(contains('canonical_categories')));
    },
  );
}
