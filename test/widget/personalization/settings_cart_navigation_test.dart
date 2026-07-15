import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/customer_ratings_view.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockChatUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

void main() {
  const user = UserEntity(
    id: 'customer-1',
    email: 'customer@example.com',
    fullName: 'Müşteri Kullanıcı',
  );

  late MockAuthCubit authCubit;
  late MockAuthCubit loginAuthCubit;
  late MockCartV2Cubit cartV2Cubit;
  late MockChatUnreadCubit chatUnreadCubit;
  late MockPurchaseHistoryCubit purchaseHistoryCubit;

  setUp(() async {
    await sl.reset();

    authCubit = MockAuthCubit();
    loginAuthCubit = MockAuthCubit();
    cartV2Cubit = MockCartV2Cubit();
    chatUnreadCubit = MockChatUnreadCubit();
    purchaseHistoryCubit = MockPurchaseHistoryCubit();

    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {});

    whenListen(
      chatUnreadCubit,
      const Stream<ChatUnreadState>.empty(),
      initialState: const ChatUnreadLoaded(0),
    );
    when(() => chatUnreadCubit.loadUnreadCount()).thenAnswer((_) async {});
    when(() => chatUnreadCubit.close()).thenAnswer((_) async {});

    whenListen(
      purchaseHistoryCubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryLoaded([]),
    );
    when(() => purchaseHistoryCubit.loadPurchases()).thenAnswer((_) async {});
    when(() => purchaseHistoryCubit.close()).thenAnswer((_) async {});

    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => loginAuthCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<ChatUnreadCubit>(() => chatUnreadCubit);
    sl.registerFactory<PurchaseHistoryCubit>(() => purchaseHistoryCubit);
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    required AuthState authState,
    required String? currentUserId,
  }) {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SettingsView(currentUserIdProvider: () => currentUserId),
        ),
      ),
    );
  }

  testWidgets(
    'hesap ekranında sektör standardındaki müşteri seçeneklerini gösterir',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          authState: const AuthAuthenticated(user),
          currentUserId: user.id,
        ),
      );
      await tester.pumpAndSettle();

      for (final visibleOption in [
        'Mesajlarım',
        'Alışverişlerim',
        'Kuponlarım',
        'Son Görüntülediklerim',
        'Değerlendirmelerim',
        'Bildirimlerim',
        'Kayıtlı Konumlarım',
        'Hesap Bilgilerim',
        'Yardım ve Destek',
        'Gizlilik ve İzinler',
      ]) {
        expect(find.text(visibleOption), findsOneWidget);
      }

      expect(find.text('Çıkış Yap'), findsOneWidget);
      expect(find.text('Sepetim'), findsNothing);

      for (final hiddenOption in [
        'Adreslerim',
        'Esnaf Ol',
        'Mağazam',
        'İşlemlerim',
        'Banka Hesabı',
        'Bildirimler',
        'Hesap Gizliliği',
        'Uygulama Ayarları',
        'Veri Yükleme',
        'Konum',
        'Güvenli Mod',
        'HD Görsel Kalitesi',
      ]) {
        expect(find.text(hiddenOption), findsNothing);
      }
    },
  );

  testWidgets('Alışverişlerim yeni müşteri geçmişi ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Alışverişlerim'));
    await tester.tap(find.text('Alışverişlerim'));
    await tester.pumpAndSettle();

    expect(find.byType(PurchasesView), findsOneWidget);
    expect(find.text('İade Taleplerim'), findsOneWidget);
    expect(find.text('İade Talebi Oluştur'), findsOneWidget);
    verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
  });

  testWidgets('Hesap Bilgilerim mevcut profil ekranını açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Hesap Bilgilerim'));
    await tester.tap(find.text('Hesap Bilgilerim'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('customer@example.com'), findsOneWidget);
  });

  testWidgets('Değerlendirmelerim gerçek müşteri puanları ekranını açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Değerlendirmelerim'));
    await tester.tap(find.text('Değerlendirmelerim'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerRatingsView), findsOneWidget);
    expect(find.text('Henüz değerlendirme yapmadınız'), findsOneWidget);
    verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
  });

  testWidgets('hazırlanan seçenekler kullanıcıya açık bilgi verir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        authState: const AuthAuthenticated(user),
        currentUserId: user.id,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kuponlarım'));
    await tester.tap(find.text('Kuponlarım'));
    await tester.pump();

    expect(find.text('Kuponlarım bölümü hazırlanıyor.'), findsOneWidget);
  });
}
