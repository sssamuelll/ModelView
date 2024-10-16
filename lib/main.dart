import 'package:flutter/material.dart';
import 'package:model_view/views/input/input_view.dart';
import 'package:model_view/theme/theme.dart';

void main() {
  runApp(const ModelViewApp());
}

class ModelViewApp extends StatelessWidget {
  const ModelViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ModelView',
      theme: darkTheme,
      home: const InputView(),
    );
  }
}
