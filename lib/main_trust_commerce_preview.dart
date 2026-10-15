import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final host = MerchantPreview(), base = host.services;
  final trust = PreviewTrustCommerceRepository(
    user: () => host.currentId,
    sessionChanges: host.changes.stream,
  );
  runApp(
    MerchantApp(
      services: MerchantServices(
        merchants: base.merchants,
        credentials: base.credentials,
        notifications: base.notifications,
        qr: base.qr,
        preferences: base.preferences,
        sessionChanges: base.sessionChanges,
        currentUserId: base.currentUserId,
        preview: true,
        trustCommerce: trust,
      ),
    ),
  );
}
