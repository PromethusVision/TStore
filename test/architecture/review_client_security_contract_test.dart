import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('review client mutations use only frozen RPCs', () {
    final source = File(
      'lib/features/reviews/data/repositories/review_repository_impl.dart',
    ).readAsStringSync();

    expect(source, contains("submitReviewRpc = 'submit_product_review'"));
    expect(source, contains("updateReviewRpc = 'update_product_review'"));
    expect(source, contains("deleteReviewRpc = 'delete_product_review'"));
    expect(source, contains("getReviewsRpc = 'get_product_reviews'"));
    expect(
      source,
      contains("getEligibilityRpc = 'get_product_review_eligibility'"),
    );
    expect(source, isNot(contains('.from(SupabaseTables.reviews)')));
    expect(source, isNot(contains("'is_verified_purchase':")));
    expect(source, isNot(contains("'user_id':")));
    expect(source, isNot(contains('service_role')));
    expect(source, isNot(contains('tnipyxnvhgelwdpykyez')));
  });

  test('review form does not implement deferred review images', () {
    final source = File(
      'lib/features/shop/presentation/views/product_reviews_view.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('ImagePicker')));
    expect(source, isNot(contains('review-images')));
    expect(source, isNot(contains('isVerifiedPurchase:')));
  });
}
