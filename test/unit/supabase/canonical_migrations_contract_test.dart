import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _expectedMigrationFiles = <String>[
  '20260812000100_0001_core_auth_catalog.sql',
  '20260812000200_0002_shops.sql',
  '20260812000300_0003_carts_v2.sql',
  '20260812000400_0004_qr_verified_purchases.sql',
  '20260812000500_0005_verified_shop_ratings.sql',
  '20260812000600_0006_chat_notifications_account.sql',
  '20260812000700_0007_storage_realtime.sql',
  '20260814000800_0008_fix_profile_role_guard.sql',
  '20260815000900_0009_verified_product_reviews_storage.sql',
  '20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql',
  '20260830001100_0011_canonical_taxonomy_contract_v2.sql',
];

const _baselinePublicTables = <String>{
  'addresses',
  'banners',
  'brands',
  'cart_items_v2',
  'carts',
  'categories',
  'chat_messages',
  'customer_saved_locations',
  'legal_consents',
  'notifications',
  'order_items',
  'orders',
  'products',
  'profiles',
  'qr_session_items',
  'qr_sessions',
  'reviews',
  'shop_products',
  'shop_ratings',
  'shops',
  'verified_transaction_items',
  'verified_transactions',
  'wishlist',
};

const _taxonomyAdminTables = <String>{
  'taxonomy_alias_targets',
  'taxonomy_aliases',
  'taxonomy_id_allocations',
  'taxonomy_import_runs',
  'taxonomy_node_relationships',
};

const _taxonomyContractTables = <String>{'taxonomy_contract_config'};

const _expectedPublicTables = <String>{
  ..._baselinePublicTables,
  ..._taxonomyAdminTables,
  ..._taxonomyContractTables,
};

const _forbiddenPlpgsqlLocalIdentifiers = <String>{
  'authorization',
  'constraint',
  'current_catalog',
  'current_date',
  'current_role',
  'current_schema',
  'current_time',
  'current_timestamp',
  'current_user',
  'exception',
  'function',
  'localtime',
  'localtimestamp',
  'position',
  'role',
  'session_user',
  'system_user',
  'table',
  'transaction',
  'trigger',
  'user',
};

void main() {
  late List<File> migrationFiles;
  late String canonicalSql;
  late String baselineCanonicalSql;
  late String taxonomySql;

  setUpAll(() {
    migrationFiles =
        Directory('supabase/migrations')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.sql'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    canonicalSql = migrationFiles
        .map((file) => file.readAsStringSync())
        .join('\n');
    baselineCanonicalSql = migrationFiles
        .take(9)
        .map((file) => file.readAsStringSync())
        .join('\n');
    taxonomySql = migrationFiles
        .singleWhere(
          (file) =>
              _basename(file) ==
              '20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql',
        )
        .readAsStringSync();
  });

  test(
    'canonical migration filenames define the required dependency order',
    () {
      expect(migrationFiles.map(_basename).toList(), _expectedMigrationFiles);

      for (final file in migrationFiles) {
        final sql = file.readAsStringSync();
        final isTaxonomyBootstrap = _basename(file).contains('_0010_');
        final isStrictTaxonomyContract = _basename(file).contains('_0011_');
        expect(
          _occurrences(sql, RegExp(r'^BEGIN;$', multiLine: true)),
          1,
          reason: file.path,
        );
        expect(
          _occurrences(sql, RegExp(r'^COMMIT;$', multiLine: true)),
          1,
          reason: file.path,
        );
        expect(
          sql,
          contains(
            isTaxonomyBootstrap
                ? "SET LOCAL lock_timeout='3s';"
                : "SET LOCAL lock_timeout = '",
          ),
          reason: file.path,
        );
        expect(
          sql,
          contains(
            isTaxonomyBootstrap
                ? "SET LOCAL statement_timeout='120s';"
                : "SET LOCAL statement_timeout = '",
          ),
          reason: file.path,
        );
        expect(
          sql,
          contains(
            isTaxonomyBootstrap
                ? r'DO $w37_exclusive$'
                : isStrictTaxonomyContract
                ? r'DO $w38_baseline_guard$'
                : r'DO $preflight$',
          ),
          reason: file.path,
        );
      }
    },
  );

  test('canonical chain creates exactly the expected 29 public tables', () {
    final createdTables = _captures(
      canonicalSql,
      RegExp(
        r'^CREATE TABLE(?: IF NOT EXISTS)? public\.(\w+)\s*\(',
        multiLine: true,
      ),
    );

    expect(createdTables.toSet(), _expectedPublicTables);
    expect(createdTables, hasLength(_expectedPublicTables.length));
    expect(createdTables.toSet(), hasLength(createdTables.length));
    expect(createdTables, isNot(contains('cart_items')));
    expect(createdTables, isNot(contains('coupons')));
  });

  test('all canonical public tables enable RLS exactly once', () {
    final rlsTables = _captures(
      canonicalSql,
      RegExp(
        r'^ALTER TABLE public\.(\w+) ENABLE ROW LEVEL SECURITY;$',
        multiLine: true,
      ),
    );

    expect(rlsTables.toSet(), _expectedPublicTables);
    expect(rlsTables, hasLength(_expectedPublicTables.length));
  });

  test('all table privileges start from an explicit revoke baseline', () {
    final revokedTables = <String>{};
    final revokeBlocks = RegExp(
      r'REVOKE ALL ON TABLE([\s\S]*?)FROM PUBLIC, anon, authenticated;',
      caseSensitive: false,
    ).allMatches(canonicalSql);

    for (final block in revokeBlocks) {
      revokedTables.addAll(
        _captures(
          block.group(1)!,
          RegExp(r'public\.(\w+)', caseSensitive: false),
        ),
      );
    }

    expect(revokedTables, {
      ..._baselinePublicTables,
      ..._taxonomyContractTables,
    });
    for (final table in _taxonomyAdminTables) {
      expect(
        taxonomySql,
        contains('REVOKE ALL ON public.$table FROM anon,authenticated;'),
      );
    }
  });

  test('destructive bootstrap and transitional replacement SQL are absent', () {
    final executableSql = _withoutLineComments(baselineCanonicalSql);
    final forbiddenPatterns = <RegExp>[
      RegExp(r'\bDROP\s+TABLE\b', caseSensitive: false),
      RegExp(r'\bDROP\s+SCHEMA\b', caseSensitive: false),
      RegExp(r'\bDROP\s+TRIGGER\b', caseSensitive: false),
      RegExp(r'\bDROP\s+FUNCTION\b', caseSensitive: false),
      RegExp(r'\bDROP\b[\s\S]{0,80}\bCASCADE\b', caseSensitive: false),
      RegExp(r'\bTRUNCATE\b', caseSensitive: false),
      RegExp(r'\bGRANT\s+ALL\b', caseSensitive: false),
    ];

    for (final pattern in forbiddenPatterns) {
      expect(executableSql, isNot(matches(pattern)), reason: pattern.pattern);
    }

    final taxonomyExecutableSql = _withoutLineComments(taxonomySql);
    for (final pattern in forbiddenPatterns.where(
      (pattern) => pattern.pattern != r'\bDROP\s+TRIGGER\b',
    )) {
      expect(
        taxonomyExecutableSql,
        isNot(matches(pattern)),
        reason: pattern.pattern,
      );
    }
    expect(
      _captures(
        taxonomyExecutableSql,
        RegExp(r'DROP TRIGGER IF EXISTS (\w+)', caseSensitive: false),
      ),
      ['validate_taxonomy_category_hierarchy'],
    );
  });

  test('only designated forward migrations replace installed functions', () {
    final initialCanonicalSql = migrationFiles
        .take(7)
        .map((file) => file.readAsStringSync())
        .join('\n');
    final profileHotfixSql = migrationFiles
        .singleWhere(
          (file) =>
              _basename(file) ==
              '20260814000800_0008_fix_profile_role_guard.sql',
        )
        .readAsStringSync();
    final wave6Sql = migrationFiles
        .singleWhere(
          (file) =>
              _basename(file) ==
              '20260815000900_0009_verified_product_reviews_storage.sql',
        )
        .readAsStringSync();

    expect(
      initialCanonicalSql,
      isNot(
        matches(RegExp(r'\bCREATE\s+OR\s+REPLACE\b', caseSensitive: false)),
      ),
    );
    expect(
      _captures(
        profileHotfixSql,
        RegExp(
          r'^CREATE OR REPLACE FUNCTION public\.(\w+)\s*\(',
          multiLine: true,
        ),
      ),
      ['prevent_profile_role_client_escalation'],
    );
    expect(
      profileHotfixSql,
      isNot(
        matches(
          RegExp(
            r'\b(?:DROP|TRUNCATE|ALTER\s+TABLE|CREATE\s+POLICY)\b',
            caseSensitive: false,
          ),
        ),
      ),
    );
    expect(
      _captures(
        wave6Sql,
        RegExp(
          r'^CREATE OR REPLACE FUNCTION public\.(\w+)\s*\(',
          multiLine: true,
        ),
      ).toSet(),
      {
        'get_qr_session_for_verification',
        'create_qr_session',
        'confirm_qr_session',
        'refresh_product_rating_after_review',
      },
    );
    expect(
      wave6Sql,
      isNot(
        matches(
          RegExp(
            r'\b(?:DROP\s+TABLE|DROP\s+SCHEMA|DROP\s+FUNCTION|'
            r'DROP\s+TRIGGER|TRUNCATE)\b',
            caseSensitive: false,
          ),
        ),
      ),
    );
    expect(
      _captures(
        taxonomySql,
        RegExp(
          r'^CREATE OR REPLACE FUNCTION public\.(\w+)\s*\(',
          multiLine: true,
        ),
      ).toSet(),
      {
        'validate_taxonomy_category_hierarchy',
        'taxonomy_roots_v1',
        'taxonomy_children_v1',
        'taxonomy_descendants_v1',
        'taxonomy_exact_leaf_v1',
        'taxonomy_breadcrumb_v1',
        'taxonomy_resolve_alias_v1',
        'taxonomy_search_context_v1',
      },
    );
  });

  test('canonical schema contains no environment credentials or data IDs', () {
    final executableSql = _withoutLineComments(canonicalSql);
    final forbiddenPatterns = <RegExp>[
      RegExp(
        r'\b(?:service_role_key|supabase_service_role_key)\b\s*[:=]',
        caseSensitive: false,
      ),
      RegExp(r'\b(?:postgres|postgresql)://', caseSensitive: false),
      RegExp(r'https?://[^\s]*supabase\.(?:co|in)', caseSensitive: false),
      RegExp(r'\beyJ[A-Za-z0-9_-]{20,}', caseSensitive: false),
    ];

    for (final pattern in forbiddenPatterns) {
      expect(executableSql, isNot(matches(pattern)), reason: pattern.pattern);
    }
    expect(
      _withoutLineComments(baselineCanonicalSql),
      isNot(
        matches(
          RegExp(
            r'\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-'
            r'[89ab][0-9a-f]{3}-[0-9a-f]{12}\b',
            caseSensitive: false,
          ),
        ),
      ),
    );
    expect(
      taxonomySql,
      contains(
        '-- Package SHA-256: '
        'f73d6c0f432dd788a4f47a807280017fb068d3cdc21455e8d277a0767511f0a2',
      ),
    );
  });

  test('named canonical objects are not duplicated', () {
    final constraints = _captures(
      canonicalSql,
      RegExp(r'\bCONSTRAINT\s+(\w+)', caseSensitive: false),
    );
    final triggers = _captures(
      canonicalSql,
      RegExp(
        r'^\s*CREATE TRIGGER\s+(\w+)',
        caseSensitive: false,
        multiLine: true,
      ),
    );
    final functions = _captures(
      canonicalSql,
      RegExp(
        r'^CREATE FUNCTION public\.(\w+)\s*\(',
        caseSensitive: false,
        multiLine: true,
      ),
    );
    final indexes = _captures(
      canonicalSql,
      RegExp(
        r'^\s*CREATE\s+(?:UNIQUE\s+)?INDEX\s+(?:IF NOT EXISTS\s+)?(\w+)',
        caseSensitive: false,
        multiLine: true,
      ),
    );
    final policies = _captures(
      canonicalSql,
      RegExp(
        r'^\s*CREATE\s+POLICY\s+(\w+)',
        caseSensitive: false,
        multiLine: true,
      ),
    );

    _expectUnique(constraints, label: 'constraint');
    _expectUnique(triggers, label: 'trigger');
    _expectUnique(functions, label: 'function');
    _expectUnique(indexes, label: 'index');
    _expectUnique(policies, label: 'policy');

    expect(
      _occurrences(canonicalSql, RegExp('chat_messages_content_length_check')),
      1,
    );
    expect(
      triggers.where(
        (name) => name == 'set_customer_saved_locations_updated_at',
      ),
      hasLength(1),
    );
    expect(functions.where((name) => name == 'handle_new_user'), hasLength(1));
    expect(
      functions.where((name) => name == 'create_qr_session'),
      hasLength(1),
    );
    expect(
      functions.where((name) => name == 'confirm_qr_session'),
      hasLength(1),
    );
  });

  test(
    'function and procedural block delimiters are structurally complete',
    () {
      for (final file in migrationFiles) {
        final sql = file.readAsStringSync();
        final functionCount = _occurrences(
          sql,
          RegExp(r'^CREATE(?: OR REPLACE)? FUNCTION public\.', multiLine: true),
        );

        expect(
          _occurrences(sql, RegExp(r'AS \$\w+\$')),
          functionCount,
          reason: file.path,
        );

        final proceduralTags = RegExp(r'\$(\w+)\$').allMatches(sql);
        final tagNames = proceduralTags.map((match) => match.group(1)!).toSet();
        for (final tag in tagNames) {
          expect(
            _occurrences(sql, RegExp('\\\$$tag\\\$')).isEven,
            isTrue,
            reason: '${file.path}: unpaired \$$tag\$',
          );
        }
      }
    },
  );

  test('PL/pgSQL locals avoid PostgreSQL special SQL identifiers', () {
    final conflictingLocals = <String>[];

    for (final file in migrationFiles) {
      final sql = file.readAsStringSync();
      for (final declareBlock in RegExp(
        r'\bDECLARE\s+([\s\S]*?)\bBEGIN\b',
        caseSensitive: false,
      ).allMatches(sql)) {
        final localIdentifiers = _captures(
          declareBlock.group(1)!,
          RegExp(
            r'^\s*([a-z_][a-z0-9_]*)\s+(?:CONSTANT\s+)?'
            r'(?:UUID|TEXT|TIMESTAMPTZ|INTEGER|NUMERIC|JSONB|BOOLEAN|'
            r'public\.\w+%ROWTYPE)\b',
            caseSensitive: false,
            multiLine: true,
          ),
        );

        for (final identifier in localIdentifiers) {
          if (_forbiddenPlpgsqlLocalIdentifiers.contains(
            identifier.toLowerCase(),
          )) {
            conflictingLocals.add('${_basename(file)}:$identifier');
          }
        }
      }
    }

    expect(
      conflictingLocals,
      isEmpty,
      reason:
          'PL/pgSQL locals must not shadow PostgreSQL special SQL '
          'expressions or keywords.',
    );
  });

  test(
    'effective canonical functions do not schema-qualify SQL expressions',
    () {
      final invalidExpression = RegExp(
        r'\b(?:pg_catalog|public|auth)\.'
        r'(?:coalesce|nullif|greatest|least|current_date|current_time|'
        r'current_timestamp|localtime|localtimestamp)\b',
        caseSensitive: false,
      );
      final invalidDefinitions = _functionSections(canonicalSql).entries
          .where((entry) => invalidExpression.hasMatch(entry.value))
          .map((entry) => entry.key)
          .toList();

      expect(
        invalidDefinitions,
        isEmpty,
        reason:
            'PostgreSQL special syntax expressions cannot be called as '
            'schema-qualified functions.',
      );
    },
  );

  test(
    'every SECURITY DEFINER function fixes search_path and revokes execute',
    () {
      final functionSections = _functionSections(canonicalSql);
      final definerSections = functionSections.entries.where(
        (entry) => entry.value.contains('SECURITY DEFINER'),
      );

      expect(definerSections, isNotEmpty);
      for (final entry in definerSections) {
        final isTaxonomyReadFunction = {
          'taxonomy_resolve_alias_v1',
          'taxonomy_search_context_v1',
        }.contains(entry.key);
        expect(
          entry.value,
          matches(
            RegExp(
              isTaxonomyReadFunction
                  ? r'SET search_path\s*=\s*public'
                  : r"SET search_path\s*=\s*(?:''|pg_catalog(?:,\s*\w+)*)",
            ),
          ),
          reason: '${entry.key} must use a fixed safe search_path',
        );
        expect(
          canonicalSql,
          contains('REVOKE ALL ON FUNCTION public.${entry.key}'),
          reason: '${entry.key} must not keep default PUBLIC execute',
        );
        if (isTaxonomyReadFunction) {
          expect(
            baselineCanonicalSql,
            contains(
              'REVOKE CREATE ON SCHEMA public FROM PUBLIC, anon, authenticated;',
            ),
            reason: 'public search_path requires a non-user-writable schema',
          );
        }
      }
    },
  );

  test('profile role guard hotfix preserves the security contract', () {
    final hotfixSql = migrationFiles
        .singleWhere(
          (file) =>
              _basename(file) ==
              '20260814000800_0008_fix_profile_role_guard.sql',
        )
        .readAsStringSync();
    final effectiveGuard = _functionSections(
      canonicalSql,
    )['prevent_profile_role_client_escalation'];

    expect(effectiveGuard, isNotNull);
    expect(effectiveGuard, contains('SECURITY DEFINER'));
    expect(effectiveGuard, contains("SET search_path = ''"));
    expect(
      effectiveGuard,
      contains("AND coalesce(NEW.role, 'customer') <> 'customer'"),
    );
    expect(effectiveGuard, isNot(contains('pg_catalog.coalesce')));
    expect(
      effectiveGuard,
      contains("TG_OP = 'UPDATE' AND OLD.role IS DISTINCT FROM NEW.role"),
    );
    expect(_occurrences(effectiveGuard!, RegExp("USING ERRCODE = '42501'")), 2);
    expect(effectiveGuard, contains('RETURN NEW;'));
    expect(
      hotfixSql,
      contains(
        'REVOKE ALL ON FUNCTION '
        'public.prevent_profile_role_client_escalation()',
      ),
    );
    expect(
      hotfixSql,
      isNot(
        matches(
          RegExp(
            r'GRANT\s+EXECUTE\s+ON\s+FUNCTION\s+'
            r'public\.prevent_profile_role_client_escalation',
            caseSensitive: false,
          ),
        ),
      ),
    );
    expect(hotfixSql, isNot(contains('CREATE TRIGGER')));
    expect(hotfixSql, isNot(contains('DROP TRIGGER')));
  });

  test(
    'auth.users remains managed and signup trigger is not blindly dropped',
    () {
      final executableSql = _withoutLineComments(canonicalSql);

      expect(executableSql, contains("to_regclass('auth.users')"));
      expect(executableSql, contains('REFERENCES auth.users(id)'));
      expect(executableSql, contains('AFTER INSERT ON auth.users'));
      expect(
        executableSql,
        isNot(
          matches(
            RegExp(
              r'\b(?:CREATE|ALTER|DROP)\s+TABLE\s+auth\.users\b',
              caseSensitive: false,
            ),
          ),
        ),
      );
      expect(
        executableSql,
        isNot(
          matches(
            RegExp(
              r'DROP\s+TRIGGER\s+.*on_auth_user_created',
              caseSensitive: false,
            ),
          ),
        ),
      );
    },
  );

  test('chat and notification mutation grants are least privilege', () {
    expect(
      canonicalSql,
      contains(
        'GRANT SELECT, INSERT ON TABLE public.chat_messages '
        'TO authenticated;',
      ),
    );
    expect(
      canonicalSql,
      contains(
        'GRANT UPDATE (is_read) ON TABLE public.chat_messages '
        'TO authenticated;',
      ),
    );
    expect(
      canonicalSql,
      contains(
        'GRANT SELECT, DELETE ON TABLE public.notifications '
        'TO authenticated;',
      ),
    );
    expect(
      canonicalSql,
      contains(
        'GRANT UPDATE (is_read) ON TABLE public.notifications '
        'TO authenticated;',
      ),
    );
    expect(
      canonicalSql,
      isNot(
        contains('GRANT SELECT, INSERT, UPDATE ON TABLE public.chat_messages'),
      ),
    );
    expect(
      canonicalSql,
      isNot(
        contains('GRANT SELECT, UPDATE, DELETE ON TABLE public.notifications'),
      ),
    );
    expect(
      canonicalSql,
      isNot(
        matches(
          RegExp(
            r'GRANT[\s\S]{0,80}INSERT[\s\S]{0,80}'
            r'public\.notifications',
            caseSensitive: false,
          ),
        ),
      ),
    );
    expect(
      canonicalSql,
      matches(
        RegExp(
          r"has_table_privilege\(\s*'authenticated',\s*"
          r"'public\.notifications',\s*'INSERT'",
        ),
      ),
    );
  });

  test('QR RPCs preserve final lock and fresh-clock hardening', () {
    final qrSql = migrationFiles[3].readAsStringSync();

    expect(qrSql, contains('FOR SHARE OF listing, product;'));
    expect(qrSql, contains('FOR UPDATE;'));
    expect(
      _occurrences(qrSql, RegExp(r'v_current_time := clock_timestamp\(\);')),
      greaterThanOrEqualTo(2),
    );
    expect(qrSql, contains('qr_sessions_one_active_per_cart_idx'));
    expect(qrSql, contains('ON DELETE RESTRICT'));
    expect(
      qrSql,
      contains('CREATE FUNCTION public.get_qr_session_for_verification'),
    );
    expect(qrSql, contains('CREATE FUNCTION public.create_qr_session'));
    expect(qrSql, contains('CREATE FUNCTION public.confirm_qr_session'));
  });

  test(
    'Realtime is explicit while Storage remains least-privilege blocked',
    () {
      final migration = migrationFiles
          .singleWhere(
            (file) =>
                _basename(file) == '20260812000700_0007_storage_realtime.sql',
          )
          .readAsStringSync();
      const buckets = <String>[
        'product-images',
        'category-images',
        'brand-logos',
        'banner-images',
        'avatars',
        'review-images',
      ];

      for (final bucket in buckets) {
        expect(migration, contains(bucket));
      }
      expect(
        migration,
        contains(
          'ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages',
        ),
      );
      expect(
        migration,
        contains(
          'ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications',
        ),
      );
      expect(
        migration,
        isNot(
          matches(
            RegExp(r'INSERT\s+INTO\s+storage\.buckets', caseSensitive: false),
          ),
        ),
      );
      expect(
        migration,
        isNot(
          matches(
            RegExp(
              r'CREATE\s+POLICY[\s\S]*storage\.objects',
              caseSensitive: false,
            ),
          ),
        ),
      );
    },
  );

  test('Wave 6 provisions only the three frozen public media buckets', () {
    final migration = migrationFiles
        .singleWhere(
          (file) =>
              _basename(file) ==
              '20260815000900_0009_verified_product_reviews_storage.sql',
        )
        .readAsStringSync();

    for (final bucket in [
      'product-images',
      'category-images',
      'banner-images',
    ]) {
      expect(migration, contains("'$bucket'"));
    }
    expect(migration, isNot(contains("'brand-logos'")));
    expect(migration, isNot(contains("'avatars'")));
    expect(migration, isNot(contains("'review-images'")));
    expect(
      migration,
      contains("ARRAY['image/jpeg', 'image/png', 'image/webp']::TEXT[]"),
    );
    expect(migration, contains('8388608'));
    expect(migration, contains('2097152'));
    expect(migration, contains('5242880'));
    expect(
      migration,
      isNot(
        matches(
          RegExp(
            r'CREATE\s+POLICY[\s\S]*?ON\s+storage\.objects',
            caseSensitive: false,
          ),
        ),
      ),
    );
  });
}

String _basename(File file) => file.uri.pathSegments.last;

int _occurrences(String input, RegExp pattern) =>
    pattern.allMatches(input).length;

List<String> _captures(String input, RegExp pattern) => pattern
    .allMatches(input)
    .map((match) => match.group(1)!)
    .toList(growable: false);

String _withoutLineComments(String sql) =>
    sql.split('\n').map((line) => line.split('--').first).join('\n');

void _expectUnique(List<String> names, {required String label}) {
  final duplicates = names.toSet().where(
    (name) => names.where((candidate) => candidate == name).length > 1,
  );
  expect(duplicates, isEmpty, reason: 'Duplicate $label names: $duplicates');
}

Map<String, String> _functionSections(String sql) {
  final starts = RegExp(
    r'^CREATE(?: OR REPLACE)? FUNCTION public\.(\w+)\s*\(',
    multiLine: true,
  ).allMatches(sql).toList();
  final sections = <String, String>{};

  for (var index = 0; index < starts.length; index++) {
    final match = starts[index];
    final end = index + 1 < starts.length
        ? starts[index + 1].start
        : sql.length;
    sections[match.group(1)!] = sql.substring(match.start, end);
  }

  return sections;
}
