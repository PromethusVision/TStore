import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/t_store.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final config = SupabaseConfig.forEnvironment(
      environment: AppEnvironment.development,
      supabaseUrl: 'https://widget-test.supabase.co',
      supabaseAnonKey: 'sb_publishable_widget_test_public_key',
    );
    await SupabaseService.initialize(config: config);
    await setupServiceLocator();
  });

  tearDownAll(() async {
    await sl.reset();
  });

  testWidgets('TStore app loads successfully', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TStore());

    // Verify that the app renders without errors.
    expect(find.byType(TStore), findsOneWidget);
  });
}
