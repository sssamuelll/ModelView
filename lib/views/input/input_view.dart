import 'dart:convert';

import 'package:flutter/material.dart';
import '../output/output_view.dart';
import 'package:model_view/theme/json_linter.dart';

import 'package:model_view/utils/constants.dart';

class InputView extends StatefulWidget {
  const InputView({super.key});

  @override
  _InputViewState createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  final _syntaxController = SyntaxHighlightingTextEditingController();
  String? _lintError;
  String _jsonText = '';

  @override
  void initState() {
    super.initState();
    _syntaxController.addListener(_onJsonChanged);
  }

  @override
  void dispose() {
    _syntaxController.removeListener(_onJsonChanged);
    _syntaxController.dispose();
    super.dispose();
  }

  void _onJsonChanged() {
    setState(() {
      _jsonText = _syntaxController.text;
      _lintError = null; // Clear lint error on text change
    });
  }

  void _navigateToOutput(BuildContext context) {
    try {
      var decodedJson = jsonDecode(_jsonText);
      setState(() {
        _lintError = null; // Clear lint error on success
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutputView(parsedJson: decodedJson),
        ),
      );
    } catch (e) {
      setState(() {
        _lintError = 'Invalid JSON. Please check the syntax.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelView - Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _syntaxController,
                maxLines: null, // Allow unlimited lines
                cursorColor: Colors.white,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: Colors.white, // Default text color
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                  filled: true,
                  fillColor: Color(0xFF21252B), // Background color
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_lintError != null)
              Text(
                _lintError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToOutput(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: jsonBoolColor,
              ),
              child: const Text('Visualize'),
            ),
          ],
        ),
      ),
    );
  }
}

class SyntaxHighlightingTextEditingController extends TextEditingController {
  SyntaxHighlightingTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];

    final String text = this.text;
    int index = 0;

    // Parser states

    ParserState state = ParserState.normal;
    StringBuffer buffer = StringBuffer();
    TextStyle currentStyle = style ?? const TextStyle();

    while (index < text.length) {
      String char = text[index];

      switch (state) {
        case ParserState.normal:
          if (char == '{') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inObject;
          } else if (char == '[') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inArray;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inObject:
          if (char == '"') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            buffer.write(char);
            state = ParserState.inKey;
          } else if (char == '}') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.normal;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inKey:
          buffer.write(char);
          if (char == '"') {
            _addSpan(children, buffer.toString(),
                currentStyle.copyWith(color: jsonKeyColor));
            buffer.clear();
            state = ParserState.afterKey;
          }
          break;

        case ParserState.afterKey:
          if (char == ':') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inValue;
          } else {
            _addSpan(children, char, currentStyle);
          }
          break;

        case ParserState.inValue:
          if (char == '"') {
            buffer.write(char);
            state = ParserState.inString;
          } else if (char == '{') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inObject;
          } else if (char == '[') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inArray;
          } else if (char == 't') {
            buffer.write(char);
            state = ParserState.inTrue;
          } else if (char == 'f') {
            buffer.write(char);
            state = ParserState.inFalse;
          } else if (char == 'n') {
            buffer.write(char);
            state = ParserState.inNull;
          } else if (RegExp(r'\d').hasMatch(char)) {
            buffer.write(char);
            state = ParserState.inNumber;
          } else if (char == ',' || char == '}') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inObject;
          } else {
            _addSpan(children, char, currentStyle);
          }
          break;

        case ParserState.inString:
          buffer.write(char);
          if (char == '"') {
            _addSpan(children, buffer.toString(),
                currentStyle.copyWith(color: jsonStringColor));
            buffer.clear();
            state = ParserState.inValue;
          }
          break;

        case ParserState.inNumber:
          if (char.trim().isEmpty ||
              char == ',' ||
              char == '}' ||
              char == ']') {
            _addSpan(children, buffer.toString(),
                currentStyle.copyWith(color: jsonNumberColor));
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inValue;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inTrue:
        case ParserState.inFalse:
        case ParserState.inNull:
          buffer.write(char);
          String keyword = buffer.toString();
          if ((state == ParserState.inTrue && keyword == 'true') ||
              (state == ParserState.inFalse && keyword == 'false') ||
              (state == ParserState.inNull && keyword == 'null')) {
            _addSpan(
                children, keyword, currentStyle.copyWith(color: jsonBoolColor));
            buffer.clear();
            state = ParserState.inValue;
          }
          break;

        case ParserState.inArray:
          if (char == ']') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inValue;
          } else if (char == '{') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState
                .inObject; // Volver al análisis de objeto dentro del array
          } else if (char == '[') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inArray; // Manejar arrays anidados
          } else {
            buffer.write(char);
          }
          break;
      }

      index++;
    }

    // Add any remaining text
    if (buffer.isNotEmpty) {
      _addSpan(children, buffer.toString(), currentStyle);
    }

    return TextSpan(style: style, children: children);
  }

  void _addSpan(List<TextSpan> children, String text, TextStyle style) {
    if (text.isNotEmpty) {
      children.add(TextSpan(text: text, style: style));
    }
  }
}
