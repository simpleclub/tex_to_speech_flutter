import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tex_to_speech/tex_to_speech.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await TexToSpeechFlutterBridge.init());
  test('Can call rust function', () async {
    expect(
      texToSpeech(text: "x = \\frac{ - b \\pm \\sqrt{ b^2 - 4 a c } }{ 2 a }"),
      "x ist gleich; der bruch mit zähler; negative b plus minus; die quadratwurzel von b quadrat minus 4 a c; und nenner 2 a",
    );
  });
}
