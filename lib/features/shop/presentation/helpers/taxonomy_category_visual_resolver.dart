import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

/// Resolves a semantic child-category visual without relying on list position.
///
/// The small explicit set supports the W40A representative canonical branch.
/// Every other child receives the same neutral category glyph until a later,
/// dedicated child-category art stream supplies approved artwork.
abstract final class TaxonomyCategoryVisualResolver {
  static IconData resolve(String categoryName) {
    return switch (categoryName.trim().toLowerCase()) {
      'telefon & aksesuarları' => Icons.smartphone_rounded,
      'tv & görüntü sistemleri' => Icons.tv_rounded,
      'ses & kulaklık' => Icons.headphones_rounded,
      'fotoğraf & kamera' => Icons.photo_camera_rounded,
      'oyun konsolu & aksesuarları' => Icons.sports_esports_rounded,
      'giyilebilir teknoloji' => Icons.watch_rounded,
      'akıllı ev & güvenlik' => Icons.home_filled,
      'güç, şarj & bağlantı' => Icons.cable_rounded,
      'elektronik bileşenler' => Icons.memory_rounded,
      _ => Icons.category_rounded,
    };
  }

  static Color resolveSurface(String categoryName) {
    return switch (categoryName.trim().toLowerCase()) {
      'telefon & aksesuarları' => EsnaftaVarDiscoveryColors.categorySurfaces[0],
      'tv & görüntü sistemleri' =>
        EsnaftaVarDiscoveryColors.categorySurfaces[1],
      'ses & kulaklık' => EsnaftaVarDiscoveryColors.categorySurfaces[2],
      'fotoğraf & kamera' => EsnaftaVarDiscoveryColors.categorySurfaces[3],
      'oyun konsolu & aksesuarları' =>
        EsnaftaVarDiscoveryColors.categorySurfaces[4],
      'giyilebilir teknoloji' => EsnaftaVarDiscoveryColors.categorySurfaces[5],
      'akıllı ev & güvenlik' => EsnaftaVarDiscoveryColors.categorySurfaces[0],
      'güç, şarj & bağlantı' => EsnaftaVarDiscoveryColors.categorySurfaces[1],
      'elektronik bileşenler' => EsnaftaVarDiscoveryColors.categorySurfaces[2],
      _ => EsnaftaVarColors.primarySoft,
    };
  }
}
