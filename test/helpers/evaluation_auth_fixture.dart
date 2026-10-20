import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fake_evaluation_repository.dart';

/// Synthetic SDK session, never sent to a hosted service.
Future<void> installEvaluationSession(
  SupabaseClient client,
  String sessionId, {
  String actor = evaluationActor,
  int tokenRevision = 0,
}) async {
  String segment(Object v) =>
      base64Url.encode(utf8.encode(jsonEncode(v))).replaceAll('=', '');
  await client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.'
          '${segment({'sub': actor, 'session_id': sessionId, 'nonce': tokenRevision, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
      'token_type': 'bearer',
      'refresh_token': 'synthetic-$sessionId',
      'user': {
        'id': actor,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
}
