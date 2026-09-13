import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Inspect resolved text, including inherited TextTheme colors, against its
/// nearest painted surface. Translucent surfaces are composited with ancestors.
void expectCustomerTextContrast(WidgetTester tester) {
  for (final element in find.byType(Text).evaluate()) {
    final text = element.widget as Text;
    if ((text.data ?? text.textSpan?.toPlainText() ?? '').trim().isEmpty) {
      continue;
    }
    final rich = find.descendant(
      of: find.byWidget(text),
      matching: find.byType(RichText),
    );
    if (rich.evaluate().length != 1) continue;
    final span = tester.widget<RichText>(rich).text;
    final foreground = span.style?.color;
    if (foreground == null) continue;
    var backgrounds = <Color>[Colors.transparent];
    var disabled = false;
    element.visitAncestorElements((ancestor) {
      final widget = ancestor.widget;
      if (widget is ButtonStyleButton && widget.onPressed == null) {
        disabled = true;
      }
      List<Color> paints = [];
      if (widget is DecoratedBox && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        paints =
            decoration.gradient?.colors ??
            [if (decoration.color != null) decoration.color!];
      } else if (widget is Material &&
          widget.type != MaterialType.transparency) {
        paints = [widget.color ?? Theme.of(ancestor).canvasColor];
      }
      if (paints.isNotEmpty) {
        backgrounds = [
          for (final front in backgrounds)
            for (final back in paints) Color.alphaBlend(front, back),
        ];
      }
      return backgrounds.any((color) => color.a < 1);
    });
    if (disabled) continue;
    for (final background in backgrounds) {
      final opaque = Color.alphaBlend(
        background,
        Theme.of(element).scaffoldBackgroundColor,
      );
      final rendered = Color.alphaBlend(foreground, opaque);
      final a = rendered.computeLuminance();
      final b = opaque.computeLuminance();
      final ratio = (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
      final size = span.style?.fontSize ?? 14;
      final bold = (span.style?.fontWeight?.value ?? 400) >= 700;
      final threshold = size >= 24 || (bold && size >= 18.66) ? 3.0 : 4.5;
      expect(
        ratio,
        greaterThanOrEqualTo(threshold),
        reason:
            '${text.data ?? text.textSpan?.toPlainText()}: $foreground on $opaque has contrast $ratio',
      );
    }
  }
}
