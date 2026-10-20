import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Local stale-response fence only. The server verifies JWT/session authority.
/// Token refresh in the same Auth session does not change this key.
String? authenticatedSessionKey(SupabaseClient client) {
  return authenticatedSessionKeyFromSession(client.auth.currentSession);
}

/// Keeps a queued Auth event's identity even if the live session has changed.
String? authenticatedSessionKeyFromSession(Session? session) {
  try {
    if (session == null) return null;
    final payload =
        jsonDecode(
              utf8.decode(
                base64Url.decode(
                  base64Url.normalize(session.accessToken.split('.')[1]),
                ),
              ),
            )
            as Map;
    final id = payload['session_id'];
    if (id is! String || id.isEmpty) return null;
    return '${session.user.id}:$id';
  } catch (_) {
    return null;
  }
}
