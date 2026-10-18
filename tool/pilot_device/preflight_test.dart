import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/runtime/merchant_pilot_config.dart';
import 'preflight.dart';

void main() {
  final merchant = <String, String>{
    'MERCHANT_PILOT_ENABLED': 'true',
    'MERCHANT_PILOT_URL': 'https://tnipyxnvhgelwdpykyez.supabase.co',
    'MERCHANT_PILOT_ANON_KEY': 'sb_publishable_syntheticPilotOnly12345',
    for (final flag in MerchantPilotConfig.forbiddenCapabilities) flag: 'false',
  };
  final customer = <String, String>{
    'SUPABASE_DEVELOPMENT_URL': merchant['MERCHANT_PILOT_URL']!,
    'SUPABASE_DEVELOPMENT_ANON_KEY': merchant['MERCHANT_PILOT_ANON_KEY']!,
    'ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY': 'false',
    for (final flag in MerchantPilotConfig.forbiddenCapabilities) flag: 'false',
  };
  test(
    'actual client contracts accept matching, disabled paired configuration',
    () {
      expect(() => validatePair(customer, merchant), returnsNormally);
    },
  );
  for (final key in customer.keys) {
    test('missing or mismatched Customer $key cannot enter pair', () {
      expect(
        () => validatePair({...customer}..remove(key), merchant),
        throwsA(anything),
      );
      expect(
        () => validatePair({...customer, key: 'changed'}, merchant),
        throwsA(anything),
      );
    });
  }
  test('different safe client key is still a pair mismatch', () {
    expect(
      () => validatePair({
        ...customer,
        'SUPABASE_DEVELOPMENT_ANON_KEY': 'sb_publishable_otherPilotClient12345',
      }, merchant),
      throwsA(anything),
    );
  });
  test('extra Customer capability or production field rejected', () {
    expect(
      () => validatePair({
        ...customer,
        'SUPABASE_PRODUCTION_URL': 'forbidden',
      }, merchant),
      throwsA(anything),
    );
    expect(
      () => validatePair({...customer, 'UNKNOWN_FEATURE': 'true'}, merchant),
      throwsA(anything),
    );
  });
}
