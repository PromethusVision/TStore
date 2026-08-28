import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('release logging contract', () {
    test('shared Logger instances are disabled in release mode', () {
      for (final path in const [
        'lib/core/utils/helpers/logger_helper.dart',
        'lib/core/utils/logging/logger.dart',
        'lib/core/network/interceptors.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          source,
          contains('kReleaseMode ? Level.off : Level.debug'),
          reason: '$path must fail closed for release logging.',
        );
      }
    });

    test('HTTP diagnostics never log URLs, headers, bodies, or messages', () {
      final source = File(
        'lib/core/network/interceptors.dart',
      ).readAsStringSync();

      for (final forbidden in const [
        'options.baseUrl',
        'options.path',
        'response.headers',
        'response.data',
        'err.message',
        'err.error',
      ]) {
        expect(source, isNot(contains(forbidden)));
      }
    });

    test('diagnostics do not interpolate precise location or Auth errors', () {
      final locationSource = File(
        'lib/core/utils/helpers/location_helper.dart',
      ).readAsStringSync();
      expect(locationSource, isNot(contains(r'${position.latitude}')));
      expect(locationSource, isNot(contains(r'${position.longitude}')));
      expect(locationSource, isNot(contains(r'Adres bulundu: $address')));

      for (final path in const [
        'lib/features/auth/presentation/widgets/customer_session_listener.dart',
        'lib/features/auth/presentation/widgets/password_recovery_listener.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains(r': $error')));
      }
    });
  });
}
