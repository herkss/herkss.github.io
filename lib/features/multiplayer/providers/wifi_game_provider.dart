import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../game/models/card_model.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';
import '../services/network_service.dart';

enum WifiGameState { waiting, playing, finished, disconnected }

/// Host = P1 (권위자), Guest = P2 (동기화 수신자)
///
/// 프로토콜:
///   Host → Guest  : game_start, state_update
///   Guest → Host  : card_tap
///   Both receive  : disconnected (socket closed)
class WifiGameProvider extends ChangeNotifier {
  final NetworkService network;

  WifiGameProvider(this.network) {
    _sub = network.messages.listen(_onMessage);
  }

  late final StreamSubscription<Map<String, dynamic>> _sub;

  LevelConfig _levelConfig = LevelData.levels[0];
  int _level = 1;
  int _stage = 1;

  List<CardModel> _cards = [];
  final List<int> _selectedIndices = [];
  bool _isEvaluating = false;
  int _matchedPairs = 0;

  int _currentPlayer = 1;
  int _score1 = 0;
  int _score2 = 0;
  int _pairs1 = 0;
  int _pairs2 = 0;

  WifiGameState _state = WifiGameState.waiting;
  bool _disposed = false;

  List<CardModel> get cards => _cards;
  int get currentPlayer => _currentPlayer;
  int get score1 => _score1;
  int get score2 => _score2;
  int get pairs1 => _pairs1;
  int get pairs2 => _pairs2;
  WifiGameState get state => _state;
  LevelConfig get levelConfig => _levelConfig;
  int get matchedPairs => _matchedPairs;
  int get totalPairs => _levelConfig.pairCount;
  bool get isEvaluating => _isEvaluating;
  int get level => _level;
  int get stage => _stage;

  /// 내 턴인지 여부 (Host=P1, Guest=P2)
  bool get isMyTurn =>
      (network.isHost && _currentPlayer == 1) ||
      (!network.isHost && _currentPlayer == 2);

  int get myPlayerNum => network.isHost ? 1 : 2;

  int get winner {
    if (_score1 > _score2) return 1;
    if (_score2 > _score1) return 2;
    return 0;
  }

  // ─── Host 전용: 게임 시작 ───────────────────────────────────────────────────

  void hostStartGame(int level, int stage) {
    if (!network.isHost) return;
    _level = level;
    _stage = stage;
    _levelConfig = LevelData.levels[level - 1];

    final contents = LevelData.getContents(level, stage, _levelConfig.pairCount);
    final pairs = [...contents, ...contents]..shuffle();

    _cards = List.generate(
      pairs.length,
      (i) => CardModel(cardId: 'card_$i', pairId: pairs[i].id, content: pairs[i]),
    );
    _resetScores();
    _state = WifiGameState.playing;

    // Guest에게 카드 배치 전송
    network.send({
      'type': 'game_start',
      'level': level,
      'stage': stage,
      'pairIds': pairs.map((c) => c.id).toList(),
    });

    AudioService.instance.playGameBgm(level);
    if (level >= 7) AudioService.instance.playBossEntry();
    notifyListeners();
  }

  // ─── 카드 탭 ───────────────────────────────────────────────────────────────

  void onCardTap(int index) {
    if (!isMyTurn) return;
    if (_isEvaluating) return;
    if (_state != WifiGameState.playing) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    if (_selectedIndices.length >= 2) return;

    if (network.isHost) {
      _applyFlip(index);
    } else {
      // Guest: 호스트에 전달, state_update 응답까지 잠금
      _isEvaluating = true;
      network.send({'type': 'card_tap', 'index': index});
      notifyListeners();
    }
  }

  void _applyFlip(int index) {
    _cards[index] = _cards[index].copyWith(isFlipped: true);
    _selectedIndices.add(index);
    AudioService.instance.playFlip();

    if (network.isHost) _broadcastState('flip');
    notifyListeners();

    if (_selectedIndices.length == 2) _evaluate();
  }

  // ─── Host 전용: 평가 (850ms 지연) ─────────────────────────────────────────

  Future<void> _evaluate() async {
    _isEvaluating = true;
    final i1 = _selectedIndices[0];
    final i2 = _selectedIndices[1];

    await Future.delayed(const Duration(milliseconds: 850));
    if (_disposed) return;

    String event;

    if (_cards[i1].pairId == _cards[i2].pairId) {
      _cards[i1] = _cards[i1].copyWith(isMatched: true, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isMatched: true, isMismatched: false);

      final pts = 100 * _levelConfig.level;
      if (_currentPlayer == 1) { _score1 += pts; _pairs1++; }
      else { _score2 += pts; _pairs2++; }
      _matchedPairs++;

      if (_matchedPairs >= _levelConfig.pairCount) {
        _state = WifiGameState.finished;
        event = 'win';
        AudioService.instance.stopBgm();
        AudioService.instance.playWin();
      } else {
        event = 'match';
        AudioService.instance.playMatch();
      }
    } else {
      _cards[i1] = _cards[i1].copyWith(isFlipped: false, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isFlipped: false, isMismatched: false);
      _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      event = 'mismatch';
      AudioService.instance.playMismatch();
    }

    _selectedIndices.clear();
    _isEvaluating = false;

    if (network.isHost) _broadcastState(event);
    notifyListeners();
  }

  // ─── Host: 상태 브로드캐스트 ──────────────────────────────────────────────

  void _broadcastState(String event) {
    network.send({
      'type': 'state_update',
      'cards': _cards.map((c) => {
        'f': c.isFlipped ? 1 : 0,
        'm': c.isMatched ? 1 : 0,
      }).toList(),
      'player': _currentPlayer,
      's1': _score1,
      's2': _score2,
      'p1': _pairs1,
      'p2': _pairs2,
      'mp': _matchedPairs,
      'event': event,
    });
  }

  // ─── 메시지 수신 처리 ──────────────────────────────────────────────────────

  void _onMessage(Map<String, dynamic> data) {
    if (_disposed) return;
    switch (data['type'] as String?) {
      case 'game_start':
        _handleGameStart(data);
      case 'card_tap':
        // Host가 Guest의 탭 수신
        if (network.isHost &&
            _state == WifiGameState.playing &&
            !_isEvaluating &&
            _currentPlayer == 2) {
          final idx = data['index'] as int;
          if (idx < _cards.length &&
              !_cards[idx].isFlipped &&
              !_cards[idx].isMatched &&
              _selectedIndices.length < 2) {
            _applyFlip(idx);
          }
        }
      case 'state_update':
        if (!network.isHost) _handleStateUpdate(data);
      case 'disconnected':
        _state = WifiGameState.disconnected;
        AudioService.instance.stopBgm();
        notifyListeners();
    }
  }

  void _handleGameStart(Map<String, dynamic> data) {
    _level = data['level'] as int;
    _stage = data['stage'] as int;
    _levelConfig = LevelData.levels[_level - 1];

    final pairIds = (data['pairIds'] as List).cast<String>();
    final contents = LevelData.getContents(_level, _stage, _levelConfig.pairCount);
    final contentMap = {for (final c in contents) c.id: c};

    _cards = List.generate(
      pairIds.length,
      (i) => CardModel(
        cardId: 'card_$i',
        pairId: pairIds[i],
        content: contentMap[pairIds[i]]!,
      ),
    );
    _resetScores();
    _state = WifiGameState.playing;

    AudioService.instance.playGameBgm(_level);
    if (_level >= 7) AudioService.instance.playBossEntry();
    notifyListeners();
  }

  void _handleStateUpdate(Map<String, dynamic> data) {
    final raw = (data['cards'] as List).cast<Map<String, dynamic>>();
    for (int i = 0; i < _cards.length && i < raw.length; i++) {
      _cards[i] = _cards[i].copyWith(
        isFlipped: raw[i]['f'] == 1,
        isMatched: raw[i]['m'] == 1,
      );
    }
    _currentPlayer = data['player'] as int;
    _score1 = data['s1'] as int;
    _score2 = data['s2'] as int;
    _pairs1 = data['p1'] as int;
    _pairs2 = data['p2'] as int;
    _matchedPairs = data['mp'] as int;
    _selectedIndices.clear();

    final event = data['event'] as String?;
    // 2장이 열려 있으면 평가 중으로 잠금
    final flippedOpen = _cards.where((c) => c.isFlipped && !c.isMatched).length;
    _isEvaluating = (event == 'flip' && flippedOpen >= 2);

    switch (event) {
      case 'flip':   AudioService.instance.playFlip();
      case 'match':  AudioService.instance.playMatch();
      case 'mismatch': AudioService.instance.playMismatch();
      case 'win':
        _state = WifiGameState.finished;
        AudioService.instance.stopBgm();
        AudioService.instance.playWin();
    }
    notifyListeners();
  }

  void _resetScores() {
    _matchedPairs = 0;
    _currentPlayer = 1;
    _score1 = 0; _score2 = 0;
    _pairs1 = 0; _pairs2 = 0;
    _selectedIndices.clear();
    _isEvaluating = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    network.dispose();
    super.dispose();
  }
}
