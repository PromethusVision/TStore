import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/view_models/circular_icon_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/circular_icon.dart';
import 'package:t_store/core/common/widgets/curved_widget.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

typedef ProductFavoriteCurrentUserIdProvider = String? Function();

class ProductImageSlider extends StatefulWidget {
  const ProductImageSlider({
    super.key,
    required this.product,
    this.currentUserIdProvider,
  });

  final ProductEntity product;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  bool _favoriteActionPending = false;

  @override
  void initState() {
    super.initState();
    _loadWishlistIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final productImages = _productImages;

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isLoggedIn = _currentUserId != null;
        final isFavorite = context.read<WishlistCubit>().isInWishlist(
          widget.product.id,
        );
        final isFavoriteLoading =
            isLoggedIn &&
            (_favoriteActionPending ||
                state is WishlistInitial ||
                state is WishlistLoading);

        return CurvedWidget(
          child: Container(
            decoration: BoxDecoration(
              color: dark ? TColors.darkGrey : TColors.light,
            ),
            child: Stack(
              children: [
                SelectedProductImage(image: productImages.first),
                OtherSameProductsList(images: productImages),
                CustomAppBar(
                  appBarModel: AppBarModel(
                    hasArrowBack: true,
                    actions: [
                      if (isFavoriteLoading)
                        _FavoriteLoadingIndicator(dark: dark)
                      else
                        Tooltip(
                          message: isFavorite
                              ? 'Favorilerden çıkar'
                              : 'Favorilere ekle',
                          child: CircularIcon(
                            key: const Key('product-details-favorite-action'),
                            circularIconModel: CircularIconModel(
                              icon: isFavorite ? Iconsax.heart5 : Iconsax.heart,
                              color: isFavorite
                                  ? Colors.red
                                  : (dark ? TColors.white : TColors.dark),
                              onPressed: _handleFavoritePressed,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadWishlistIfNeeded() {
    if (_currentUserId == null) return;

    final wishlistCubit = context.read<WishlistCubit>();
    if (wishlistCubit.state is WishlistInitial) {
      unawaited(wishlistCubit.getWishlist());
    }
  }

  Future<void> _handleFavoritePressed() async {
    if (_favoriteActionPending) return;

    if (_currentUserId == null) {
      THelperFunctions.navigateToScreen(context, const LoginView());
      return;
    }

    final wishlistCubit = context.read<WishlistCubit>();
    if (wishlistCubit.state is WishlistInitial ||
        wishlistCubit.state is WishlistLoading) {
      return;
    }

    setState(() => _favoriteActionPending = true);

    if (wishlistCubit.state is WishlistError) {
      await wishlistCubit.getWishlist();
      if (!mounted) return;

      setState(() => _favoriteActionPending = false);
      if (wishlistCubit.state is WishlistError) {
        _showFavoriteMessage(
          'Favoriler şu anda yüklenemedi. Lütfen tekrar deneyin.',
        );
      } else {
        _showFavoriteMessage(
          'Favori durumu yenilendi. Kalbe tekrar dokunabilirsin.',
        );
      }
      return;
    }

    await wishlistCubit.toggleWishlist(widget.product.id);
    if (!mounted) return;

    setState(() => _favoriteActionPending = false);

    if (wishlistCubit.state is WishlistError) {
      _showFavoriteMessage(
        'Favoriler şu anda güncellenemedi. Lütfen tekrar deneyin.',
      );
      return;
    }

    final isFavorite = wishlistCubit.isInWishlist(widget.product.id);
    _showFavoriteMessage(
      isFavorite ? 'Ürün favorilere eklendi.' : 'Ürün favorilerden çıkarıldı.',
    );
  }

  void _showFavoriteMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? get _currentUserId {
    final currentUserIdProvider = widget.currentUserIdProvider;
    final userId =
        (currentUserIdProvider != null
                ? currentUserIdProvider()
                : SupabaseService.instance.currentUser?.id)
            ?.trim();

    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  List<String> get _productImages {
    final images = widget.product.images
        .where((image) => image.trim().isNotEmpty)
        .toList(growable: false);

    if (images.isNotEmpty) return images;

    final thumbnail = widget.product.thumbnail;
    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      return [thumbnail];
    }

    return const [TImages.productImage13];
  }
}

class _FavoriteLoadingIndicator extends StatelessWidget {
  const _FavoriteLoadingIndicator({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('product-details-favorite-loading'),
      width: TSizes.iconLg * 1.5,
      height: TSizes.iconLg * 1.5,
      padding: const EdgeInsets.all(TSizes.sm + 2),
      decoration: BoxDecoration(
        color: dark
            ? TColors.black.withValues(alpha: .9)
            : TColors.white.withValues(alpha: .9),
        shape: BoxShape.circle,
      ),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
