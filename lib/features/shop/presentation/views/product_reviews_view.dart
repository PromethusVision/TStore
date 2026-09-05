import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

part 'product_reviews_final_ui.dart';

typedef ProductReviewLoginDestinationBuilder =
    Widget Function(BuildContext context);

Widget _defaultLoginDestinationBuilder(BuildContext context) =>
    const LoginView(returnToCallerAfterCustomerLogin: true);

class ProductReviewsView extends StatelessWidget {
  const ProductReviewsView({
    super.key,
    required this.product,
    this.reviewsCubit,
    this.loginDestinationBuilder = _defaultLoginDestinationBuilder,
  });

  final ProductEntity product;
  final ReviewsCubit? reviewsCubit;
  final ProductReviewLoginDestinationBuilder loginDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    final content = _ProductReviewsScaffold(
      product: product,
      loginDestinationBuilder: loginDestinationBuilder,
    );
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
  const _ProductReviewsScaffold({
    required this.product,
    required this.loginDestinationBuilder,
  });

  final ProductEntity product;
  final ProductReviewLoginDestinationBuilder loginDestinationBuilder;

  @override
  State<_ProductReviewsScaffold> createState() =>
      _ProductReviewsScaffoldState();
}

class _ProductReviewsScaffoldState extends State<_ProductReviewsScaffold> {
  bool _isOpeningLogin = false;
  bool _isOpeningEditor = false;
  bool _isConfirmingDelete = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<ReviewsCubit>().getProductReviews(widget.product.id),
    );
  }

  Future<void> _refresh() => context.read<ReviewsCubit>().getProductReviews(
    widget.product.id,
    refresh: true,
  );

  Future<void> _loadMore() =>
      context.read<ReviewsCubit>().loadMoreReviews(widget.product.id);

  Future<void> _openLogin() async {
    if (_isOpeningLogin) return;
    _isOpeningLogin = true;
    try {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: widget.loginDestinationBuilder),
      );
      if (!mounted || signedIn != true) return;
      await _refresh();
    } finally {
      _isOpeningLogin = false;
    }
  }

  Future<void> _openEditor([ReviewEntity? review]) async {
    if (_isOpeningEditor) return;
    _isOpeningEditor = true;
    try {
      final cubit = context.read<ReviewsCubit>();
      final result = await showModalBottomSheet<ReviewMutationResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: EsnaftaVarColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(EsnaftaVarRadii.xxLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (_) => BlocProvider<ReviewsCubit>.value(
          value: cubit,
          child: _ReviewEditorSheet(
            productId: widget.product.id,
            productName: widget.product.name,
            review: review,
          ),
        ),
      );
      if (!mounted || result == null || result.ignored) return;
      _showMessage(result.message, isError: !result.succeeded);
    } finally {
      _isOpeningEditor = false;
    }
  }

  Future<void> _confirmDelete(ReviewEntity review) async {
    if (_isConfirmingDelete) return;
    _isConfirmingDelete = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          key: const Key('product-review-delete-dialog'),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: EsnaftaVarColors.error,
          ),
          title: const Text('Değerlendirme silinsin mi?'),
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.xxLarge),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.title?.trim().isNotEmpty ?? false) ...[
                Text(
                  review.title!.trim(),
                  style: Theme.of(dialogContext).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'Değerlendirmeniz ürün puanından çıkarılır. Doğrulanmış alışveriş kaydınız korunur ve daha sonra yeniden değerlendirme yapabilirsiniz.',
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const Key('product-review-delete-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              key: const Key('product-review-delete-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: EsnaftaVarColors.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      final result = await context.read<ReviewsCubit>().deleteReview(
        productId: widget.product.id,
        reviewId: review.id,
      );
      if (!mounted || result.ignored) return;
      _showMessage(result.message, isError: !result.succeeded);
    } finally {
      _isConfirmingDelete = false;
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (message.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? EsnaftaVarColors.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('product-reviews-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xs,
                    EsnaftaVarSpacing.md,
                    0,
                  ),
                  child: _ReviewsFinalHeader(productName: widget.product.name),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
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
                      final loaded = state as ReviewsLoaded;
                      return _ReviewsList(
                        state: loaded,
                        onRefresh: _refresh,
                        onLoadMore: _loadMore,
                        onLogin: _openLogin,
                        onRetryEligibility: () => context
                            .read<ReviewsCubit>()
                            .retryEligibility(widget.product.id),
                        onCreate: () => _openEditor(),
                        onEdit: _openEditor,
                        onDelete: _confirmDelete,
                      );
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

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onLogin,
    required this.onRetryEligibility,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewsLoaded state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onLogin;
  final Future<void> Function() onRetryEligibility;
  final VoidCallback onCreate;
  final ValueChanged<ReviewEntity> onEdit;
  final ValueChanged<ReviewEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: EsnaftaVarColors.primary,
      backgroundColor: EsnaftaVarColors.surface,
      onRefresh: onRefresh,
      child: ListView(
        key: const Key('product-reviews-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          EsnaftaVarSpacing.md,
          EsnaftaVarSpacing.xxs,
          EsnaftaVarSpacing.md,
          EsnaftaVarSpacing.xl,
        ),
        children: [
          _ReviewsFinalSummary(stats: state.stats),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          _EligibilityCard(
            state: state,
            onLogin: onLogin,
            onRetry: onRetryEligibility,
            onCreate: onCreate,
          ),
          const SizedBox(height: EsnaftaVarSpacing.md),
          Text(
            'Müşteri deneyimleri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: EsnaftaVarColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          if (state.reviews.isEmpty)
            const _EmptyReviewsCard()
          else
            for (var index = 0; index < state.reviews.length; index++) ...[
              _ReviewCard(
                review: state.reviews[index],
                isMutating: state.isMutating,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              if (index != state.reviews.length - 1)
                const SizedBox(height: EsnaftaVarSpacing.sm),
            ],
          if (!state.hasReachedMax) ...[
            const SizedBox(height: EsnaftaVarSpacing.md),
            OutlinedButton.icon(
              key: const Key('product-reviews-load-more'),
              onPressed: state.isLoadingMore ? null : onLoadMore,
              icon: state.isLoadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded),
              label: Text(
                state.isLoadingMore ? 'Yükleniyor' : 'Daha Fazla Göster',
              ),
            ),
          ],
          if (state.loadMoreFailure != null) ...[
            const SizedBox(height: EsnaftaVarSpacing.xs),
            _InlineMessage(
              key: const Key('product-reviews-load-more-error'),
              message: state.loadMoreFailure!.message,
              actionLabel: 'Tekrar Dene',
              onAction: onLoadMore,
            ),
          ],
        ],
      ),
    );
  }
}

class _EligibilityCard extends StatelessWidget {
  const _EligibilityCard({
    required this.state,
    required this.onLogin,
    required this.onRetry,
    required this.onCreate,
  });

  final ReviewsLoaded state;
  final Future<void> Function() onLogin;
  final Future<void> Function() onRetry;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final failure = state.eligibilityFailure;
    if (failure != null) {
      return _ReviewActionCard(
        key: const Key('product-review-eligibility-error'),
        icon: failure.requiresAuthentication
            ? Icons.login_rounded
            : Icons.sync_problem_rounded,
        title: failure.requiresAuthentication
            ? 'Oturumunuzu yenileyin'
            : 'Değerlendirme hakkı kontrol edilemedi',
        description: failure.message,
        actionLabel: failure.requiresAuthentication
            ? 'Giriş Yap'
            : 'Tekrar Dene',
        onAction: failure.requiresAuthentication ? onLogin : onRetry,
      );
    }

    final eligibility = state.eligibility;
    if (eligibility == null) {
      return _ReviewActionCard(
        key: const Key('product-review-eligibility-loading'),
        icon: Icons.hourglass_top_rounded,
        title: 'Değerlendirme hakkı kontrol ediliyor',
        description: 'Alışveriş kaydınız güvenli biçimde doğrulanıyor.',
        actionLabel: 'Tekrar Dene',
        onAction: onRetry,
      );
    }

    switch (eligibility.status) {
      case ProductReviewEligibilityStatus.guest:
        return _ReviewActionCard(
          key: const Key('product-review-eligibility-guest'),
          icon: Icons.login_rounded,
          title: 'Değerlendirme yazmak için giriş yapın',
          description:
              'Doğrulanmış mağaza içi alışverişinizi kontrol edebilmemiz için '
              'hesabınıza giriş yapın.',
          actionLabel: 'Giriş Yap',
          onAction: onLogin,
        );
      case ProductReviewEligibilityStatus.unverified:
        return const _ReviewActionCard(
          key: Key('product-review-eligibility-unverified'),
          icon: Icons.storefront_outlined,
          title: 'Doğrulanmış alışveriş gerekli',
          description:
              'Bu ürünü değerlendirebilmek için doğrulanmış mağaza içi '
              'alışveriş gerekir.',
        );
      case ProductReviewEligibilityStatus.canSubmit:
        return _ReviewActionCard(
          key: const Key('product-review-eligibility-can-submit'),
          icon: Icons.rate_review_outlined,
          title: 'Bu ürünü değerlendirebilirsiniz',
          description:
              'Puanınızı, kısa bir başlığı ve dilerseniz yorumunuzu paylaşın.',
          actionLabel: 'Değerlendirme Yaz',
          onAction: state.isMutating ? null : onCreate,
        );
      case ProductReviewEligibilityStatus.existingReview:
        return const _ReviewActionCard(
          key: Key('product-review-eligibility-existing'),
          icon: Icons.verified_outlined,
          title: 'Değerlendirmeniz yayınlandı',
          description:
              'Kendi değerlendirmenizi aşağıdaki listeden düzenleyebilir veya '
              'silebilirsiniz.',
        );
    }
  }
}

class _ReviewActionCard extends StatelessWidget {
  const _ReviewActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final FutureOr<void> Function()? onAction;

  @override
  Widget build(BuildContext context) => _buildReviewsFinalAction(this, context);
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isMutating,
    required this.onEdit,
    required this.onDelete,
  });

  final ReviewEntity review;
  final bool isMutating;
  final ValueChanged<ReviewEntity> onEdit;
  final ValueChanged<ReviewEntity> onDelete;

  @override
  Widget build(BuildContext context) => _buildReviewsFinalCard(this, context);
}

class _ReviewEditorSheet extends StatefulWidget {
  const _ReviewEditorSheet({
    required this.productId,
    required this.productName,
    this.review,
  });

  final String productId;
  final String productName;
  final ReviewEntity? review;

  @override
  State<_ReviewEditorSheet> createState() => _ReviewEditorSheetState();
}

class _ReviewEditorSheetState extends State<_ReviewEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;
  late int _rating;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.review != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.rating ?? 0;
    _titleController = TextEditingController(text: widget.review?.title ?? '');
    _commentController = TextEditingController(
      text: widget.review?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_rating < 1 || _rating > 5) {
      setState(() => _errorMessage = 'Lütfen 1 ile 5 arasında bir puan seçin.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final cubit = context.read<ReviewsCubit>();
    final result = _isEditing
        ? await cubit.updateReview(
            productId: widget.productId,
            reviewId: widget.review!.id,
            rating: _rating,
            title: _titleController.text,
            comment: _commentController.text,
          )
        : await cubit.submitReview(
            productId: widget.productId,
            rating: _rating,
            title: _titleController.text,
            comment: _commentController.text,
          );
    if (!mounted) return;
    if (result.succeeded) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() {
      _isSaving = false;
      if (!result.ignored) _errorMessage = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: !_isSaving,
      child: SingleChildScrollView(
        key: const Key('product-review-editor'),
        padding: EdgeInsets.fromLTRB(
          EsnaftaVarSpacing.lg,
          EsnaftaVarSpacing.md,
          EsnaftaVarSpacing.lg,
          EsnaftaVarSpacing.xl + bottomInset,
        ),
        child: CustomerLightInputTheme(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: EsnaftaVarColors.borderStrong,
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing
                              ? 'Değerlendirmenizi Düzenleyin'
                              : 'Ürünü Değerlendirin',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.productName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: EsnaftaVarColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('product-review-editor-close'),
                    tooltip: 'Kapat',
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: EsnaftaVarSpacing.lg),
              const Text(
                'Puanınız *',
                style: TextStyle(
                  color: EsnaftaVarColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: EsnaftaVarSpacing.xs),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    key: Key('product-review-rating-$value'),
                    tooltip: '$value yıldız',
                    onPressed: _isSaving
                        ? null
                        : () => setState(() => _rating = value),
                    iconSize: 36,
                    color: EsnaftaVarColors.highlight,
                    icon: Icon(
                      value <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                    ),
                  );
                }),
              ),
              const SizedBox(height: EsnaftaVarSpacing.sm),
              TextField(
                key: const Key('product-review-title-field'),
                controller: _titleController,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Kısa başlık (isteğe bağlı)',
                  hintText: 'Deneyiminizi özetleyin',
                ),
              ),
              const SizedBox(height: EsnaftaVarSpacing.sm),
              TextField(
                key: const Key('product-review-comment-field'),
                controller: _commentController,
                enabled: !_isSaving,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Yorum (isteğe bağlı)',
                  hintText: 'Ürünle ilgili deneyiminizi paylaşın',
                  alignLabelWithHint: true,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: EsnaftaVarSpacing.sm),
                _InlineMessage(
                  key: const Key('product-review-editor-error'),
                  message: _errorMessage!,
                ),
              ],
              const SizedBox(height: EsnaftaVarSpacing.lg),
              FilledButton.icon(
                key: const Key('product-review-submit'),
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: EsnaftaVarColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSaving
                      ? 'Kaydediliyor...'
                      : _isEditing
                      ? 'Değişiklikleri Kaydet'
                      : 'Değerlendirmeyi Gönder',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReviewsCard extends StatelessWidget {
  const _EmptyReviewsCard();

  @override
  Widget build(BuildContext context) => const EsnaftaVarStateCard(
    key: Key('product-reviews-empty'),
    icon: Icons.rate_review_outlined,
    title: 'Henüz ürün değerlendirmesi yok',
    message: 'Doğrulanmış müşteri değerlendirmeleri burada görünecek.',
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.errorSoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        border: Border.all(color: EsnaftaVarColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: EsnaftaVarColors.error),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(child: Text(message)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _ReviewsLoadingView extends StatelessWidget {
  const _ReviewsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        key: Key('product-reviews-loading'),
        color: EsnaftaVarColors.primary,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.xl),
      children: [
        Icon(icon, size: 48, color: EsnaftaVarColors.primary),
        const SizedBox(height: EsnaftaVarSpacing.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: EsnaftaVarColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(description, textAlign: TextAlign.center),
        const SizedBox(height: EsnaftaVarSpacing.lg),
        FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

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
        return Icon(icon, size: 18, color: EsnaftaVarColors.highlight);
      }),
    );
  }
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
