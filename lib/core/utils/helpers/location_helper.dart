import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/helpers/logger_helper.dart';

class LocationHelper {
  static LocationSettings getPlatformSpecificSettings() {
    if (Platform.isAndroid) {
      LoggerHelper.info("Using Android-specific location settings");
      return AndroidSettings(accuracy: LocationAccuracy.best);
    } else if (Platform.isIOS) {
      LoggerHelper.info("Using iOS-specific location settings");
      return AppleSettings(accuracy: LocationAccuracy.best);
    } else {
      LoggerHelper.info("Using default location settings");
      return const LocationSettings(accuracy: LocationAccuracy.best);
    }
  }

  static Future<String?> getAddressFromCurrentLocation(
    BuildContext context,
  ) async {
    try {
      LoggerHelper.info('Konum izinleri kontrol ediliyor...');

      var status = await Permission.location.status;
      if (!context.mounted) return null;

      if (!status.isGranted) {
        LoggerHelper.warning('Konum izni verilmemiş. İzin isteniyor...');

        bool shouldRequestPermission =
            await THelperFunctions.showPermissionDialog(context);
        if (!context.mounted) return null;

        if (shouldRequestPermission) {
          status = await Permission.location.request();
          if (!context.mounted) return null;

          if (!status.isGranted) {
            LoggerHelper.error('Konum izni reddedildi.');

            if (status.isPermanentlyDenied) {
              bool shouldOpenSettings =
                  await showGeneralDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return ScaleTransition(
                        scale: animation,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(
                                Icons.location_disabled,
                                color: primaryRed,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Konum izni gerekiyor',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Konum izni kapalı. Devam etmek için uygulama ayarlarından izni açın.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: secondaryPurple,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.security_update_warning,
                                  size: 48,
                                  color: primaryRed,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'Vazgeç',
                                      style: TextStyle(
                                        color: accentRedText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Ayarları Aç',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      openAppSettings();
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          actionsPadding: const EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            24,
                          ),
                        ),
                      );
                    },
                  ) ??
                  false;

              if (shouldOpenSettings) {
                return null;
              }
            }
            return null;
          }
        } else {
          return null;
        }
      }

      LoggerHelper.info('Konum hizmetleri kontrol ediliyor...');

      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!context.mounted) return null;

        LoggerHelper.error('Konum hizmetleri kapalı.');
        bool shouldOpenSettings =
            await THelperFunctions.showLocationServiceDialog(context);
        if (!context.mounted) return null;

        if (!shouldOpenSettings ||
            !await Geolocator.isLocationServiceEnabled()) {
          return null;
        }
      }
      if (!context.mounted) return null;

      LoggerHelper.info('Mevcut konum belirleniyor...');

      final loadingNavigator = Navigator.of(context, rootNavigator: true);
      final loadingRoute = DialogRoute<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Konum belirleniyor',
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Konumunuz belirleniyor...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: secondaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
      unawaited(loadingNavigator.push<void>(loadingRoute));

      void closeLoadingDialog() {
        if (loadingNavigator.mounted && loadingRoute.isActive) {
          loadingNavigator.removeRoute(loadingRoute);
        }
      }

      try {
        // Get platform-specific location settings
        final locationSettings = getPlatformSpecificSettings();

        // Get current position with platform-specific settings
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        closeLoadingDialog();

        LoggerHelper.debug(
          'Konum belirlendi: enlem ${position.latitude}, boylam ${position.longitude}',
        );

        LoggerHelper.info('Konum bilgisi adrese dönüştürülüyor...');

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          // Create a more detailed address string
          List<String?> addressComponents =
              [place.locality, place.administrativeArea]
                  .where(
                    (component) => component != null && component.isNotEmpty,
                  )
                  .toList();

          String address = addressComponents
              .join(', ')
              .replaceAll(RegExp(r',\s*,'), ',')
              .replaceAll(RegExp(r'^\s*,\s*|\s*,\s*$'), '');

          if (context.mounted) {
            THelperFunctions.showSnackBar(
              type: SnackBarType.success,
              context: context,
              message: 'Konumunuz başarıyla belirlendi.',
            );
          }
          LoggerHelper.info('Adres bulundu: $address');
          return address;
        }

        return null;
      } catch (e) {
        closeLoadingDialog();

        // Show error snackbar
        if (context.mounted) {
          THelperFunctions.showSnackBar(
            type: SnackBarType.error,
            context: context,
            message: 'Konumunuz belirlenemedi. Lütfen tekrar deneyin.',
          );
        }

        LoggerHelper.error(
          'Konum belirlenirken beklenmeyen bir hata oluştu.',
          e,
        );
        return null;
      }
    } on PlatformException catch (e) {
      LoggerHelper.error(
        'Konum işlemi sırasında sistem hatası oluştu.',
        e.message,
      );
      if (context.mounted) {
        THelperFunctions.showSnackBar(
          type: SnackBarType.error,
          context: context,
          message: 'Konumunuz belirlenemedi. Lütfen tekrar deneyin.',
        );
      }
      return null;
    }
  }
}
