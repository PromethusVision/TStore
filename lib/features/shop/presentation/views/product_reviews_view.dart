import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class ProductReviewsView extends StatelessWidget {
  const ProductReviewsView({
    super.key,
    required this.product,
    this.reviewsCubit,
  });

  final ProductEntity product;
  final ReviewsCubit? reviewsCubit;

  @override
  Widget build(BuildContext context) {
    final content = _ProductReviewsScaffold(product: product);
    final providedCubit = reviewsCubit;

    if (providedCubit != null) {
      return BlocProvider<ReviewsCubit>.value(
        value: providedCubit,
        child: content,
      );
    }

    return BlocProvider<ReviewsCubit>(
      create: (_) => sl<ReviewsCubit>(),
      child: content,
    );
  }
}

class _ProductReviewsScaffold extends StatefulWidget {
  const _ProductReviewsScaffold({required this.product});

  final ProductEntity product;

  @override
  State<_ProductReviewsScaffold> createState() =>
      _ProductReviewsScaffoldState();
}

class _ProductReviewsScaffoldState extends State<_ProductReviewsScaffold> {
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<ReviewsCubit>().getProductReviews(widget.product.id),
    );
  }

  Future<void> _refresh() {
    return context.read<ReviewsCubit>().getProductReviews(
      widget.product.id,
      refresh: true,
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await context.read<ReviewsCubit>().loadMoreReviews(widget.product.id);
    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('product-reviews-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _ReviewsHeader(productName: widget.product.name),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: BlocBuilder<ReviewsCubit, ReviewsState>(
                    builder: (context, state) {
                      if (state is ReviewsInitial || state is ReviewsLoading) {
                        return const _ReviewsLoadingView();
                      }

                      if (state is ReviewsError) {
                        return _ReviewsStatusList(
                          key: const Key('product-reviews-error'),
                          icon: Icons.cloud_off_outlined,
                          title: 'Değerlendirmeler yüklenemedi',
                          description: state.message,
                          actionLabel: 'Tekrar Dene',
                          onAction: _refresh,
                        );
                      }

                      if (state is ReviewsLoaded && state.reviews.isEmpty) {
                        return _ReviewsStatusList(
                          key: const Key('product-reviews-empty'),
                          icon: Icons.rate_review_outlined,
                          title: 'Henüz ürün değerlendirmesi yok',
                          description:
                              'Müşteri değerlendirmeleri geldiğinde burada '
                              'görebileceksin.',
                          actionLabel: 'Yenile',
                          onAction: _refresh,
                        );
                      }

                      if (state is ReviewsLoaded) {
                        return _ReviewsSuccessList(
                          product: widget.product,
                          state: state,
                          isLoadingMore: _isLoadingMore,
                          onRefresh: _refresh,
                          onLoadMore: _loadMore,
                        );
                      }

                      return const _ReviewsLoadingView();
                    },
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

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader({required this.productName});

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('product-reviews-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('product-reviews-back'),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Geri',
            style: IconButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.mint,
              foregroundColor: CustomerHomeV1Tokens.petrol,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ürün Değerlendirmeleri',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CustomerHomeV1Tokens.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CustomerHomeV1Tokens.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Color(0xFFA66A00)),
          ),
        ],
      ),
    );
  }
}

class _ReviewsLoadingView extends StatelessWidget {
  const _ReviewsLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('product-reviews-loading'),
      padding: const EdgeInsets.fromLTRB(
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space4,
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space24,
      ),
      children: const [
        _LoadingBlock(height: 148),
        SizedBox(height: CustomerHomeV1Tokens.space12),
        _LoadingBlock(height: 190),
        SizedBox(height: CustomerHomeV1Tokens.space12),
        _LoadingBlock(height: 190),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: CustomerHomeV1Tokens.petrol,
        ),
      ),
    );
  }
}

class _ReviewsStatusList extends StatelessWidget {
  const _ReviewsStatusList({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space24,
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space24,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CustomerHomeV1Tokens.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomerHomeV1Tokens.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space20),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: CustomerHomeV1Tokens.petrol,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius16,
                    ),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewsSuccessList extends StatelessWidget {
  const _ReviewsSuccessList({
    required this.product,
    required this.state,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final ProductEntity product;
  final ReviewsLoaded state;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CustomerHomeV1Tokens.petrol,
      backgroundColor: CustomerHomeV1Tokens.surface,
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: const Key('product-reviews-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space4,
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ReviewsSummaryCard(product: product, reviews: state.reviews),
                const SizedBox(height: CustomerHomeV1Tokens.space16),
                Text(
                  'Müşteri deneyimleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CustomerHomeV1Tokens.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                for (var index = 0; index < state.reviews.length; index++) ...[
                  _ReviewCard(review: state.reviews[index]),
                  if (index != state.reviews.length - 1)
                    const SizedBox(height: CustomerHomeV1Tokens.space12),
                ],
                if (!state.hasReachedMax) ...[
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  OutlinedButton.icon(
                    key: const Key('product-reviews-load-more'),
                    onPressed: isLoadingMore ? null : onLoadMore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CustomerHomeV1Tokens.petrol,
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(
                        color: CustomerHomeV1Tokens.petrol,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius16,
                        ),
                      ),
                    ),
                    icon: isLoadingMore
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CustomerHomeV1Tokens.petrol,
                            ),
                          )
                        : const Icon(Icons.expand_more_rounded),
                    label: Text(
                      isLoadingMore ? 'Yükleniyor' : 'Daha Fazla Göster',
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsSummaryCard extends StatelessWidget {
  const _ReviewsSummaryCard({required this.product, required this.reviews});

  final ProductEntity product;
  final List<ReviewEntity> reviews;

  @override
  Widget build(BuildContext context) {
    final reviewCount = product.reviewsCount > 0
        ? product.reviewsCount
        : reviews.length;
    final loadedAverage = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
              reviews.length;
    final averageRating = product.rating > 0 ? product.rating : loadedAverage;

    return Container(
      key: const Key('product-reviews-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.petrol,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                _StarRow(
                  rating: averageRating,
                  color: CustomerHomeV1Tokens.yellow,
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space8),
                Text(
                  '$reviewCount değerlendirme',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final reviewerName = _reviewerName(review.userName);
    final title = review.title?.trim();
    final comment = review.comment?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasComment = comment != null && comment.isNotEmpty;

    return Container(
      key: Key('product-review-${review.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: CustomerHomeV1Tokens.mint,
                foregroundColor: CustomerHomeV1Tokens.petrol,
                child: Text(
                  _initials(reviewerName),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: CustomerHomeV1Tokens.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      _formatReviewDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CustomerHomeV1Tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.isVerifiedPurchase)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CustomerHomeV1Tokens.space8,
                    vertical: CustomerHomeV1Tokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: CustomerHomeV1Tokens.mint,
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radiusPill,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: CustomerHomeV1Tokens.green,
                      ),
                      SizedBox(width: CustomerHomeV1Tokens.space4),
                      Text(
                        'Doğrulanmış',
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          _StarRow(rating: review.rating.toDouble()),
          if (hasTitle) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: CustomerHomeV1Tokens.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: CustomerHomeV1Tokens.space8),
          Text(
            hasComment ? comment : 'Yalnızca puan verildi.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: hasComment
                  ? CustomerHomeV1Tokens.navy
                  : CustomerHomeV1Tokens.muted,
              height: 1.5,
            ),
          ),
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            Text(
              '${review.helpfulCount} kişi faydalı buldu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CustomerHomeV1Tokens.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.rating,
    this.color = CustomerHomeV1Tokens.yellow,
  });

  final double rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final icon = rating >= position
            ? Icons.star_rounded
            : rating >= position - 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return Icon(icon, size: 18, color: color);
      }),
    );
  }
}

String _reviewerName(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'Esnafta Var kullanıcısı';
  }
  return normalized;
}

String _initials(String value) {
  final words = value
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return 'E';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
      .toUpperCase();
}

String _formatReviewDate(DateTime? value) {
  if (value == null) return 'Tarih bilgisi yok';
  const months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
