import 'package:flutter/services.dart';
import 'package:t_store/features/shop/presentation/helpers/category_symbols.dart';

/// Loads the exact bundled font, so goldens cannot pass using missing-glyph boxes.
Future<void> loadCategoryIconFont() =>
    (FontLoader(CategorySymbols.fontFamily)..addFont(
          rootBundle.load('assets/fonts/EsnaftaVarCategorySymbols.ttf'),
        ))
        .load();
