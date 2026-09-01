import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/taxonomy_browse_state.dart';
import 'package:t_store/features/shop/presentation/helpers/taxonomy_category_visual_resolver.dart';
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
        initialCategoryTitle: category.displayName,
        repository: repository,
        capability: capability,
        leafDestinationBuilder: leafDestinationBuilder,
      ),
    );
  }
}

class _TaxonomyBrowseContent extends StatelessWidget {
  const _TaxonomyBrowseContent({
    required this.initialCategoryTitle,
    required this.repository,
    required this.capability,
    required this.leafDestinationBuilder,
  });

  final String initialCategoryTitle;
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
          _ => initialCategoryTitle,
        };
        return EsnaftaVarScaffold(
          key: const Key('taxonomy-browse-view'),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  _TaxonomyBrowseHeader(title: title),
                  Expanded(child: _body(context, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TaxonomyBrowseState state) {
    if (state is TaxonomyBrowseInitial || state is TaxonomyBrowseLoading) {
      return const _TaxonomyBrowseLoading();
    }
    if (state is TaxonomyBrowseError) {
      return _TaxonomyBrowseStatus(
        key: const Key('taxonomy-browse-error'),
        icon: Icons.cloud_off_rounded,
        title: 'Kategoriler yüklenemedi',
        message: state.message,
      );
    }
    if (state is TaxonomyBrowseBlocked) {
      return const _TaxonomyBrowseStatus(
        key: Key('taxonomy-browse-blocked'),
        icon: Icons.lock_outline_rounded,
        title: 'Kategori şu anda kapalı',
        message: 'Bu kategori şu anda kullanıma açık değil.',
      );
    }

    final loaded = state as TaxonomyBrowseLoaded;
    final usesScaledText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    return Column(
      children: [
        TaxonomyBreadcrumbBar(breadcrumb: loaded.breadcrumb),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            EsnaftaVarSpacing.md,
            EsnaftaVarSpacing.sm,
            EsnaftaVarSpacing.md,
            EsnaftaVarSpacing.sm,
          ),
          child: EsnaftaVarSectionHeader(
            title: 'Alt kategoriler',
            subtitle:
                '${loaded.children.length} alt kategori • Yakınındaki esnaflarda keşfet',
          ),
        ),
        Expanded(
          child: loaded.children.isEmpty
              ? const _TaxonomyBrowseStatus(
                  key: Key('taxonomy-browse-empty'),
                  icon: Icons.category_outlined,
                  title: 'Alt kategori bulunamadı',
                  message:
                      'Bu kategorinin keşif seçenekleri henüz hazır değil.',
                )
              : GridView.builder(
                  key: const Key('taxonomy-children-grid'),
                  padding: const EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    0,
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xl,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: EsnaftaVarSpacing.sm,
                    mainAxisSpacing: EsnaftaVarSpacing.sm,
                    mainAxisExtent: usesScaledText ? 142 : 118,
                  ),
                  itemCount: loaded.children.length,
                  itemBuilder: (context, index) {
                    final child = loaded.children[index];
                    final decision =
                        TaxonomyCategoryNavigationDecision.forCanonicalNode(
                          child,
                        );
                    final canOpen =
                        decision.action !=
                        TaxonomyCategoryNavigationAction.unavailable;
                    return _TaxonomyChildCard(
                      child: child,
                      decision: decision,
                      surfaceColor:
                          TaxonomyCategoryVisualResolver.resolveSurface(
                            child.displayName,
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

class _TaxonomyBrowseHeader extends StatelessWidget {
  const _TaxonomyBrowseHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.sm,
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: EsnaftaVarColors.divider)),
      ),
      child: Row(
        children: [
          EsnaftaVarSurfaceIconButton(
            buttonKey: const Key('taxonomy-browse-back'),
            icon: Icons.arrow_back_rounded,
            tooltip: 'Geri',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KATEGORİLER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: EsnaftaVarColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaxonomyBreadcrumbBar extends StatelessWidget {
  const TaxonomyBreadcrumbBar({super.key, required this.breadcrumb});

  final TaxonomyBreadcrumb breadcrumb;

  @override
  Widget build(BuildContext context) {
    final items = breadcrumb.items;
    final current = items.last;
    final parent = items.length > 1 ? items[items.length - 2] : null;
    return Semantics(
      label: 'Kategori yolu: ${breadcrumb.fullLabel}',
      child: Container(
        key: const Key('taxonomy-breadcrumb'),
        height: 36,
        margin: const EdgeInsets.fromLTRB(
          EsnaftaVarSpacing.md,
          EsnaftaVarSpacing.xs,
          EsnaftaVarSpacing.md,
          0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: EsnaftaVarSpacing.sm),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surfaceAlt,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.15;
            return Row(
              children: [
                const Icon(
                  Icons.home_outlined,
                  color: EsnaftaVarColors.primary,
                  size: EsnaftaVarIconSizes.small,
                ),
                if (!compact) ...[
                  const SizedBox(width: EsnaftaVarSpacing.xxs),
                  Text(
                    'Ana Sayfa',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EsnaftaVarColors.textSecondary,
                    ),
                  ),
                ],
                const _BreadcrumbChevron(),
                if (items.length > 2) ...[
                  Text(
                    '…',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: EsnaftaVarColors.textMuted,
                    ),
                  ),
                  const _BreadcrumbChevron(),
                ],
                if (parent != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: compact ? 56 : 88),
                    child: Text(
                      parent.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EsnaftaVarColors.textSecondary,
                      ),
                    ),
                  ),
                  const _BreadcrumbChevron(),
                ],
                Expanded(
                  child: Text(
                    current.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: EsnaftaVarColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BreadcrumbChevron extends StatelessWidget {
  const _BreadcrumbChevron();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        Icons.chevron_right_rounded,
        color: EsnaftaVarColors.textMuted,
        size: EsnaftaVarIconSizes.small,
      ),
    );
  }
}

class _TaxonomyChildCard extends StatelessWidget {
  const _TaxonomyChildCard({
    required this.child,
    required this.decision,
    required this.surfaceColor,
    required this.onTap,
  });

  final TaxonomyCategoryNode child;
  final TaxonomyCategoryNavigationDecision decision;
  final Color surfaceColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isContainer =
        decision.action == TaxonomyCategoryNavigationAction.navigateDeeper;
    final canOpen = onTap != null;
    final cueIcon = !canOpen
        ? Icons.lock_outline_rounded
        : isContainer
        ? Icons.chevron_right_rounded
        : Icons.storefront_outlined;
    final semanticAction = !canOpen
        ? 'şu anda kullanılamıyor'
        : isContainer
        ? 'alt kategorilerini aç'
        : 'ürünlerini gör';

    return Semantics(
      button: true,
      enabled: canOpen,
      label: '${child.displayName}, $semanticAction',
      child: Material(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: InkWell(
          key: Key('taxonomy-child-${child.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: EsnaftaVarSpacing.sm,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
              border: Border.all(color: EsnaftaVarColors.borderDefault),
              boxShadow: EsnaftaVarElevation.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.medium,
                        ),
                      ),
                      child: Icon(
                        TaxonomyCategoryVisualResolver.resolve(
                          child.displayName,
                        ),
                        color: canOpen
                            ? EsnaftaVarColors.primary
                            : EsnaftaVarColors.textMuted,
                        size: EsnaftaVarIconSizes.large,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: EsnaftaVarColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cueIcon,
                        color: canOpen
                            ? EsnaftaVarColors.primary
                            : EsnaftaVarColors.textMuted,
                        size: EsnaftaVarIconSizes.medium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: EsnaftaVarSpacing.xs),
                Expanded(
                  child: Text(
                    child.displayName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: canOpen
                          ? EsnaftaVarColors.textPrimary
                          : EsnaftaVarColors.textMuted,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaxonomyBrowseLoading extends StatelessWidget {
  const _TaxonomyBrowseLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: EsnaftaVarColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: EsnaftaVarSpacing.sm),
          Text('Kategoriler hazırlanıyor…'),
        ],
      ),
    );
  }
}

class _TaxonomyBrowseStatus extends StatelessWidget {
  const _TaxonomyBrowseStatus({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: Center(
        child: EsnaftaVarStateCard(icon: icon, title: title, message: message),
      ),
    );
  }
}
