import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';

enum SellerSortOption { cheapest, mostExpensive, highestRated, nearest }

class RankedSeller extends Equatable {
  const RankedSeller({
    required this.shopProduct,
    required this.originalIndex,
    required this.distanceMeters,
    required this.organicRank,
    required this.displayRank,
  });
  final ShopProductEntity shopProduct;
  final int originalIndex, organicRank, displayRank;
  final double? distanceMeters;
  @override
  List<Object?> get props => [
    shopProduct,
    originalIndex,
    distanceMeters,
    organicRank,
    displayRank,
  ];
}

/// Same existing comparison/tie rules, shared by the visible offers and hero.
/// There is no sponsored insertion: organicRank == displayRank in Slice A.
class SellerRanking {
  static List<RankedSeller> rank(
    List<ShopProductEntity> sellers,
    CustomerCoordinates? coordinates,
    SellerSortOption? sort, {
    bool Function(ShopProductEntity)? filter,
    double? radiusMeters,
  }) {
    final entries =
        <({ShopProductEntity listing, int index, double? distance})>[];
    for (var i = 0; i < sellers.length; i++) {
      final listing = sellers[i];
      if (!listing.isCustomerPurchasable ||
          (filter != null && !filter(listing))) {
        continue;
      }
      final distance = coordinates?.isValid != true
          ? null
          : CustomerProximityHelper.distanceInMeters(
              from: coordinates!,
              latitude: listing.shop?.latitude,
              longitude: listing.shop?.longitude,
            );
      if (radiusMeters != null &&
          (!radiusMeters.isFinite ||
              radiusMeters < 0 ||
              distance == null ||
              distance > radiusMeters)) {
        continue;
      }
      entries.add((listing: listing, index: i, distance: distance));
    }
    if (sort != null) {
      entries.sort((a, b) {
        final comparison = switch (sort) {
          SellerSortOption.cheapest => _compare(
            a.listing.price,
            b.listing.price,
            true,
          ),
          SellerSortOption.mostExpensive => _compare(
            a.listing.price,
            b.listing.price,
            false,
          ),
          SellerSortOption.highestRated => _compare(
            a.listing.shop?.rating,
            b.listing.shop?.rating,
            false,
          ),
          SellerSortOption.nearest => _compare(a.distance, b.distance, true),
        };
        return comparison != 0 ? comparison : a.index.compareTo(b.index);
      });
    }
    return List.unmodifiable([
      for (var i = 0; i < entries.length; i++)
        RankedSeller(
          shopProduct: entries[i].listing,
          originalIndex: entries[i].index,
          distanceMeters: entries[i].distance,
          organicRank: i + 1,
          displayRank: i + 1,
        ),
    ]);
  }

  static int _compare(double? a, double? b, bool ascending) {
    final av = a != null && a.isFinite, bv = b != null && b.isFinite;
    if (!av && !bv) return 0;
    if (!av) return 1;
    if (!bv) return -1;
    final result = a.compareTo(b);
    return ascending ? result : -result;
  }
}
