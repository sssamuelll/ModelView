import 'package:flutter/material.dart';
import 'package:model_view/theme/json_linter.dart'; // Import the linter file

class OutputView extends StatelessWidget {
  final dynamic parsedJson;

  const OutputView({super.key, required this.parsedJson});

  List<TextSpan> _highlightJson(dynamic data) {
    List<TextSpan> spans = [];
    spans.addAll(_parseJson(data, 0));
    return spans;
  }

  List<TextSpan> _parseJson(dynamic data, int depth) {
    List<TextSpan> spans = [];
    if (data is Map) {
      spans.add(
          const TextSpan(text: '{\n', style: TextStyle(color: Colors.white)));
      data.forEach((key, value) {
        spans.add(TextSpan(
            text: '  ' * depth + '"$key": ',
            style: TextStyle(
                color: jsonKeyColor))); // Use jsonKeyColor from linter
        spans.addAll(_parseJson(value, depth + 1));
        spans.add(const TextSpan(
            text: ',\n',
            style: TextStyle(color: Colors.white))); // Comma after each value
      });
      spans.add(TextSpan(
          text: '  ' * (depth - 1) + '}',
          style: TextStyle(color: Colors.white)));
    } else if (data is List) {
      spans.add(
          const TextSpan(text: '[\n', style: TextStyle(color: Colors.white)));
      for (var item in data) {
        spans.addAll(_parseJson(item, depth + 1));
        spans.add(const TextSpan(
            text: ',\n',
            style:
                TextStyle(color: Colors.white))); // Comma after each array item
      }
      spans.add(TextSpan(
          text: '  ' * (depth - 1) + ']',
          style: TextStyle(color: Colors.white)));
    } else if (data is String) {
      spans.add(TextSpan(
          text: '"$data"',
          style: TextStyle(
              color: jsonStringColor))); // Use jsonStringColor from linter
    } else if (data is num) {
      spans.add(TextSpan(
          text: '$data',
          style: TextStyle(
              color: jsonNumberColor))); // Use jsonNumberColor from linter
    } else if (data is bool) {
      spans.add(TextSpan(
          text: '$data',
          style: TextStyle(
              color: jsonBoolColor))); // Use jsonBoolColor from linter
    } else {
      spans.add(TextSpan(
          text: '$data',
          style: TextStyle(color: Colors.grey))); // Fallback color
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelView - Output'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              children: _highlightJson(parsedJson),
              style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace'), // Monospace font for code-like feel
            ),
          ),
        ),
      ),
    );
  }
}
