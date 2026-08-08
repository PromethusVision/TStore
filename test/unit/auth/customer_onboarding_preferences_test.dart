import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/auth/data/services/customer_onboarding_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ilk kullanimda onboarding tamamlanmamis kabul edilir', () async {
    expect(await CustomerOnboardingPreferences.isCompleted(), isFalse);
  });

  test('tamamlanan onboarding sonraki acilista hatirlanir', () async {
    await CustomerOnboardingPreferences.markCompleted();

    expect(await CustomerOnboardingPreferences.isCompleted(), isTrue);
  });
}
