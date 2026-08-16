import 'dart:convert';
import 'dart:io';

import 'package:t_store/core/supabase/production_release_preflight.dart';

void main(List<String> arguments) {
  try {
    if (arguments.length != 3) {
      throw const _UsageException();
    }
    final modeValue = _requiredOption(arguments, 'mode');
    final configPath = _requiredOption(arguments, 'config');
    final target = _requiredOption(arguments, 'target');
    final mode = switch (modeValue) {
      'release' => ProductionReleasePreflightMode.release,
      'contract' => ProductionReleasePreflightMode.compileContract,
      _ => throw const _UsageException(),
    };

    final values = _readManifest(configPath);
    ProductionReleasePreflight.validate(
      mode: mode,
      values: values,
      target: target,
    );

    if (mode == ProductionReleasePreflightMode.compileContract) {
      stdout.writeln(
        'Production config preflight: PASS (COMPILE_CONTRACT_ONLY)',
      );
      stdout.writeln('Deployment authorization: NO');
    } else {
      stdout.writeln('Production config preflight: PASS (STRUCTURAL_RELEASE)');
      stdout.writeln('Remote project/Auth verification: REQUIRED');
    }
    stdout.writeln(
      'Entrypoint contract: ${ProductionReleasePreflight.productionEntrypoint}',
    );
    stdout.writeln('Configuration values were not logged.');
  } on _UsageException {
    stderr.writeln('Production config preflight: FAIL');
    stderr.writeln(
      'Usage: dart run tool/production_release_preflight.dart '
      '--mode=<release|contract> --config=<json-path> '
      '--target=lib/main_production.dart',
    );
    exitCode = 64;
  } on FileSystemException {
    stderr.writeln('Production config preflight: FAIL');
    stderr.writeln('The manifest file could not be read.');
    exitCode = 66;
  } on FormatException {
    stderr.writeln('Production config preflight: FAIL');
    stderr.writeln('The manifest must be valid JSON with string values.');
    exitCode = 65;
  } on ProductionReleasePreflightException catch (error) {
    stderr.writeln('Production config preflight: FAIL');
    stderr.writeln(error);
    exitCode = 1;
  } catch (_) {
    stderr.writeln('Production config preflight: FAIL');
    stderr.writeln('Validation could not be completed safely.');
    exitCode = 1;
  }
}

Map<String, String> _readManifest(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException();
  }

  final values = <String, String>{};
  for (final entry in decoded.entries) {
    if (entry.value is! String) {
      throw const FormatException();
    }
    values[entry.key] = entry.value as String;
  }
  return values;
}

String _requiredOption(List<String> arguments, String name) {
  final prefix = '--$name=';
  final matches = arguments.where((argument) => argument.startsWith(prefix));
  if (matches.length != 1) {
    throw const _UsageException();
  }
  final value = matches.single.substring(prefix.length).trim();
  if (value.isEmpty) {
    throw const _UsageException();
  }
  return value;
}

final class _UsageException implements Exception {
  const _UsageException();
}
