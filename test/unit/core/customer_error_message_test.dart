import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';

void main() {
  group('CustomerErrorMessage', () {
    test('connection details are replaced with a safe Turkish message', () {
      final message = CustomerErrorMessage.from(
        Exception('ClientException: Failed to fetch private-host'),
      );

      expect(message, CustomerErrorMessage.connection);
      expect(message, isNot(contains('private-host')));
    });

    test('expired sessions ask the customer to sign in again', () {
      expect(
        CustomerErrorMessage.from(Exception('JWT expired')),
        CustomerErrorMessage.sessionExpired,
      );
    });

    test('permission errors never expose backend details', () {
      final message = CustomerErrorMessage.from(
        Exception('PostgrestException 42501: secret policy name'),
      );

      expect(message, CustomerErrorMessage.permissionDenied);
      expect(message, isNot(contains('secret policy name')));
    });

    test('duplicate records receive a clear message', () {
      expect(
        CustomerErrorMessage.from(Exception('duplicate key 23505')),
        CustomerErrorMessage.alreadyExists,
      );
    });

    test('unexpected details are replaced with the requested fallback', () {
      const fallback = 'Favorileriniz yüklenemedi. Lütfen tekrar deneyin.';
      final message = CustomerErrorMessage.from(
        StateError('database-password-was-visible'),
        fallback: fallback,
      );

      expect(message, fallback);
      expect(message, isNot(contains('database-password-was-visible')));
    });

    test('service failures hide the remote response body', () {
      final message = CustomerErrorMessage.from(
        Exception('statusCode: 503 upstream-body-was-visible'),
      );

      expect(message, CustomerErrorMessage.serviceUnavailable);
      expect(message, isNot(contains('upstream-body-was-visible')));
    });

    test('not-found failures hide backend identifiers', () {
      final message = CustomerErrorMessage.from(
        Exception('statusCode: 404 internal-row-id-was-visible'),
      );

      expect(message, CustomerErrorMessage.notFound);
      expect(message, isNot(contains('internal-row-id-was-visible')));
    });
  });
}
