import 'package:shared_preferences/shared_preferences.dart';

abstract final class CustomerOnboardingPreferences {
  static const completedKey = 'customer_onboarding_completed_v1';

  static Future<bool> isCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final preferences = await SharedPreferences.getInstance();
    final didSave = await preferences.setBool(completedKey, true);
    if (!didSave) {
      throw StateError('Onboarding completion could not be saved.');
    }
  }
}
