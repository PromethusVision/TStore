/// Identity captured from an Auth event, not from the live session afterwards.
/// Local lifecycle evidence only; server authorization remains mandatory.
class MerchantSessionIdentity {
  const MerchantSessionIdentity({
    required this.userId,
    required this.sessionKey,
  });

  final String? userId;
  final String? sessionKey;
}
