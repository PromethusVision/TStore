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
];

const _expectedPublicTables = <String>{
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
  });

  test(
    'canonical migration filenames define the required dependency order',
    () {
      expect(migrationFiles.map(_basename).toList(), _expectedMigrationFiles);

      for (final file in migrationFiles) {
        final sql = file.readAsStringSync();
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
        expect(sql, contains("SET LOCAL lock_timeout = '"), reason: file.path);
        expect(
          sql,
          contains("SET LOCAL statement_timeout = '"),
          reason: file.path,
        );
        expect(sql, contains(r'DO $preflight$'), reason: file.path);
      }
    },
  );

  test('canonical chain creates exactly the expected 23 public tables', () {
    final createdTables = _captures(
      canonicalSql,
      RegExp(r'^CREATE TABLE public\.(\w+)\s*\(', multiLine: true),
    );

    expect(createdTables.toSet(), _expectedPublicTables);
    expect(createdTables, hasLength(23));
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

    expect(revokedTables, _expectedPublicTables);
  });

  test('destructive bootstrap and transitional replacement SQL are absent', () {
    final executableSql = _withoutLineComments(canonicalSql);
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
  });

  test('only the additive hotfix replaces the profile role guard', () {
    final historicalSql = migrationFiles
        .take(migrationFiles.length - 1)
        .map((file) => file.readAsStringSync())
        .join('\n');
    final hotfixSql = migrationFiles.last.readAsStringSync();

    expect(
      historicalSql,
      isNot(
        matches(RegExp(r'\bCREATE\s+OR\s+REPLACE\b', caseSensitive: false)),
      ),
    );
    expect(
      _captures(
        hotfixSql,
        RegExp(
          r'^CREATE OR REPLACE FUNCTION public\.(\w+)\s*\(',
          multiLine: true,
        ),
      ),
      ['prevent_profile_role_client_escalation'],
    );
    expect(
      hotfixSql,
      isNot(
        matches(
          RegExp(
            r'\b(?:DROP|TRUNCATE|ALTER\s+TABLE|CREATE\s+POLICY)\b',
            caseSensitive: false,
          ),
        ),
      ),
    );
  });

  test('canonical schema contains no environment credentials or data IDs', () {
    final executableSql = _withoutLineComments(canonicalSql);
    final forbiddenPatterns = <RegExp>[
      RegExp(r'\bservice_role\b', caseSensitive: false),
      RegExp(r'\b(?:postgres|postgresql)://', caseSensitive: false),
      RegExp(r'https?://[^\s]*supabase\.(?:co|in)', caseSensitive: false),
      RegExp(r'\beyJ[A-Za-z0-9_-]{20,}', caseSensitive: false),
      RegExp(
        r'\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-'
        r'[89ab][0-9a-f]{3}-[0-9a-f]{12}\b',
        caseSensitive: false,
      ),
    ];

    for (final pattern in forbiddenPatterns) {
      expect(executableSql, isNot(matches(pattern)), reason: pattern.pattern);
    }
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
        r'^\s*CREATE\s+(?:UNIQUE\s+)?INDEX\s+(\w+)',
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
          _occurrences(sql, RegExp(r'AS \$function\$')),
          functionCount,
          reason: file.path,
        );
        expect(
          _occurrences(sql, RegExp(r'\$function\$')),
          functionCount * 2,
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
        expect(
          entry.value,
          matches(
            RegExp(r"SET search_path\s*=\s*(?:''|pg_catalog(?:,\s*\w+)*)"),
          ),
          reason: '${entry.key} must use a fixed safe search_path',
        );
        expect(
          canonicalSql,
          contains('REVOKE ALL ON FUNCTION public.${entry.key}'),
          reason: '${entry.key} must not keep default PUBLIC execute',
        );
      }
    },
  );

  test('profile role guard hotfix preserves the security contract', () {
    final hotfixSql = migrationFiles.last.readAsStringSync();
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
