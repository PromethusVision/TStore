import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/shop_profile_photo.dart';

class ProfileRepo extends PreviewMerchantRepository
    implements MerchantShopPhotoRepository {
  ProfileRepo(super.host) : super(hasShop: true, empty: true);
  int staged = 0;
  bool failUpload = false, loseReply = false;
  MerchantShopDraft? last;
  Uint8List? bytes;
  @override
  Future<Either<String, String>> stageShopPhoto(
    MerchantAccess access,
    Uint8List data,
  ) async {
    staged++;
    bytes = data;
    return failUpload
        ? const Left('Bağlantı yok.')
        : const Right('shops/local/new.png');
  }

  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  ) async {
    last = draft;
    final result = await super.saveShop(access, draft);
    return loseReply ? const Left('Yanıt alınamadı.') : result;
  }
}

Position position({double accuracy = 8, DateTime? timestamp}) => Position(
  longitude: 29,
  latitude: 41,
  timestamp: timestamp ?? DateTime.now(),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 1,
);
final pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
);

Future<Uint8List> realPhoto() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 4, 4),
    ui.Paint()..color = const Color(0xff113344),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(4, 4);
  try {
    return (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}

void main() {
  late MerchantPreview preview;
  late ProfileRepo repo;
  late MerchantSessionCubit host;
  late String key;
  int saved = 0;
  setUp(() async {
    preview = MerchantPreview();
    repo = ProfileRepo(preview);
    key = 'one';
    saved = 0;
    host = MerchantSessionCubit(
      repository: repo,
      credentials: preview.services.credentials,
      sessionChanges: preview.changes.stream,
      currentUserId: () => preview.currentId,
      currentSessionKey: () => key,
    );
    await host.reload();
  });
  tearDown(() async {
    await host.close();
    await preview.dispose();
  });
  Future<void> pump(
    WidgetTester t, {
    Future<Position> Function()? load,
    Future<XFile?> Function()? pick,
    Future<bool> Function(Uri)? map,
    double width = 390,
    double scale = 1,
  }) async {
    t.view.physicalSize = Size(width, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider.value(
          value: host,
          child: MerchantShopForm(
            repository: repo,
            access: MerchantAccess(user: preview.user, shop: repo.shop),
            onSaved: () => saved++,
            loadPosition: load,
            pickImage: pick,
            openMap: map,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text).last);
    await t.pumpAndSettle();
    await t.ensureVisible(find.text(text).last);
    await t.pumpAndSettle();
    await t.tap(find.text(text).last);
    await t.pumpAndSettle();
  }

  Future<void> pickDay(WidgetTester t, String day, String choice) async {
    await t.ensureVisible(find.byKey(ValueKey('hours-$day')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(ValueKey('hours-$day')));
    await t.pumpAndSettle();
    await tap(t, choice);
  }

  testWidgets(
    'daily closed and unspecified preserve unknown legacy data and weekend',
    (t) async {
      repo.shop = repo.shop!.copyWith(
        openingHours: {
          'mon_sat': '09:00–18:00',
          'sun': 'Kapalı',
          'note': 'Yaz',
        },
      );
      await pump(t);
      await pickDay(t, 'mon', 'Kapalı');
      await tap(t, 'Pazartesi saatlerini hafta içine uygula');
      await pickDay(t, 'tue', 'Belirtilmedi');
      await tap(t, 'Mağazayı kaydet');
      expect(repo.last!.openingHours, containsPair('mon', 'closed'));
      expect(repo.last!.openingHours, containsPair('fri', 'closed'));
      expect(repo.last!.openingHours, containsPair('tue', ''));
      expect(repo.last!.openingHours, containsPair('sun', 'Kapalı'));
      expect(repo.last!.openingHours, containsPair('note', 'Yaz'));
    },
  );
  testWidgets(
    'time picker requires both choices and preserves value after cancel',
    (t) async {
      await pump(t);
      await pickDay(t, 'mon', 'Saat seç');
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tap(t, 'Onayla');
      await tap(t, 'Vazgeç');
      await tap(t, 'Mağazayı kaydet');
      expect(repo.last!.openingHours, isEmpty);
    },
  );
  testWidgets('two time selections store a normalized range', (t) async {
    await pump(t);
    await pickDay(t, 'mon', 'Saat seç');
    await tap(t, 'Onayla');
    await tap(t, 'Onayla');
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.openingHours['mon'], '09:00–18:00');
  });
  testWidgets('GPS requires confirmation and route preview uses exact point', (
    t,
  ) async {
    Uri? uri;
    await pump(
      t,
      load: () async => position(),
      map: (value) async {
        uri = value;
        return true;
      },
    );
    await tap(t, 'Mağazadayım, konumumu al');
    await tap(t, 'Bulunan konumu haritada kontrol et');
    expect(uri!.queryParameters['query'], '41.0,29.0');
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.latitude, isNull);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    await tap(t, 'Bu konum mağazama ait');
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.latitude, 41);
    expect(repo.last!.longitude, 29);
  });
  testWidgets('inaccurate or failed GPS retains existing coordinates', (
    t,
  ) async {
    repo.shop = repo.shop!.copyWith(latitude: 40, longitude: 28);
    await pump(t, load: () async => position(accuracy: 150));
    await tap(t, 'Mağazadayım, konumumu al');
    expect(find.text('Bu konum mağazama ait'), findsNothing);
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.latitude, 40);
    expect(repo.last!.longitude, 28);
  });
  testWidgets('explicit coordinate removal saves a null pair', (t) async {
    repo.shop = repo.shop!.copyWith(latitude: 40, longitude: 28);
    await pump(t);
    await tap(t, 'Kayıtlı konumu kaldır');
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.latitude, isNull);
    expect(repo.last!.longitude, isNull);
  });
  testWidgets(
    'late position after same-account new session never enters draft',
    (t) async {
      final gate = Completer<Position>();
      await pump(t, load: () => gate.future);
      await tap(t, 'Mağazadayım, konumumu al');
      key = 'two';
      gate.complete(position());
      await t.pumpAndSettle();
      expect(find.text('Bu konum mağazama ait'), findsNothing);
      expect(repo.saveCount, 0);
    },
  );
  testWidgets('late gallery response after new session never uploads', (
    t,
  ) async {
    final gate = Completer<XFile?>();
    await pump(t, pick: () => gate.future);
    await tap(t, 'Fotoğraf ekle');
    key = 'two';
    gate.complete(XFile.fromData(pixel, name: 'p.png'));
    await t.pumpAndSettle();
    expect(repo.staged, 0);
    expect(repo.saveCount, 0);
  });
  testWidgets('cancelled picker does not stage or dirty photo', (t) async {
    await pump(t, pick: () async => null);
    await tap(t, 'Fotoğraf ekle');
    await tap(t, 'Mağazayı kaydet');
    expect(repo.staged, 0);
    expect(repo.last!.photoPath, isNull);
  });
  testWidgets('oversize photo rejected before upload', (t) async {
    await pump(
      t,
      pick: () async =>
          XFile.fromData(Uint8List(shopPhotoMaxBytes + 1), name: 'large.png'),
    );
    await tap(t, 'Fotoğraf ekle');
    expect(repo.staged, 0);
    expect(find.text('Fotoğraf en fazla 5 MB olabilir.'), findsOneWidget);
  });
  testWidgets(
    'removed photo and confirmed coordinates reconcile a lost save without another write',
    (t) async {
      repo.shop = repo.shop!.copyWith(photoPath: 'shops/local/old.png');
      repo.loseReply = true;
      await pump(t, load: () async => position());
      await tap(t, 'Fotoğrafı kaldır');
      await tap(t, 'Mağazadayım, konumumu al');
      await tap(t, 'Bu konum mağazama ait');
      await tap(t, 'Mağazayı kaydet');
      expect(saved, 0);
      await tap(t, 'Güncel kaydı kontrol et');
      expect(
        find.text('Güncel kayıt, gönderdiğin bilgilerle aynı.'),
        findsOneWidget,
      );
      await tap(t, 'Güncel kayıtla devam et');
      expect(saved, 1);
      expect(repo.saveCount, 1);
    },
  );
  testWidgets('all controls fit at 320 width and double text size', (t) async {
    await pump(t, width: 320, scale: 2, load: () async => position());
    await tap(t, 'Mağazadayım, konumumu al');
    await t.ensureVisible(find.text('Bu konum mağazama ait'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await pickDay(t, 'sat', 'Kapalı');
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.text('Mağazayı kaydet'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
  testWidgets('photo path changes discard a late old signed URL', (t) async {
    final old = Completer<String>();
    Future<String> resolve(String path) =>
        path == 'old' ? old.future : Future.error('unavailable');
    Widget view(String path) => MaterialApp(
      home: ShopProfilePhoto(
        path: path,
        resolve: resolve,
        fallback: const Text('fallback'),
      ),
    );
    await t.pumpWidget(view('old'));
    await t.pumpWidget(view('new'));
    old.complete('https://old.invalid/private.png');
    await t.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(find.text('fallback'), findsOneWidget);
  });

  testWidgets(
    'valid photo is decoded, stripped of trailing metadata and staged before save',
    (t) async {
      final bytes = (await t.runAsync(realPhoto))!;
      final source = Uint8List.fromList([
        ...bytes,
        ...utf8.encode('GPS-private-test-metadata'),
      ]);
      await pump(t, pick: () async => XFile.fromData(source, name: 'shop.png'));
      await t.runAsync(() async {
        await t.tap(find.text('Fotoğraf ekle'));
        for (var i = 0; i < 100 && repo.staged == 0; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      await t.pumpAndSettle();
      expect(repo.staged, 1);
      expect(
        utf8.decode(repo.bytes!, allowMalformed: true),
        isNot(contains('GPS-private-test-metadata')),
      );
      expect(repo.shop!.photoPath, isNull);
      await tap(t, 'Mağazayı kaydet');
      expect(repo.last!.photoPath, 'shops/local/new.png');
    },
  );

  testWidgets('failed staging preserves existing photo and allows retry', (
    t,
  ) async {
    repo.shop = repo.shop!.copyWith(photoPath: 'shops/local/old.png');
    repo.failUpload = true;
    final bytes = (await t.runAsync(realPhoto))!;
    await pump(t, pick: () async => XFile.fromData(bytes, name: 'shop.png'));
    await t.runAsync(() async {
      await t.tap(find.text('Fotoğrafı değiştir'));
      for (var i = 0; i < 100 && repo.staged == 0; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await t.pumpAndSettle();
    expect(repo.staged, 1);
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.photoPath, 'shops/local/old.png');
  });

  testWidgets(
    'double tap opens one hours dialog; new session cannot apply its choice',
    (t) async {
      await pump(t);
      final day = find.byKey(const ValueKey('hours-mon'));
      await t.ensureVisible(day);
      await t.pumpAndSettle();
      await t.tap(day);
      await t.tap(day, warnIfMissed: false);
      await t.pumpAndSettle();
      expect(find.byType(SimpleDialog), findsOneWidget);
      key = 'two';
      await tap(t, 'Kapalı');
      expect(repo.saveCount, 0);
      expect(find.text('Kapalı'), findsNothing);
    },
  );

  for (final failure in [
    const FormatException('Konum izni verilmedi.'),
    TimeoutException('local timeout'),
  ]) {
    testWidgets('location error preserves old point: ${failure.runtimeType}', (
      t,
    ) async {
      repo.shop = repo.shop!.copyWith(latitude: 40, longitude: 28);
      await pump(t, load: () async => throw failure);
      await tap(t, 'Mağazadayım, konumumu al');
      await tap(t, 'Mağazayı kaydet');
      expect(repo.last!.latitude, 40);
      expect(repo.last!.longitude, 28);
    });
  }

  testWidgets('stale position cannot become the shop address', (t) async {
    await pump(
      t,
      load: () async => position(
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
    await tap(t, 'Mağazadayım, konumumu al');
    expect(find.text('Bu konum mağazama ait'), findsNothing);
    await tap(t, 'Mağazayı kaydet');
    expect(repo.last!.latitude, isNull);
  });

  testWidgets(
    'normal same-session refresh retains pending location and hours draft',
    (t) async {
      final gate = Completer<Position>();
      await pump(t, load: () => gate.future);
      await pickDay(t, 'sat', 'Kapalı');
      await tap(t, 'Mağazadayım, konumumu al');
      preview.changes.add(preview.currentId);
      await t.pumpAndSettle();
      gate.complete(position());
      await t.pumpAndSettle();
      await tap(t, 'Bu konum mağazama ait');
      await tap(t, 'Mağazayı kaydet');
      expect(repo.last!.latitude, 41);
      expect(repo.last!.openingHours['sat'], 'closed');
    },
  );
}
