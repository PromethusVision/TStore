import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/core/navigation/engagement_auth_gate.dart';
import 'package:t_store/features/rewards/presentation/reward_center.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/navigation/engagement_target.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/helpers/taxonomy_category_destination.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

Future<Widget?> resolveEngagementDestination(EngagementTarget target) async {
  switch (target.type) {
    case EngagementTargetType.search:
      return AllProductsView(isSearchMode: true, initialQuery: target.value);
    case EngagementTargetType.product:
      return (await sl<GetProductByIdUsecase>()(
        target.value,
      )).fold((_) => null, (p) => ProductDetailsView(product: p));
    case EngagementTargetType.shop:
      return (await sl<GetShopByIdUsecase>()(target.value)).fold(
        (_) => null,
        (s) => s == null || !s.isActive ? null : ShopProfileView(shop: s),
      );
    case EngagementTargetType.category:
      final cubit = sl<CategoriesCubit>();
      try {
        final repository = cubit.activeCanonicalRepository;
        if (repository == null) return null;
        final breadcrumb = (await repository.getBreadcrumb(
          target.value,
        )).fold((_) => null, (b) => b);
        if (breadcrumb == null ||
            breadcrumb.current.categoryId != target.value) {
          return null;
        }
        final nodes = breadcrumb.items.length == 1
            ? await repository.getRoots()
            : await repository.getChildren(
                breadcrumb.items[breadcrumb.items.length - 2].categoryId,
              );
        final category = nodes.fold(
          (_) => null,
          (items) => items.where((n) => n.id == target.value).firstOrNull,
        );
        return category == null
            ? null
            : buildCanonicalTaxonomyDestination(
                category: category,
                repository: repository,
                capability: cubit.taxonomyCapability,
                breadcrumb: breadcrumb,
              );
      } finally {
        await cubit.close();
      }
    case EngagementTargetType.reward:
      return EngagementAuthGate(
        customerOnly: true,
        builder: (_) => const RewardCenter(),
      );
    case EngagementTargetType.messages:
      return EngagementAuthGate(builder: (_) => const ConversationsView());
    case EngagementTargetType.notifications:
      return EngagementAuthGate(
        builder: (context) {
          final state = context.read<AuthCubit>().state;
          return CustomerNotificationsView(
            appRole: state is AuthAuthenticated && state.user.isMerchant
                ? NotificationAppRole.merchant
                : NotificationAppRole.customer,
          );
        },
      );
  }
}

class EngagementDestination extends StatefulWidget {
  const EngagementDestination({
    super.key,
    required this.target,
    this.resolve = resolveEngagementDestination,
  });
  final EngagementTarget target;
  final Future<Widget?> Function(EngagementTarget) resolve;
  @override
  State<EngagementDestination> createState() => _EngagementDestinationState();
}

class _EngagementDestinationState extends State<EngagementDestination> {
  late final Future<Widget?> _destination = Future.sync(
    () => widget.resolve(widget.target),
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
    future: _destination,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        return snapshot.data!;
      }
      return Scaffold(
        appBar: AppBar(title: const Text('EsnaftaVar')),
        body: Center(
          child: snapshot.connectionState != ConnectionState.done
              ? const CircularProgressIndicator(
                  semanticsLabel: 'İçerik yükleniyor',
                )
              : const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Bu içerik şu anda kullanılamıyor.',
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      );
    },
  );
}
