import 'package:dartz/dartz.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

const merchantOperationsPageSize = 20;

class PendingListingUpload {
  const PendingListingUpload(this.listingId, this.productName, this.photoCount);
  final String listingId, productName;
  final int photoCount;
}

/// Exact totals are independent of the bounded, paginated recovery list.
class MerchantOperations {
  const MerchantOperations({
    this.pendingSubmissions = 0,
    this.approvedSubmissions = 0,
    this.rejectedSubmissions = 0,
    this.pendingListings = 0,
    this.uploads = const [],
  });
  final int pendingSubmissions, approvedSubmissions, rejectedSubmissions;
  final int pendingListings;
  final List<PendingListingUpload> uploads;
}

abstract interface class MerchantOperationsRepository {
  Future<Either<String, MerchantOperations>> read(
    MerchantAccess access, {
    int page = 0,
  });
}
