import 'dart:convert';
import 'dart:io';
import 'package:t_store/features/merchant/runtime/merchant_pilot_config.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

/// Reads a client-only manifest locally. Never initializes a network client.
void main(List<String> args) {
  try {
    if (args.length != 6 ||
        args[0] != '--config' ||
        args[2] != '--target' ||
        args[4] != '--flavor' ||
        args[3] != MerchantPilotConfig.target ||
        args[5] != MerchantPilotConfig.flavor) {
      throw const FormatException(
        'Use the documented pilot config, target and flavor.',
      );
    }
    final raw = jsonDecode(File(args[1]).readAsStringSync());
    if (raw is! Map<String, dynamic> || raw.values.any((v) => v is! String)) {
      throw const FormatException(
        'Configuration must contain string fields only.',
      );
    }
    MerchantPilotConfig.fromValues(raw.cast<String, String>());
    stdout.writeln(
      jsonEncode({
        'status': 'PASS',
        'mode': 'offline_configuration_only',
        'application_id': MerchantPilotConfig.applicationId,
        'flavor': MerchantPilotConfig.flavor,
        'target': MerchantPilotConfig.target,
        'production_access': 'NONE',
        'remote_authorization': false,
        'provider_configured': false,
        'physical_acceptance': 'OPEN',
        'signing_proof': 'NOT_RUN',
        'distribution_ready': false,
      }),
    );
  } on SupabaseConfigurationException catch (error) {
    stderr.writeln('FAIL: ${error.message}');
    exitCode = 2;
  } catch (_) {
    stderr.writeln(
      'FAIL: Pilot configuration or invocation is invalid. No connection attempted.',
    );
    exitCode = 2;
  }
}
