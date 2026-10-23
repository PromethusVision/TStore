import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Fresh one-shot position only: never reuse a Customer or last-known location.
Future<Position> loadMerchantShopPosition() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const FormatException('Telefonun konum hizmetini açıp yeniden dene.');
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const FormatException(
      'Telefon ayarlarından bu uygulamanın konum iznini aç.',
    );
  }
  if (permission != LocationPermission.always &&
      permission != LocationPermission.whileInUse) {
    throw const FormatException(
      'Konum izni verilmedi. Mağaza bilgilerini konum eklemeden kaydedebilirsin.',
    );
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 25),
    ),
  ).timeout(const Duration(seconds: 30));
}
