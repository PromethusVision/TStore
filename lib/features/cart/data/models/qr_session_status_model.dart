class QrSessionStatusModel {
  static const Set<String> supportedStatuses = {
    'active',
    'used',
    'expired',
    'cancelled',
  };

  final String status;
  final DateTime expiresAt;

  const QrSessionStatusModel({required this.status, required this.expiresAt});

  factory QrSessionStatusModel.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString().trim() ?? '';
    if (!supportedStatuses.contains(status)) {
      throw const FormatException('QR oturum durumu gecersiz.');
    }

    final rawExpiresAt = json['expires_at'];
    final expiresAt = rawExpiresAt is DateTime
        ? rawExpiresAt
        : DateTime.tryParse(rawExpiresAt?.toString() ?? '');
    if (expiresAt == null) {
      throw const FormatException('QR oturum suresi gecersiz.');
    }

    return QrSessionStatusModel(status: status, expiresAt: expiresAt);
  }

  String resolveAt(DateTime now) {
    if (status == 'active' && !expiresAt.isAfter(now)) {
      return 'expired';
    }
    return status;
  }
}
