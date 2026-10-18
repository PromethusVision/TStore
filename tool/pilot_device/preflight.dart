import 'dart:convert';
import 'dart:io';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/merchant/runtime/merchant_pilot_config.dart';

/// Offline cross-check using the application's actual validation contracts.
void validatePair(Map<String, String> customer, Map<String, String> merchant) {
  final pilot = MerchantPilotConfig.fromValues(merchant);
  final expected = <String, String>{
    SupabaseConfig.developmentUrlDartDefine: pilot.backend.supabaseUrl,
    SupabaseConfig.developmentAnonKeyDartDefine: pilot.backend.supabaseAnonKey,
    'ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY': 'false',
    for (final flag in MerchantPilotConfig.forbiddenCapabilities) flag: 'false',
  };
  if (customer.length != expected.length ||
      expected.entries.any((e) => customer[e.key] != e.value)) {
    throw const FormatException('Pair configuration mismatch.');
  }
  SupabaseConfig.fromEnvironmentValues(AppEnvironment.development, customer);
}

void main(List<String> args) {
  try {
    if (args.length != 2) throw const FormatException();
    Map<String, String> read(String path) =>
        (jsonDecode(File(path).readAsStringSync()) as Map)
            .cast<String, String>();
    validatePair(read(args[0]), read(args[1]));
    stdout.writeln('PAIR_CONFIGURATION_PASS_OFFLINE_ONLY');
  } catch (_) {
    stderr.writeln('PAIR_CONFIGURATION_REFUSED; no connection attempted.');
    exitCode = 2;
  }
}
