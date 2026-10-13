import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';

class SupabaseListingHeroMediaRepository implements ListingHeroMediaRepository {
  const SupabaseListingHeroMediaRepository(this.client);
  final SupabaseClient client;
  @override
  Future<List<ListingHeroPhoto>> photos(
    List<ShopProductEntity> rankedListings,
  ) async {
    final listings = rankedListings
        .where((s) => s.isCustomerPurchasable)
        .toList(growable: false);
    if (listings.isEmpty) return const [];
    final rows = <dynamic>[];
    try {
      for (var offset = 0; offset < listings.length; offset += 100) {
        final end = offset + 100 < listings.length
            ? offset + 100
            : listings.length;
        rows.addAll(
          await client.rpc(
                'catalog_listing_media_read_v1',
                params: {
                  'p_listing_ids': listings
                      .sublist(offset, end)
                      .map((s) => s.id)
                      .toList(),
                },
              )
              as List,
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST202' || e.code == '42883') {
        return const LegacyListingHeroMediaRepository().photos(listings);
      }
      rethrow; // Auth/network failures must not revive retired media.
    }
    final byId = {for (final row in rows) row['listing_id'] as String: row};
    final paths = <String>{
      for (final row in rows)
        if (row['managed'] == true)
          for (final media in row['images'] as List)
            if (media['bucket_id'] == 'listing-media')
              media['object_path'] as String,
    }.toList(growable: false);
    final signed = <String, String>{};
    // Bounded batch signing avoids one request per photo. Missing/denied
    // objects are skipped; the RPC's primary/order/id sequence stays intact.
    for (var offset = 0; offset < paths.length; offset += 100) {
      final end = offset + 100 < paths.length ? offset + 100 : paths.length;
      try {
        final batch = await client.storage
            .from('listing-media')
            .createSignedUrls(paths.sublist(offset, end), 300);
        for (final item in batch) {
          if (paths.contains(item.path) && !item.signedUrl.endsWith('null')) {
            signed[item.path] = item.signedUrl;
          }
        }
      } catch (_) {
        /* Other photo batches and eligible legacy listings remain usable. */
      }
    }
    final photos = <ListingHeroPhoto>[];
    for (final listing in listings) {
      final row = byId[listing.id];
      if (row == null) continue; // Server eligibility is authoritative.
      if (row['managed'] != true) {
        photos.addAll(
          await const LegacyListingHeroMediaRepository().photos([listing]),
        );
        continue;
      }
      for (final media in row['images'] as List) {
        final url = signed[media['object_path']];
        if (url != null) {
          photos.add(
            ListingHeroPhoto(
              listingId: listing.id,
              shopName: listing.shop?.name ?? 'Esnaf',
              source: url,
            ),
          );
        }
      }
    }
    return List.unmodifiable(photos);
  }
}
