import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _migrationPath =
    'supabase/migrations/'
    '20260815000900_0009_verified_product_reviews_storage.sql';
const _contractPath = 'docs/WAVE_6_REVIEW_RPC_CONTRACT.md';

void main() {
  late String migration;
  late String contract;

  setUpAll(() {
    migration = File(
      _migrationPath,
    ).readAsStringSync().replaceAll('\r\n', '\n');
    contract = File(_contractPath).readAsStringSync().replaceAll('\r\n', '\n');
  });

  test('durable product UUID is captured once and copied into proof', () {
    expect(
      migration,
      contains(
        'ALTER TABLE public.qr_session_items\n  ADD COLUMN product_id UUID;',
      ),
    );
    expect(
      migration,
      contains(
        'ALTER TABLE public.verified_transaction_items\n'
        '  ADD COLUMN product_id UUID;',
      ),
    );
    expect(
      migration,
      contains(
        'INSERT INTO public.qr_session_items (\n'
        '    qr_session_id,\n'
        '    shop_product_id,\n'
        '    product_id,',
      ),
    );
    expect(migration, contains('    product.id,\n    product.name,'));
    expect(
      migration,
      contains(
        'INSERT INTO public.verified_transaction_items (\n'
        '    verified_transaction_id,\n'
        '    shop_product_id,\n'
        '    product_id,',
      ),
    );
    expect(migration, contains('    item.product_id,\n    item.product_name,'));
    expect(
      migration,
      isNot(
        matches(
          RegExp(
            r'UPDATE\s+public\.(?:qr_session_items|'
            r'verified_transaction_items)[\s\S]{0,180}'
            r'SET\s+product_id',
            caseSensitive: false,
          ),
        ),
      ),
      reason: 'Historical snapshots must not use a present-day catalog join.',
    );
    expect(migration, contains("'[QR_PRODUCT_SNAPSHOT_REQUIRED]"));
    expect(migration, contains("'[VERIFIED_PRODUCT_SNAPSHOT_IMMUTABLE]"));
  });

  test('QR locking, freshness, single-use, and immutable totals remain', () {
    final creation = _section(
      migration,
      'CREATE OR REPLACE FUNCTION public.create_qr_session',
      'REVOKE ALL ON FUNCTION public.create_qr_session',
    );
    final confirmation = _section(
      migration,
      'CREATE OR REPLACE FUNCTION public.confirm_qr_session',
      'REVOKE ALL ON FUNCTION public.confirm_qr_session',
    );

    expect(creation, contains('FOR SHARE OF listing, product;'));
    expect(creation, contains('v_current_time := clock_timestamp();'));
    expect(creation, contains('snapshot_product_count = snapshot_line_count'));
    expect(confirmation, contains('FOR UPDATE;'));
    expect(confirmation, contains('v_current_time := clock_timestamp();'));
    expect(confirmation, contains("locked_session.status = 'used'"));
    expect(confirmation, contains("SET status = 'checked_out'"));
    expect(confirmation, contains("'[QR_PRODUCT_SNAPSHOT_MISSING]"));
  });

  test('review mutations require server evidence and are RPC-only', () {
    expect(migration, contains('ADD COLUMN verified_transaction_item_id UUID'));
    expect(
      migration,
      contains(
        'REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT',
      ),
    );
    expect(
      migration,
      contains('DROP POLICY IF EXISTS reviews_insert_own ON public.reviews;'),
    );
    expect(
      migration,
      contains(
        'REVOKE INSERT, UPDATE, DELETE ON TABLE public.reviews '
        'FROM authenticated;',
      ),
    );
    expect(
      migration,
      contains('verified_transaction.customer_user_id = NEW.user_id'),
    );
    expect(migration, contains('verified_item.product_id = NEW.product_id'));
    expect(migration, contains("'[REVIEW_EVIDENCE_IMMUTABLE]"));
    expect(migration, contains("'[REVIEW_NOT_VERIFIED]"));
    expect(
      migration,
      isNot(contains('DROP CONSTRAINT reviews_user_product_key')),
    );
  });

  test(
    'frozen RPC surface has explicit privilege and idempotency semantics',
    () {
      const signatures = <String>[
        'get_product_reviews(UUID, INTEGER, INTEGER)',
        'get_product_review_eligibility(UUID)',
        'submit_product_review(UUID, INTEGER, TEXT, TEXT)',
        'update_product_review(UUID, INTEGER, TEXT, TEXT)',
        'delete_product_review(UUID)',
      ];

      for (final signature in signatures) {
        expect(migration, contains('REVOKE ALL ON FUNCTION public.$signature'));
        expect(contract, contains('`${signature.split('(').first}`'));
      }

      expect(migration, contains('WHEN unique_violation THEN'));
      expect(migration, contains("'created', was_created"));
      expect(migration, contains("'deleted', deleted_review_id IS NOT NULL"));
      expect(
        migration,
        contains(
          'ORDER BY verified_transaction.confirmed_at, verified_item.id',
        ),
      );
      expect(contract, contains('returned unchanged with `created: false`'));
      expect(contract, contains('After deletion'));
    },
  );

  test('legacy reviews stay visible but never enter verified aggregates', () {
    expect(
      migration,
      contains(
        'SET is_verified_purchase = false\n'
        'WHERE verified_transaction_item_id IS NULL',
      ),
    );
    expect(
      _occurrences(
        migration,
        'review.verified_transaction_item_id IS NOT NULL',
      ),
      greaterThanOrEqualTo(3),
    );
    expect(
      migration,
      contains(
        "'is_verified_purchase',\n"
        '                            page.verified_transaction_item_id '
        'IS NOT NULL',
      ),
    );
    expect(contract, contains('Preserved legacy reviews remain'));
  });

  test(
    'only active buckets are public and client Storage policies stay absent',
    () {
      const expectedBuckets = <String>{
        'product-images',
        'category-images',
        'banner-images',
      };
      final bucketValues = RegExp(
        r"\(\n\s+'([a-z-]+)',\n\s+'\1',\n\s+true,",
      ).allMatches(migration).map((match) => match.group(1)!).toSet();

      expect(bucketValues, expectedBuckets);
      for (final deferred in ['brand-logos', 'avatars', 'review-images']) {
        expect(migration, isNot(contains("'$deferred'")));
      }
      expect(migration, contains('8388608'));
      expect(migration, contains('2097152'));
      expect(migration, contains('5242880'));
      expect(
        _occurrences(
          migration,
          "ARRAY['image/jpeg', 'image/png', 'image/webp']::TEXT[]",
        ),
        3,
      );
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
    },
  );

  test(
    'trusted media paths match the client and retention stays operational',
    () {
      expect(_occurrences(migration, "'^catalog/'"), 3);
      expect(_occurrences(migration, "'^shops/'"), 1);
      expect(migration, contains("'v[0-9]{14}/"));
      expect(migration, contains("'[STORAGE_INVALID_PATH]"));
      expect(migration, isNot(contains('BEFORE DELETE ON storage.objects')));
      expect(contract, contains('new versioned object'));
      expect(contract, contains('trusted operations workflow contract'));
      expect(contract, contains('installs no cron'));
    },
  );
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
