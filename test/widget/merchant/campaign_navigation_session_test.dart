import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_campaigns.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';
import 'merchant_trust_campaigns_test.dart' as fixture;

class NavigationCampaigns extends fixture.ControlledTrust
    implements AuthenticatedSessionEvents {
  NavigationCampaigns(super.host);
  final keys = StreamController<String?>.broadcast();
  String? session = 'S1';
  int reads = 0;
  @override
  String? get currentSessionKey => session;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  @override
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  }) {
    reads++;
    return super.campaigns(shopId, offset: offset);
  }
}

class OnPush extends NavigatorObserver {
  VoidCallback? next;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final action = next;
    next = null;
    action?.call();
  }
}

void main() {
  for (final entry in [
    'list',
    'editor',
    'products',
    'preview',
    'publish',
    'photo',
  ]) {
    for (final transition in ['renewal', 'replacement', 'round trip']) {
      testWidgets(
        'campaign $entry retains origin across $transition before mount',
        (tester) async {
          final host = MerchantPreview();
          final repo = NavigationCampaigns(host);
          final access = MerchantAccess(
            user: host.user,
            shop: host.repository.shop,
          );
          final media = fixture.CampaignMediaMock();
          final first = host.repository.items.first;
          when(() => media.media(access, first.id)).thenAnswer(
            (_) async => const Right(
              ListingMedia(
                [
                  ListingImage(
                    id: previewCampaignId,
                    path: 'synthetic/photo.png',
                    state: 'published',
                    primary: true,
                    order: 0,
                  ),
                ],
                maxPhotos: 5,
                maxBytes: 1000,
              ),
            ),
          );
          final old = repo.rows.first;
          final campaign = Campaign(
            id: old.id,
            shopId: old.shopId,
            revisionId: old.revisionId,
            status: 'draft',
            draft: CampaignDraft(
              title: 'Private campaign draft',
              description: '',
              type: CampaignType.announcement,
              scope: CampaignScope.single,
              startsAt: old.draft.startsAt,
              endsAt: old.draft.endsAt,
              listingIds: [first.id],
            ),
            products: [CampaignProduct(first.id, first.product!.name)],
          );
          repo.rows
            ..clear()
            ..add(campaign);
          final services = fixture.services(host, repo, media: media);
          final observer = OnPush();
          try {
            await tester.pumpWidget(
              MaterialApp(
                navigatorObservers: [observer],
                home: switch (entry) {
                  'list' => Scaffold(
                    body: MerchantCampaignSummary(
                      services: services,
                      access: access,
                    ),
                  ),
                  'editor' || 'publish' => MerchantCampaignsView(
                    services: services,
                    access: access,
                  ),
                  _ => MerchantCampaignEditor(
                    services: services,
                    access: access,
                    existing: campaign,
                  ),
                },
              ),
            );
            await tester.pumpAndSettle();
            var label = switch (entry) {
              'list' => 'Kampanyaları yönet',
              'editor' => 'Düzenle',
              'products' => 'Ürün seç (1)',
              'preview' => 'Müşteri görünümünü önizle',
              'publish' => 'Yayınla',
              _ => 'Ürün fotoğraflarından seç',
            };
            if (entry == 'photo') {
              await tester.ensureVisible(find.text(label));
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
              await tester.tap(find.text(first.product!.name));
              await tester.pumpAndSettle();
              label = 'Seçimi kullan (1)';
            }
            if (find.text(label).evaluate().isEmpty) {
              await tester.scrollUntilVisible(
                find.text(label),
                200,
                scrollable: find.byType(Scrollable).first,
              );
            }
            await tester.ensureVisible(find.text(label));
            observer.next = () {
              if (transition == 'replacement') repo.session = 'S2';
              if (transition != 'renewal') repo.keys.add('S2');
              if (transition != 'replacement') repo.keys.add('S1');
            };
            final reads = repo.reads;
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(
              observer.next,
              isNull,
              reason: 'The private destination was actually pushed.',
            );
            if (transition == 'renewal') {
              expect(find.text('Oturum değişti'), findsNothing);
              expect(switch (entry) {
                'list' => find.text('Kampanya oluştur'),
                'editor' => find.widgetWithText(TextField, 'Kampanya başlığı'),
                'products' => find.text('Seçimi kullan (1)'),
                'preview' => find.text('Önizleme · Henüz yayınlanmadı'),
                'publish' => find.text('Kampanyayı yayınla'),
                _ => find.text('Mevcut fotoğrafı seç'),
              }, findsOneWidget);
            } else {
              expect(find.text('Oturum değişti'), findsWidgets);
              expect(find.text('Private campaign draft'), findsNothing);
              expect(find.text('Önizleme · Henüz yayınlanmadı'), findsNothing);
              expect(find.text('Kampanyayı yayınla'), findsNothing);
              expect(find.text('Mevcut fotoğrafı seç'), findsNothing);
              expect(find.byType(CheckboxListTile), findsNothing);
              expect(repo.reads, reads);
            }
            expect(repo.requests, isEmpty);
            expect(tester.takeException(), isNull);
          } finally {
            await tester.pumpWidget(const SizedBox());
            expect(repo.keys.hasListener, false);
            await repo.keys.close();
            await host.dispose();
          }
        },
      );
    }
  }
}
