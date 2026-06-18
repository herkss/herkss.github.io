import 'package:flutter/foundation.dart';
import '../../game/models/card_model.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';

enum MultiGameState { playing, finished }

class MultiGameProvider extends ChangeNotifier {
  LevelConfig _levelConfig = LevelData.levels[0];
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

  MultiGameState _state = MultiGameState.playing;
  bool _disposed = false;

  List<CardModel> get cards => _cards;
  int get currentPlayer => _currentPlayer;
  int get score1 => _score1;
  int get score2 => _score2;
  int get pairs1 => _pairs1;
  int get pairs2 => _pairs2;
  MultiGameState get state => _state;
  LevelConfig get levelConfig => _levelConfig;
  int get matchedPairs => _matchedPairs;
  int get totalPairs => _levelConfig.pairCount;
  bool get isEvaluating => _isEvaluating;
  int get stage => _stage;

  // 0 = 무승부, 1 = P1 승리, 2 = P2 승리
  int get winner {
    if (_score1 > _score2) return 1;
    if (_score2 > _score1) return 2;
    return 0;
  }

  void initGame(int level, int stage) {
    _disposed = false;
    _levelConfig = LevelData.levels[level - 1];
    _stage = stage;

    final contents = LevelData.getContents(level, stage, _levelConfig.pairCount);
    final pairs = [...contents, ...contents]..shuffle();

    _cards = List.generate(
      pairs.length,
      (i) => CardModel(cardId: 'card_$i', pairId: pairs[i].id, content: pairs[i]),
    );

    _matchedPairs = 0;
    _currentPlayer = 1;
    _score1 = 0;
    _score2 = 0;
    _pairs1 = 0;
    _pairs2 = 0;
    _selectedIndices.clear();
    _isEvaluating = false;
    _state = MultiGameState.playing;

    AudioService.instance.playGameBgm(level);
    notifyListeners();
  }

  void onCardTap(int index) {
    if (_isEvaluating) return;
    if (_state != MultiGameState.playing) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    if (_selectedIndices.length >= 2) return;

    _cards[index] = _cards[index].copyWith(isFlipped: true);
    _selectedIndices.add(index);
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
    if (_disposed) return;

    if (_cards[i1].pairId == _cards[i2].pairId) {
      // 매칭 성공 → 현재 플레이어 점수 추가, 턴 유지
      _cards[i1] = _cards[i1].copyWith(isMatched: true, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isMatched: true, isMismatched: false);

      final points = 100 * _levelConfig.level;
      if (_currentPlayer == 1) {
        _score1 += points;
        _pairs1++;
      } else {
        _score2 += points;
        _pairs2++;
      }
      _matchedPairs++;

      if (_matchedPairs >= _levelConfig.pairCount) {
        _state = MultiGameState.finished;
        AudioService.instance.stopBgm();
        AudioService.instance.playWin();
      } else {
        AudioService.instance.playMatch();
      }
    } else {
      // 매칭 실패 → 카드 닫고 다음 플레이어로 턴 이동
      _cards[i1] = _cards[i1].copyWith(isFlipped: false, isMismatched: false);
      _cards[i2] = _cards[i2].copyWith(isFlipped: false, isMismatched: false);
      AudioService.instance.playMismatch();
      _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    }

    _selectedIndices.clear();
    _isEvaluating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
