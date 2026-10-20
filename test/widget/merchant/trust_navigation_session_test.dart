import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_views.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';

class NavigationTrust extends PreviewTrustCommerceRepository
    implements AuthenticatedSessionEvents {
  NavigationTrust(this.actors)
    : super(user: () => previewTrustActor, sessionChanges: actors.stream);
  final StreamController<String?> actors;
  final keys = StreamController<String?>.broadcast();
  String? session = 'S1';
  int reads = 0;
  @override
  String? get currentSessionKey => session;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  @override
  Future<Either<TrustFailure, TrustSnapshot>> trust({
    String? shopId,
    int? before,
  }) async {
    reads++;
    return const Right(
      TrustSnapshot(
        enabled: true,
        badges: [
          TrustBadge(
            code: 'one',
            family: 'one',
            level: 1,
            title: 'Birinci rozet',
            explanation: 'Private explanation one',
            eligible: true,
          ),
          TrustBadge(
            code: 'two',
            family: 'two',
            level: 1,
            title: 'İkinci rozet',
            explanation: 'Private explanation two',
            eligible: true,
          ),
          TrustBadge(
            code: 'three',
            family: 'three',
            level: 1,
            title: 'Üçüncü rozet',
            explanation: 'Private explanation three',
            eligible: true,
          ),
        ],
      ),
    );
  }
}

void main() {
  for (final merchant in [true, false]) {
    for (final entry in ['summary', 'detail', 'all badges', 'history']) {
      for (final transition in [
        'renewal',
        'replacement',
        'round trip',
        'logout',
        'account round trip',
        'observer error',
        'observer closed',
        'silent replacement',
      ]) {
        testWidgets(
          '${merchant ? 'merchant' : 'customer'} $entry binds $transition before first mount',
          (tester) async {
            tester.view.physicalSize = const Size(320, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final actors = StreamController<String?>.broadcast();
            final repo = NavigationTrust(actors);
            try {
              final shop = merchant ? previewTrustShop : null;
              await tester.pumpWidget(
                MaterialApp(
                  home: entry == 'detail'
                      ? TrustDetailView(
                          repository: repo,
                          actor: previewTrustActor,
                          shopId: shop,
                        )
                      : Scaffold(
                          body: TrustSummary(
                            repository: repo,
                            actor: previewTrustActor,
                            shopId: shop,
                          ),
                        ),
                ),
              );
              await tester.pumpAndSettle();
              expect(repo.reads, 1);
              await tester.tap(switch (entry) {
                'summary' => find.byType(ActionChip).first,
                'detail' => find.byTooltip('Birinci rozet koşulları'),
                'all badges' => find.text('+1'),
                _ => find.text('İlerleme ve geçmiş'),
              });
              // No pump here: invalidate after navigation dispatch but before
              // the dialog/detail route can bind its own session guard.
              switch (transition) {
                case 'renewal':
                  repo.keys.add('S1');
                  actors.add(previewTrustActor);
                case 'replacement':
                  repo.session = 'S2';
                  repo.keys.add('S2');
                case 'round trip':
                  repo.keys.add('S2');
                  repo.keys.add('S1');
                case 'logout':
                  repo.session = null;
                  actors.add(null);
                case 'account round trip':
                  actors.add('another-synthetic-actor');
                  actors.add(previewTrustActor);
                case 'observer error':
                  repo.keys.addError(StateError('observation failed'));
                case 'observer closed':
                  unawaited(repo.keys.close());
                case 'silent replacement':
                  repo.session = 'S2';
              }
              await tester.pumpAndSettle();
              if (transition == 'renewal') {
                if (entry == 'history') {
                  expect(repo.reads, 2);
                  expect(find.byType(TrustDetailView), findsOneWidget);
                  expect(find.text('Kazanıldı'), findsNWidgets(3));
                } else {
                  expect(
                    find.textContaining('Private explanation'),
                    findsWidgets,
                  );
                }
              } else {
                expect(
                  find.textContaining('Private explanation'),
                  findsNothing,
                );
                final expired = entry == 'history'
                    ? find.text('Oturum değişti')
                    : find.widgetWithText(AlertDialog, 'Oturum değişti');
                expect(expired, findsOneWidget);
                expect(
                  repo.reads,
                  1,
                  reason:
                      'An old navigation must not read in the replacement session.',
                );
                if (!repo.keys.isClosed) repo.keys.add('S1');
                repo.session = 'S1';
                actors.add(previewTrustActor);
                await tester.pumpAndSettle();
                expect(
                  find.textContaining('Private explanation'),
                  findsNothing,
                );
                expect(expired, findsOneWidget);
                expect(repo.reads, 1);
              }
              expect(tester.takeException(), isNull);
            } finally {
              await tester.pumpWidget(const SizedBox());
              expect(actors.hasListener, false);
              expect(repo.keys.hasListener, false);
              await actors.close();
              if (!repo.keys.isClosed) await repo.keys.close();
            }
          },
        );
      }
    }
  }
}
