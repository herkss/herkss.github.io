import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _bgmMuted = false;
  bool _sfxMuted = false;
  bool get muted => _sfxMuted;
  bool get bgmMuted => _bgmMuted;
  bool get sfxMuted => _sfxMuted;

  final _bgmPlayer = AudioPlayer();
  String? _currentBgm;

  final _sfxPool = List.generate(8, (_) => AudioPlayer());
  int _sfxIdx = 0;

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.35);
    _ready = true;
  }

  // ─── BGM ──────────────────────────────────────────────────────────────────

  Future<void> playMenuBgm() => _playBgm('audio/bgm_menu.mp3');

  Future<void> playGameBgm(int level) {
    final track = level <= 2
        ? 'audio/bgm_stage_1.mp3'
        : level <= 5
            ? 'audio/bgm_stage_2.mp3'
            : level <= 8
                ? 'audio/bgm_stage_3.mp3'
                : 'audio/bgm_stage_4.mp3';
    return _playBgm(track);
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playBgm(String path) async {
    if (_currentBgm == path) return;
    _currentBgm = path;
    if (_bgmMuted) return;
    try {
      await _bgmPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  // ─── Mute ─────────────────────────────────────────────────────────────────

  void toggleMute() => _sfxMuted = !_sfxMuted;

  Future<void> toggleBgmMute() async {
    _bgmMuted = !_bgmMuted;
    try {
      if (_bgmMuted) {
        await _bgmPlayer.pause();
      } else if (_currentBgm != null) {
        await _bgmPlayer.resume();
      }
    } catch (_) {}
  }

  // ─── SFX ──────────────────────────────────────────────────────────────────

  Future<void> playFlip() => _playSfx('audio/shoot.ogg');
  Future<void> playMatch() => _playSfx('audio/explosion.ogg');
  Future<void> playMismatch() => _playSfx('audio/player_hit.ogg');
  Future<void> playCombo() => _playSfx('audio/shoot_rapid.ogg');
  Future<void> playBigCombo() => _playSfx('audio/explosion_boss.ogg');
  Future<void> playWin() => _playSfx('audio/stage_clear.mp3');
  Future<void> playLose() => _playSfx('audio/game_over.mp3');
  Future<void> playBossEntry() => _playSfx('audio/boss_entry.ogg');
  Future<void> playItem() => _playSfx('audio/powerup.ogg');
  Future<void> playShield() => _playSfx('audio/shield.ogg');
  Future<void> playUIClick() => _playSfx('audio/ui_click.ogg');

  Future<void> _playSfx(String path) async {
    if (_sfxMuted || !_ready) return;
    try {
      final p = _sfxPool[_sfxIdx % _sfxPool.length];
      _sfxIdx++;
      await p.play(AssetSource(path), volume: 0.7);
    } catch (_) {}
  }

  void dispose() {
    _bgmPlayer.dispose();
    for (final p in _sfxPool) {
      p.dispose();
    }
  }
}
