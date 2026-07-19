import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/circular_icon_view_model.dart';
import 'package:t_store/core/common/widgets/circular_icon.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

typedef ProductFavoriteCurrentUserIdProvider = String? Function();

class ProductFavoriteButton extends StatefulWidget {
  const ProductFavoriteButton({
    super.key,
    required this.productId,
    required this.keyPrefix,
    this.currentUserIdProvider,
    this.height,
    this.width,
    this.iconSize,
    this.backgroundColor,
  });

  final String productId;
  final String keyPrefix;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final double? height;
  final double? width;
  final double? iconSize;
  final Color? backgroundColor;

  @override
  State<ProductFavoriteButton> createState() => _ProductFavoriteButtonState();
}

class _ProductFavoriteButtonState extends State<ProductFavoriteButton> {
  bool _favoriteActionPending = false;

  @override
  void initState() {
    super.initState();
    _loadWishlistIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isLoggedIn = _currentUserId != null;
        final isFavorite = context.read<WishlistCubit>().isInWishlist(
          widget.productId,
        );
        final isFavoriteLoading =
            isLoggedIn &&
            (_favoriteActionPending ||
                state is WishlistInitial ||
                state is WishlistLoading);

        if (isFavoriteLoading) {
          return _FavoriteLoadingIndicator(
            key: Key('${widget.keyPrefix}-loading'),
            height: widget.height,
            width: widget.width,
            backgroundColor: widget.backgroundColor,
            dark: dark,
          );
        }

        return Tooltip(
          message: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
          child: CircularIcon(
            key: Key('${widget.keyPrefix}-action'),
            circularIconModel: CircularIconModel(
              height: widget.height,
              width: widget.width,
              iconSize: widget.iconSize,
              backgroundColor: widget.backgroundColor,
              icon: isFavorite ? Iconsax.heart5 : Iconsax.heart,
              color: isFavorite
                  ? Colors.red
                  : (dark ? TColors.white : TColors.dark),
              onPressed: _handleFavoritePressed,
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

    await wishlistCubit.toggleWishlist(widget.productId);
    if (!mounted) return;

    setState(() => _favoriteActionPending = false);

    if (wishlistCubit.state is WishlistError) {
      _showFavoriteMessage(
        'Favoriler şu anda güncellenemedi. Lütfen tekrar deneyin.',
      );
      return;
    }

    final isFavorite = wishlistCubit.isInWishlist(widget.productId);
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
}

class _FavoriteLoadingIndicator extends StatelessWidget {
  const _FavoriteLoadingIndicator({
    super.key,
    required this.dark,
    this.height,
    this.width,
    this.backgroundColor,
  });

  final bool dark;
  final double? height;
  final double? width;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? TSizes.iconLg * 1.5,
      height: height ?? TSizes.iconLg * 1.5,
      padding: const EdgeInsets.all(TSizes.sm + 2),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (dark
                ? TColors.black.withValues(alpha: .9)
                : TColors.white.withValues(alpha: .9)),
        shape: BoxShape.circle,
      ),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
