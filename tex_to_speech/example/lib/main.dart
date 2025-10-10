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
              SizedBox.square(dimension: 16.0),
              Expanded(child: _TexConverterForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class _TexConverterForm extends StatefulWidget {
  const _TexConverterForm({super.key});

  @override
  State<_TexConverterForm> createState() => __TexConverterFormState();
}

class __TexConverterFormState extends State<_TexConverterForm> {
  final TextEditingController _controller = TextEditingController();
  String? _speech;

  Object? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter TeX',
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            SizedBox.square(dimension: 8.0),
            IconButton.outlined(
              onPressed: () {
                final text = _controller.text;
                if (text.isEmpty) return;
                setState(() {
                  _speech = null;
                  _error = null;
                });
                try {
                  final result = texToSpeech(text: text);
                  if (!mounted) return;
                  setState(() {
                    _speech = result;
                  });
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _error = e;
                  });
                }
              },
              icon: const Icon(Icons.speaker),
            ),
          ],
        ),
        SizedBox.square(dimension: 8.0),
        Text(
          _speech ?? 'No speech generated yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (_error != null) ...[
          SizedBox.square(dimension: 8.0),
          Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}
