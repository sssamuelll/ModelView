import 'dart:convert';
import 'dart:io'; // Necesario para manejar archivos en escritorio.
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart'; // Importa desktop_drop
import 'package:cross_file/cross_file.dart'; // Importa XFile de cross_file
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
  bool _isDragging = false;

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
      _lintError = null;
    });
  }

  void _navigateToOutput(BuildContext context) {
    try {
      var decodedJson = jsonDecode(_jsonText);
      setState(() {
        _lintError = null;
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

  // Función para manejar el archivo arrastrado y leer su contenido.
  Future<void> _onFileDropped(List<XFile> files) async {
    if (files.isNotEmpty) {
      final file = files.first;
      if (file.name.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          setState(() {
            _jsonText = content;
            _syntaxController.text = _jsonText;
          });
        } catch (e) {
          setState(() {
            _lintError = 'Failed to read the file. Please try again.';
          });
        }
      } else {
        setState(() {
          _lintError = 'Please drop a valid .json file.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelView - Input'),
      ),
      body: Stack(
        children: [
          DropTarget(
            onDragEntered: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            onDragDone: (details) async {
              setState(() {
                _isDragging = false;
              });
              await _onFileDropped(
                  details.files); // Usa details.files con XFile
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _syntaxController,
                          maxLines: null,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'monospace',
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(8.0),
                            filled: true,
                            fillColor: Color(0xFF21252B),
                          ),
                        ),
                        if (_isDragging)
                          Container(
                            color: Colors.blue.withOpacity(0.3),
                            child: const Center(
                              child: Text(
                                'Suelta aquí tu archivo .json',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
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
          ),
        ],
      ),
    );
  }
}

// Custom TextEditingController to apply syntax highlighting to JSON text.
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

    ParserState state = ParserState.normal;
    List<ParserContext> contextStack = [];
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
            contextStack.add(ParserContext.object); // Push object context
            state = ParserState.inObject;
          } else if (char == '[') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            contextStack.add(ParserContext.array); // Push array context
            state = ParserState.inArray;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inObject:
          if (char.trim().isEmpty || char == '\n' || char == '\r') {
            _addSpan(children, char, currentStyle);
          } else if (char == '"') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            buffer.write(char);
            state = ParserState.inKey;
          } else if (char == '}') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            if (contextStack.isNotEmpty) {
              contextStack.removeLast(); // Pop object context
            }
            state = ParserState.afterValue;
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
          if (char.trim().isEmpty || char == '\n' || char == '\r') {
            _addSpan(children, char, currentStyle);
          } else if (char == ':') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state = ParserState.inValue;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inValue:
          if (char.trim().isEmpty || char == '\n' || char == '\r') {
            _addSpan(children, char, currentStyle);
          } else if (char == '"') {
            buffer.write(char);
            state = ParserState.inString;
          } else if (char == '{') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            contextStack.add(ParserContext.object); // Push object context
            state = ParserState.inObject;
          } else if (char == '[') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            contextStack.add(ParserContext.array); // Push array context
            state = ParserState.inArray;
          } else if (char == 't' || char == 'f' || char == 'n') {
            buffer.write(char);
            state = (char == 't')
                ? ParserState.inTrue
                : (char == 'f')
                    ? ParserState.inFalse
                    : ParserState.inNull;
          } else if (RegExp(r'[-0-9]').hasMatch(char)) {
            buffer.write(char);
            state = ParserState.inNumber;
          } else {
            buffer.write(char);
          }
          break;

        case ParserState.inString:
          buffer.write(char);
          if (char == '"') {
            _addSpan(children, buffer.toString(),
                currentStyle.copyWith(color: jsonStringColor));
            buffer.clear();
            state = ParserState.afterValue;
          }
          break;

        case ParserState.afterValue:
          if (char.trim().isEmpty || char == '\n' || char == '\r') {
            _addSpan(children, char, currentStyle);
          } else if (char == ',') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            // Decide next state based on context
            if (contextStack.isNotEmpty) {
              if (contextStack.last == ParserContext.object) {
                state = ParserState.inObject;
              } else if (contextStack.last == ParserContext.array) {
                state = ParserState.inArray;
              } else {
                state = ParserState.normal;
              }
            } else {
              state = ParserState.normal;
            }
          } else if (char == '}') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            if (contextStack.isNotEmpty) {
              contextStack.removeLast(); // Pop context
            }
            state = ParserState.afterValue;
          } else if (char == ']') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            if (contextStack.isNotEmpty) {
              contextStack.removeLast(); // Pop context
            }
            state = ParserState.afterValue;
          } else {
            // Posible carácter inesperado, volvemos a inValue
            buffer.write(char);
            state = ParserState.inValue;
          }
          break;

        case ParserState.inNumber:
          if (RegExp(r'[0-9.eE+-]').hasMatch(char)) {
            buffer.write(char);
          } else {
            _addSpan(children, buffer.toString(),
                currentStyle.copyWith(color: jsonNumberColor));
            buffer.clear();
            index--; // Re-evaluate this character
            state = ParserState.afterValue;
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
            state = ParserState.afterValue;
          } else if (keyword.length >= 5) {
            // Palabra clave inválida, volvemos a inValue
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            state = ParserState.inValue;
          }
          break;

        case ParserState.inArray:
          if (char.trim().isEmpty || char == '\n' || char == '\r') {
            _addSpan(children, char, currentStyle);
          } else if (char == ']') {
            _addSpan(children, buffer.toString(), currentStyle);
            buffer.clear();
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            if (contextStack.isNotEmpty) {
              contextStack.removeLast(); // Pop array context
            }
            state = ParserState.afterValue;
          } else if (char == ',') {
            _addSpan(children, char,
                currentStyle.copyWith(color: jsonPunctuationColor));
            state =
                ParserState.inValue; // Comenzar a parsear el siguiente valor
          } else {
            // Comenzar a parsear el valor del array
            index--; // Re-evaluar este carácter
            state = ParserState.inValue;
          }
          break;
      }
      index++;
    }

    // Agrega cualquier texto restante en el buffer al listado de children.
    if (buffer.isNotEmpty) {
      // Dependiendo del estado, asigna el estilo apropiado
      TextStyle finalStyle = currentStyle;
      if (state == ParserState.inString) {
        finalStyle = currentStyle.copyWith(color: jsonStringColor);
      } else if (state == ParserState.inNumber) {
        finalStyle = currentStyle.copyWith(color: jsonNumberColor);
      } else if (state == ParserState.inKey) {
        finalStyle = currentStyle.copyWith(color: jsonKeyColor);
      } else if (state == ParserState.inTrue ||
          state == ParserState.inFalse ||
          state == ParserState.inNull) {
        finalStyle = currentStyle.copyWith(color: jsonBoolColor);
      }
      _addSpan(children, buffer.toString(), finalStyle);
    }

    return TextSpan(style: style, children: children);
  }

  // Agrega un TextSpan a children si el texto no está vacío.
  void _addSpan(List<TextSpan> children, String text, TextStyle style) {
    if (text.isNotEmpty) {
      children.add(TextSpan(text: text, style: style));
    }
  }
}

enum ParserState {
  normal,
  inObject,
  inKey,
  afterKey,
  inValue,
  afterValue,
  inString,
  inNumber,
  inTrue,
  inFalse,
  inNull,
  inArray,
}

enum ParserContext {
  object,
  array,
}
