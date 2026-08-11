import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String migration;

  setUpAll(() {
    migration = File(
      'supabase_migration_qr_verified_purchase_release_hardening.sql',
    ).readAsStringSync().replaceAll('\r\n', '\n');
  });

  test('migration is additive and keeps both RPCs permission-scoped', () {
    expect(_occurrences(migration, 'CREATE OR REPLACE FUNCTION'), 2);
    expect(_occurrences(migration, '\nSECURITY DEFINER\n'), 2);
    expect(_occurrences(migration, 'SET search_path ='), 2);
    expect(migration, contains('BEGIN;'));
    expect(migration, contains('COMMIT;'));
    expect(
      RegExp(
        r'\b(DROP\s+TABLE|TRUNCATE|DELETE\s+FROM)\b',
        caseSensitive: false,
      ).hasMatch(migration),
      isFalse,
    );
    expect(
      migration,
      contains('REVOKE ALL ON FUNCTION public.create_qr_session(UUID)'),
    );
    expect(
      migration,
      contains('GRANT EXECUTE ON FUNCTION public.create_qr_session(UUID)'),
    );
    expect(
      migration,
      contains('REVOKE ALL ON FUNCTION public.confirm_qr_session(TEXT)'),
    );
    expect(
      migration,
      contains('GRANT EXECUTE ON FUNCTION public.confirm_qr_session(TEXT)'),
    );
  });

  test('creation locks cart and catalog before taking its expiry clock', () {
    final function = _section(
      migration,
      'CREATE OR REPLACE FUNCTION public.create_qr_session',
      'REVOKE ALL ON FUNCTION public.create_qr_session',
    );
    final cartLock = function.indexOf('FOR UPDATE;');
    final catalogLock = function.indexOf('FOR SHARE OF sp, p;');
    final clockRefresh = function.indexOf('v_now := clock_timestamp();');

    expect(cartLock, greaterThanOrEqualTo(0));
    expect(catalogLock, greaterThan(cartLock));
    expect(clockRefresh, greaterThan(catalogLock));
    expect(function, contains('p.is_active IS NOT TRUE'));
    expect(function, contains('AND p.is_active = TRUE'));
  });

  test('confirmation takes every blocking lock before expiry comparison', () {
    final function = _section(
      migration,
      'CREATE OR REPLACE FUNCTION public.confirm_qr_session',
      'REVOKE ALL ON FUNCTION public.confirm_qr_session',
    );
    final clockRefresh = function.indexOf('v_now := clock_timestamp();');
    final beforeClock = function.substring(0, clockRefresh);
    final expiryCheck = function.indexOf('v_session.expires_at <= v_now');

    expect(clockRefresh, greaterThanOrEqualTo(0));
    expect(_occurrences(beforeClock, 'FOR UPDATE;'), 2);
    expect(_occurrences(beforeClock, 'FOR SHARE;'), greaterThanOrEqualTo(2));
    expect(expiryCheck, greaterThan(clockRefresh));
    expect(function, contains("SET status = 'used'"));
    expect(function, contains('used_at = v_now'));
    expect(function, contains('v_now\n  FROM public.shops AS s'));
    expect(function, contains("SET status = 'checked_out'"));
  });
}

String _section(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start);
  if (start < 0 || end <= start) {
    throw StateError('Migration section could not be found.');
  }
  return source.substring(start, end);
}

int _occurrences(String source, String value) =>
    value.allMatches(source).length;
