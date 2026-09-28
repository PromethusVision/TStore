import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final preview = MerchantPreview();
  runApp(MerchantApp(services: preview.services));
}
