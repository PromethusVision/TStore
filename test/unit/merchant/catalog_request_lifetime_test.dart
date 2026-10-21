import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/data/merchant_request_scope.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_catalog_cubit.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'merchant_repository_test.dart' show access, listing;

class _Listings extends Fake implements MerchantRepository {
  final response = Completer<Either<String, List<ShopProductEntity>>>();
  int calls = 0;
  @override
  Future<Either<String, List<ShopProductEntity>>> listings(
    MerchantAccess a, {
    int page = 0,
    String query = '',
  }) {
    calls++;
    return response.future;
  }
}

void main() {
  for (final active in [true, false]) {
    test(
      'catalog list continuation follows host lifetime active=$active',
      () async {
        var current = true;
        final repository = _Listings();
        final cubit = MerchantCatalogCubit(
          repository,
          access,
          isCurrent: () => current,
        );
        final request = cubit.load();
        current = active;
        repository.response.complete(Right([listing]));
        await request;
        expect(cubit.state.items.length, active ? 1 : 0);
        if (!active) {
          await cubit.load(refresh: true);
          expect(repository.calls, 1);
        }
        await cubit.close();
      },
    );
  }
  for (final source in ['actor', 'session']) {
    for (final event in ['change', 'error', 'end', 'renew']) {
      test(
        '$source $event fences pending success and later dispatch',
        () async {
          final actors = StreamController<String?>.broadcast(sync: true);
          final keys = StreamController<String?>.broadcast(sync: true);
          final scope = MerchantRequestScope(
            userId: 'owner',
            sessionKey: 'S1',
            currentUserId: () => 'owner',
            currentSessionKey: () => 'S1',
            changes: actors.stream,
            sessionKeys: keys.stream,
          );
          final response = Completer<int>();
          final pending = scope.run(() => response.future);
          final controller = source == 'actor' ? actors : keys;
          if (event == 'end') {
            await controller.close();
          } else if (event == 'error') {
            controller.addError(StateError('synthetic loss'));
          } else {
            controller.add(
              event == 'change'
                  ? 'other'
                  : (source == 'actor' ? 'owner' : 'S1'),
            );
            controller.add(source == 'actor' ? 'owner' : 'S1');
          }
          final expectation = expectLater(
            pending,
            event == 'renew'
                ? completion(1)
                : throwsA(isA<MerchantRequestChanged>()),
          );
          response.complete(1);
          await expectation;
          var dispatched = false;
          final next = scope.run(() async {
            dispatched = true;
            return 2;
          });
          await expectLater(
            next,
            event == 'renew'
                ? completion(2)
                : throwsA(isA<MerchantRequestChanged>()),
          );
          expect(dispatched, event == 'renew');
          await scope.close();
          expect(actors.hasListener, false);
          expect(keys.hasListener, false);
          await actors.close();
          await keys.close();
        },
      );
    }
  }
  for (final error in [false, true]) {
    test(
      'closing an abandoned request fences delayed error=$error and cancels listeners',
      () async {
        final actors = StreamController<String?>.broadcast(sync: true);
        final keys = StreamController<String?>.broadcast(sync: true);
        final scope = MerchantRequestScope(
          userId: 'owner',
          sessionKey: 'S1',
          currentUserId: () => 'owner',
          currentSessionKey: () => 'S1',
          changes: actors.stream,
          sessionKeys: keys.stream,
        );
        final gate = Completer<int>();
        final future = scope.run(() => gate.future);
        await scope.close();
        expect(actors.hasListener || keys.hasListener, false);
        final result = expectLater(
          future,
          throwsA(isA<MerchantRequestChanged>()),
        );
        if (error) {
          gate.completeError(StateError('late'));
        } else {
          gate.complete(1);
        }
        await result;
        await actors.close();
        await keys.close();
      },
    );
  }
  for (final operation in ['save', 'reload']) {
    for (final outcome in ['success', 'failure', 'throw']) {
      test(
        'editor $operation $outcome after host retirement cannot publish or retry',
        () async {
          var current = true, calls = 0, notifications = 0;
          final gate = Completer<Either<String, int>>();
          final recovery = MerchantEditRecovery<int>(
            isCurrent: () => current,
            read: () {
              calls++;
              return gate.future;
            },
          );
          recovery.addListener(() => notifications++);
          final work = operation == 'save'
              ? recovery.save(() {
                  calls++;
                  return gate.future;
                })
              : recovery.reload();
          current = false;
          if (outcome == 'throw') {
            gate.completeError(StateError('late'));
          } else {
            gate.complete(
              outcome == 'success' ? const Right(1) : const Left('late'),
            );
          }
          await work;
          expect(recovery.loaded, false);
          expect(recovery.current, isNull);
          expect(recovery.error, isNull);
          expect(notifications, 1);
          await recovery.reload();
          await recovery.save(() async {
            calls++;
            return const Right(2);
          });
          expect(calls, 1);
          recovery.dispose();
        },
      );
    }
  }
}
