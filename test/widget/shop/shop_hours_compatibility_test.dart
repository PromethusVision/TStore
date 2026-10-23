import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_state.dart';
import 'package:t_store/features/shop/presentation/views/my_shop_form_view.dart';

class HoursCubit extends MockCubit<MyShopState> implements MyShopCubit {}

void main() {
  for (final edit in [false, true]) {
    testWidgets(
      'legacy editor preserves daily hours unless weekdays explicitly edited: $edit',
      (t) async {
        final cubit = HoursCubit();
        final original = <String, dynamic>{
          'mon': '08:00–16:00',
          'tue': 'closed',
          'note': 'koru',
        };
        final shop = ShopEntity(
          id: 'local',
          name: 'Yerel mağaza',
          openingHours: original,
        );
        when(() => cubit.state).thenReturn(MyShopLoaded(shop));
        when(
          () => cubit.updateMyShop(
            shopId: any(named: 'shopId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            phone: any(named: 'phone'),
            address: any(named: 'address'),
            openingHours: any(named: 'openingHours'),
          ),
        ).thenAnswer((_) async {});
        addTearDown(cubit.close);
        await t.pumpWidget(
          MaterialApp(
            home: BlocProvider<MyShopCubit>.value(
              value: cubit,
              child: MyShopFormView(shop: shop),
            ),
          ),
        );
        await t.pumpAndSettle();
        if (edit) {
          final field = find.widgetWithText(TextFormField, 'Hafta içi');
          await t.ensureVisible(field);
          await t.pumpAndSettle();
          await t.enterText(field, '10:00–19:00');
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pumpAndSettle();
        final save = find.text('Değişiklikleri Kaydet');
        await t.ensureVisible(save);
        await t.pumpAndSettle();
        await t.tap(save);
        await t.pumpAndSettle();
        final hours =
            verify(
                  () => cubit.updateMyShop(
                    shopId: 'local',
                    name: 'Yerel mağaza',
                    description: null,
                    phone: null,
                    address: null,
                    openingHours: captureAny(named: 'openingHours'),
                  ),
                ).captured.single
                as Map;
        if (edit) {
          expect(hours.containsKey('mon'), false);
          expect(hours.containsKey('tue'), false);
          expect(hours['mon_fri'], '10:00–19:00');
        } else {
          expect(hours, original);
        }
        expect(hours['note'], 'koru');
      },
    );
  }
}
