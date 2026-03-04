import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../domain/song.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<void>? _completeSub;

  void init({required Future<void> Function() onComplete}) {
    _player.setReleaseMode(ReleaseMode.stop);

    _completeSub?.cancel();
    _completeSub = _player.onPlayerComplete.listen((_) async {
      await onComplete();
    });
  }

  Future<void> play(Song song, {double volume = 0.5}) async {
    await _player.stop();
    await _player.play(AssetSource(song.assetPath), volume: volume);
  }

  Future<void> stop() => _player.stop();

  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
  }
}
