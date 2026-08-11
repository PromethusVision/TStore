import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/t_store.dart';

const appEnvironment = AppEnvironment.development;
const supabaseUrlDartDefine = SupabaseConfig.developmentUrlDartDefine;
const supabaseAnonKeyDartDefine = SupabaseConfig.developmentAnonKeyDartDefine;

SupabaseConfig createSupabaseConfig({
  String supabaseUrl = const String.fromEnvironment(supabaseUrlDartDefine),
  String supabaseAnonKey = const String.fromEnvironment(
    supabaseAnonKeyDartDefine,
  ),
}) {
  return SupabaseConfig.forEnvironment(
    environment: appEnvironment,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = createSupabaseConfig();
  await SupabaseService.initialize(config: supabaseConfig);
  await setupServiceLocator();

  runApp(const TStore());
}
