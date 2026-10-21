import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import 'package:t_store/features/merchant_promotions/presentation/merchant_promotion_center.dart';
import '../../unit/merchant_promotions/promotion_repository_test.dart' as wire;

void main() {
  for (final pending in [true, false]) {
    for (final width in [320.0, 430.0]) {
      testWidgets(
        'reopen recovers original command at $width, transport pending=$pending',
        (t) async {
          late SupabaseClient client;
          late SupabaseMerchantPromotionRepository repo;
          late StreamController<String?> actors, keys;
          late Completer<dynamic> write;
          final writes = <Map<String, dynamic>>[];
          var success = false, reads = 0;
          await t.runAsync(() async {
            actors = StreamController<String?>.broadcast();
            keys = StreamController<String?>.broadcast();
            write = Completer<dynamic>();
            client = SupabaseClient(
              'http://127.0.0.1:55431',
              'synthetic-only',
              authOptions: const AuthClientOptions(autoRefreshToken: false),
            );
            repo = SupabaseMerchantPromotionRepository(
              client,
              currentUserId: () => 'owner',
              currentSessionKey: () => 'S1',
              sessionChanges: actors.stream,
              sessionKeyChanges: keys.stream,
              rpc: (name, args) async {
                if (name == 'read_merchant_promotions_v1') {
                  reads++;
                  return wire.page();
                }
                if (name == 'preview_merchant_promotion_v1') {
                  return wire.preview();
                }
                writes.add(args);
                if (success) {
                  return {
                    'id': wire.draft,
                    'revision_id': wire.revision,
                    'action': 'save',
                  };
                }
                if (pending) return write.future;
                throw StateError('response lost');
              },
            );
          });
          Future<void> settle() async {
            for (var i = 0; i < 3; i++) {
              await t.pump();
              await t.runAsync(() => pumpEventQueue());
            }
            await t.pumpAndSettle();
          }

          t.view.physicalSize = Size(width, 1100);
          t.view.devicePixelRatio = 1;
          t.platformDispatcher.textScaleFactorTestValue = 1.3;
          addTearDown(() async {
            await t.pumpWidget(const SizedBox());
            await t.runAsync(() async {
              await actors.close();
              await keys.close();
              await client.dispose();
            });
            t.view.resetPhysicalSize();
            t.view.resetDevicePixelRatio();
            t.platformDispatcher.clearTextScaleFactorTestValue();
          });
          Widget screen(int id) => MaterialApp(
            key: ValueKey(id),
            home: MerchantPromotionCenter(
              repository: repo,
              shopId: wire.shop,
              ownerId: 'owner',
            ),
          );
          Future<void> tap(String label, {bool waiting = false}) async {
            final all = find.text(label);
            await t.scrollUntilVisible(all, 250);
            final f = all.last;
            await t.ensureVisible(f);
            await t.tap(f);
            if (!waiting) {
              await settle();
            } else {
              await t.pump();
              await t.runAsync(() => pumpEventQueue());
              await t.pump();
            }
          }

          await t.pumpWidget(screen(1));
          await settle();
          await tap('Yeni tanıtım taslağı');
          await tap('Önizlemeyi yenile');
          await tap('Taslağı kaydet', waiting: pending);
          expect(writes.length, 1);
          final original = repo.pendingCommand(wire.shop)!;
          await t.pumpWidget(screen(2));
          await settle();
          expect(reads, 1);
          expect(writes.length, 1);
          expect(find.text('Aynı işlemi kontrol et'), findsOneWidget);
          expect(find.text('Yeni tanıtım taslağı'), findsNothing);
          expect(repo.pendingCommand(wire.shop), same(original));
          success = true;
          await tap('Aynı işlemi kontrol et', waiting: pending);
          if (pending) {
            expect(writes.length, 1);
            await t.runAsync(() async {
              write.complete({
                'id': wire.draft,
                'revision_id': wire.revision,
                'action': 'save',
              });
              await pumpEventQueue();
            });
            await settle();
          } else {
            expect(writes.length, 2);
            expect(writes.first, writes.last);
          }
          expect(repo.pendingCommand(wire.shop), isNull);
          expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
