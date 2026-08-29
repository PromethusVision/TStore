import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_state.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

typedef TaxonomyLeafDestinationBuilder =
    Widget Function(
      TaxonomyCategoryNode category,
      TaxonomyBreadcrumb breadcrumb,
      TaxonomyProductQueryScope queryScope,
    );

class TaxonomyBrowseView extends StatelessWidget {
  const TaxonomyBrowseView({
    super.key,
    required this.category,
    required this.repository,
    required this.capability,
    this.leafDestinationBuilder,
  });

  final TaxonomyCategoryNode category;
  final CanonicalTaxonomyRepository repository;
  final TaxonomyRuntimeCapability capability;
  final TaxonomyLeafDestinationBuilder? leafDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TaxonomyBrowseCubit(repository: repository, capability: capability)
            ..load(category),
      child: _TaxonomyBrowseContent(
        repository: repository,
        capability: capability,
        leafDestinationBuilder: leafDestinationBuilder,
      ),
    );
  }
}

class _TaxonomyBrowseContent extends StatelessWidget {
  const _TaxonomyBrowseContent({
    required this.repository,
    required this.capability,
    required this.leafDestinationBuilder,
  });

  final CanonicalTaxonomyRepository repository;
  final TaxonomyRuntimeCapability capability;
  final TaxonomyLeafDestinationBuilder? leafDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaxonomyBrowseCubit, TaxonomyBrowseState>(
      builder: (context, state) {
        if (state is TaxonomyBrowseLoaded &&
            state.navigationDecision.action ==
                TaxonomyCategoryNavigationAction.openProductListing) {
          return _leafDestination(
            state.category,
            state.breadcrumb,
            state.navigationDecision.productQueryScope!,
          );
        }

        final title = switch (state) {
          TaxonomyBrowseLoading(:final category) => category.displayName,
          TaxonomyBrowseLoaded(:final category) => category.displayName,
          _ => 'Kategoriler',
        };
        return Scaffold(
          key: const Key('taxonomy-browse-view'),
          backgroundColor: CustomerHomeV1Tokens.cream,
          appBar: AppBar(
            backgroundColor: CustomerHomeV1Tokens.cream,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(key: Key('taxonomy-browse-back')),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          body: SafeArea(top: false, child: _body(context, state)),
        );
      },
    );
  }

  Widget _body(BuildContext context, TaxonomyBrowseState state) {
    if (state is TaxonomyBrowseInitial || state is TaxonomyBrowseLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TaxonomyBrowseError) {
      return _TaxonomyBrowseStatus(
        key: const Key('taxonomy-browse-error'),
        message: state.message,
      );
    }
    if (state is TaxonomyBrowseBlocked) {
      return const _TaxonomyBrowseStatus(
        key: Key('taxonomy-browse-blocked'),
        message: 'Bu kategori şu anda kullanıma açık değil.',
      );
    }

    final loaded = state as TaxonomyBrowseLoaded;
    return Column(
      children: [
        Semantics(
          label: 'Kategori yolu: ${loaded.breadcrumb.fullLabel}',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loaded.breadcrumb.fullLabel,
                key: const Key('taxonomy-breadcrumb'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Expanded(
          child: loaded.children.isEmpty
              ? const _TaxonomyBrowseStatus(
                  key: Key('taxonomy-browse-empty'),
                  message:
                      'Bu kategoride gösterilecek alt kategori bulunamadı.',
                )
              : ListView.separated(
                  key: const Key('taxonomy-children-list'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: loaded.children.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final child = loaded.children[index];
                    final decision =
                        TaxonomyCategoryNavigationDecision.forCanonicalNode(
                          child,
                        );
                    final canOpen =
                        decision.action !=
                        TaxonomyCategoryNavigationAction.unavailable;
                    return ListTile(
                      key: Key('taxonomy-child-${child.id}'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        child.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        canOpen
                            ? Icons.chevron_right_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      onTap: canOpen
                          ? () => _openChild(
                              context,
                              loaded.breadcrumb,
                              child,
                              decision,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openChild(
    BuildContext context,
    TaxonomyBreadcrumb parentBreadcrumb,
    TaxonomyCategoryNode child,
    TaxonomyCategoryNavigationDecision decision,
  ) async {
    final childBreadcrumb = TaxonomyBreadcrumb([
      ...parentBreadcrumb.items,
      TaxonomyBreadcrumbItem(
        categoryId: child.id,
        label: child.displayName,
        level: child.level,
      ),
    ]);
    final destination = switch (decision.action) {
      TaxonomyCategoryNavigationAction.navigateDeeper => TaxonomyBrowseView(
        category: child,
        repository: repository,
        capability: capability,
        leafDestinationBuilder: leafDestinationBuilder,
      ),
      TaxonomyCategoryNavigationAction.openProductListing => _leafDestination(
        child,
        childBreadcrumb,
        decision.productQueryScope!,
      ),
      TaxonomyCategoryNavigationAction.unavailable => null,
    };
    if (destination == null || !context.mounted) return;
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Widget _leafDestination(
    TaxonomyCategoryNode node,
    TaxonomyBreadcrumb breadcrumb,
    TaxonomyProductQueryScope scope,
  ) {
    return leafDestinationBuilder?.call(node, breadcrumb, scope) ??
        SubCategoryView(
          title: node.displayName,
          categoryId: node.id,
          taxonomyQueryScope: scope,
        );
  }
}

class _TaxonomyBrowseStatus extends StatelessWidget {
  const _TaxonomyBrowseStatus({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
