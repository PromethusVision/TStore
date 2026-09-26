import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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

  testWidgets('W53A actual app stays light across OS brightness changes', (
    tester,
  ) async {
    final dispatcher = tester.binding.platformDispatcher;
    addTearDown(dispatcher.clearPlatformBrightnessTestValue);
    for (final brightness in [
      Brightness.dark,
      Brightness.light,
      Brightness.dark,
    ]) {
      dispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpWidget(const TStore());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
      expect(app.darkTheme, isNull);
      final context = tester.element(find.byType(Navigator).first);
      final theme = Theme.of(context);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.onSurface, EsnaftaVarColors.textPrimary);
      expect(theme.scaffoldBackgroundColor, EsnaftaVarColors.background);
      expect(MediaQuery.platformBrightnessOf(context), brightness);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('TStore app loads successfully', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TStore());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that the app renders without errors.
    expect(find.byType(TStore), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
