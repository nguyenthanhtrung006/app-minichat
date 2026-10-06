import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AudioPlayer API test', () {
    final player = AudioPlayer();
    expect(player, isNotNull);
    final source = AssetSource('audio/nhacchuongden.mp3');
    expect(source.path, equals('audio/nhacchuongden.mp3'));
    player.dispose();
  });
}
