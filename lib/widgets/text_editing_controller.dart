import 'package:flutter/material.dart';
import 'package:model_view/theme/json_linter.dart';

class SyntaxHighlightingTextEditingController extends TextEditingController {
  SyntaxHighlightingTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context, // Agrega el parámetro BuildContext
    TextStyle? style,
    required bool withComposing,
  }) {
    final children = <TextSpan>[];

    final text = this.text;

    final regex = RegExp(
      r'(\".*?\"|\b\d+\.?\d*|\btrue\b|\bfalse\b|\bnull\b|[{}\[\],:])',
      multiLine: true,
    );

    final matches = regex.allMatches(text);

    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        // Añadir texto entre coincidencias
        children.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style?.copyWith(color: Colors.white),
        ));
      }

      final matchText = match.group(0)!;

      TextStyle matchStyle = style ?? const TextStyle();

      if (matchText.startsWith('"') && matchText.endsWith('"')) {
        // Cadenas de texto
        matchStyle = matchStyle.copyWith(color: jsonStringColor);
      } else if (matchText == 'true' ||
          matchText == 'false' ||
          matchText == 'null') {
        // Booleanos o null
        matchStyle = matchStyle.copyWith(color: jsonBoolColor);
      } else if (num.tryParse(matchText) != null) {
        // Números
        matchStyle = matchStyle.copyWith(color: jsonNumberColor);
      } else if ('{}[],:'.contains(matchText)) {
        // Puntuación
        matchStyle = matchStyle.copyWith(color: jsonPunctuationColor);
      } else {
        // Color por defecto
        matchStyle = matchStyle.copyWith(color: Colors.white);
      }

      children.add(TextSpan(
        text: matchText,
        style: matchStyle,
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      children.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style?.copyWith(color: Colors.white),
      ));
    }

    return TextSpan(style: style, children: children);
  }
}
