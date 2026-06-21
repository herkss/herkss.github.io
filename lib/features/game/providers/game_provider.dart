import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';

class GameProvider extends ChangeNotifier {
  LevelConfig _levelConfig = LevelData.levels[0];
  int _stage = 1;

  List<CardModel> _cards = [];
  final List<int> _selectedIndices = [];
  bool _isEvaluating = false;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _moves = 0;
  int _mistakes = 0;
  int _matchedPairs = 0;

  int _timeRemaining = 120;
  int _timeLimit = 120;
  Timer? _timer;

  GameState _gameState = GameState.idle;

  int _hintCount = 3;
  int _peekCount = 1;

  // Getters
  List<CardModel> get cards => _cards;
  int get score => _score;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get moves => _moves;
  int get mistakes => _mistakes;
  int get matchedPairs => _matchedPairs;
  int get timeRemaining => _timeRemaining;
  int get timeLimit => _timeLimit;
  GameState get gameState => _gameState;
  LevelConfig get levelConfig => _levelConfig;
  int get stage => _stage;
  int get hintCount => _hintCount;
  int get peekCount => _peekCount;
  bool get isEvaluating => _isEvaluating;

  double get timeRatio => _timeRemaining / _timeLimit;
  int get totalPairs => _levelConfig.pairCount;
  int get stars => _calcStars();

  void initGame(int level, int stage) {
    _timer?.cancel();
    _levelConfig = LevelData.levels[level - 1];
    _stage = stage;

    final contents = LevelData.getContents(level, stage, _levelConfig.pairCount);
    final pairs = [...contents, ...contents]..shuffle();

    _cards = List.generate(pairs.length, (i) => CardModel(
      cardId: 'card_$i',
      pairId: pairs[i].id,
      content: pairs[i],
    ));

    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _moves = 0;
    _mistakes = 0;
    _matchedPairs = 0;
    _timeLimit = _levelConfig.timeLimit;
    _timeRemaining = _timeLimit;
    _selectedIndices.clear();
    _isEvaluating = false;
    _hintCount = 3;
    _peekCount = 1;
    _gameState = GameState.playing;

    _startTimer();
    AudioService.instance.playGameBgm(level);
    if (level >= 7) AudioService.instance.playBossEntry();
    notifyListeners();
  }

  void onCardTap(int index) {
    if (_isEvaluating) return;
    if (_gameState != GameState.playing) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    if (_selectedIndices.length >= 2) return;

    _cards[index] = _cards[index].copyWith(isFlipped: true);
    _selectedIndices.add(index);
    _moves++;
    AudioService.instance.playFlip();
    notifyListeners();

    if (_selectedIndices.length == 2) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    _isEvaluating = true;
    final i1 = _selectedIndices[0];
    final i2 = _selectedIndices[1];

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;

    if (_cards[i1].pairId == _cards[i2].pairId) {
      _combo++;
      _maxCombo = max(_combo, _maxCombo);
      final comboMult = min(_combo, 5);
      _score += 100 * _levelConfig.level * comboMult;
      _matchedPairs++;

      _cards[i1] = _cards[i1].copyWith(isMatched: true, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isMatched: true, isMismatched: false);

      if (_matchedPairs >= _levelConfig.pairCount) {
        _score += _timeRemaining * 15;
        _gameState = GameState.won;
        _timer?.cancel();
        AudioService.instance.stopBgm();
        AudioService.instance.playWin();
      } else if (_combo >= 5) {
        AudioService.instance.playBigCombo();
      } else if (_combo >= 3) {
        AudioService.instance.playCombo();
      } else {
        AudioService.instance.playMatch();
      }
    } else {
      _combo = 0;
      _mistakes++;
      AudioService.instance.playMismatch();
      _cards[i1] = _cards[i1].copyWith(isFlipped: false, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isFlipped: false, isMismatched: false);
    }

    _selectedIndices.clear();
    _isEvaluating = false;
    notifyListeners();
  }

  void useHint() {
    if (_hintCount <= 0 || _gameState != GameState.playing) return;
    _hintCount--;
    AudioService.instance.playItem();

    final unmatched = _cards
        .where((c) => !c.isMatched && !c.isFlipped)
        .map((c) => c.pairId)
        .toSet()
        .toList();
    if (unmatched.isEmpty) return;

    final targetPairId = unmatched.first;
    final indices = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].pairId == targetPairId && !_cards[i].isMatched) {
        indices.add(i);
      }
    }

    for (final i in indices) {
      _cards[i] = _cards[i].copyWith(isHinted: true);
    }
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      for (final i in indices) {
        if (i < _cards.length && !_cards[i].isMatched) {
          _cards[i] = _cards[i].copyWith(isHinted: false);
        }
      }
      notifyListeners();
    });
  }

  Future<void> usePeek() async {
    if (_peekCount <= 0 || _gameState != GameState.playing) return;
    _peekCount--;
    AudioService.instance.playItem();

    final unmatched = <int>[];
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isMatched && !_cards[i].isFlipped) {
        _cards[i] = _cards[i].copyWith(isHinted: true);
        unmatched.add(i);
      }
    }
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    for (final i in unmatched) {
      if (i < _cards.length && !_cards[i].isMatched) {
        _cards[i] = _cards[i].copyWith(isHinted: false);
      }
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState != GameState.playing) {
        _timer?.cancel();
        return;
      }
      if (_isEvaluating) return; // 카드 평가 중에는 타이머 정지 (마지막 매칭 버그 방지)
      _timeRemaining--;
      if (_timeRemaining <= 0) {
        _timeRemaining = 0;
        _gameState = GameState.lost;
        _timer?.cancel();
        AudioService.instance.stopBgm();
        AudioService.instance.playLose();
      }
      notifyListeners();
    });
  }

  int _calcStars() {
    if (_gameState != GameState.won) return 0;
    final timeRatio = _timeRemaining / _timeLimit;
    if (_mistakes == 0 && timeRatio >= 0.5) return 3;
    if (_mistakes <= 4 || timeRatio >= 0.25) return 2;
    return 1;
  }

  bool get mounted => true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
