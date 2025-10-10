import 'package:flutter/material.dart';
import 'package:tex_to_speech/tex_to_speech.dart';

Future<void> main() async {
  await TexToSpeechFlutterBridge.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            spacing: 6.0,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action: Call Rust `tex_to_speech("x = \\frac{ - b \\pm \\sqrt{ b^2 - 4 a c } }{ 2 a }")`\nResult: `${texToSpeech(text: "x = \\frac{ - b \\pm \\sqrt{ b^2 - 4 a c } }{ 2 a }")}`',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
