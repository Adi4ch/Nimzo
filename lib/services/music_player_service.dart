abstract class MusicPlayerService {
  bool get isPlaying;
  String? get currentTrack;
  Future<void> play(String track);
  Future<void> pause();
  Future<void> dispose();
}

class DemoMusicPlayerService implements MusicPlayerService {
  @override
  bool isPlaying = false;

  @override
  String? currentTrack;

  @override
  Future<void> play(String track) async { currentTrack = track; isPlaying = true; }

  @override
  Future<void> pause() async => isPlaying = false;

  @override
  Future<void> dispose() async {}
}