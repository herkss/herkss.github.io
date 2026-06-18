import 'dart:math';
import 'package:flutter/material.dart';
import '../../features/game/models/card_model.dart';
import 'app_colors.dart';

class LevelConfig {
  final int level;
  final int gridCols;
  final int gridRows;
  final int timeLimit;
  final String name;

  const LevelConfig({
    required this.level,
    required this.gridCols,
    required this.gridRows,
    required this.timeLimit,
    required this.name,
  });

  int get pairCount => (gridCols * gridRows) ~/ 2;
  int get totalCards => gridCols * gridRows;
}

enum StageTheme {
  numbers,
  alphabet,
  animals,
  food,
  nature,
  korean,
  flags,
  colors,
  objects,
  mix,
}

const _stageNames = [
  '숫자', '알파벳', '동물', '음식', '자연',
  '한글', '국기', '색상', '사물', '혼합',
];

const _stageIcons = ['🔢', '🔤', '🐾', '🍽️', '🌿', '한', '🌍', '🎨', '📦', '🎲'];

class LevelData {
  static const List<LevelConfig> levels = [
    LevelConfig(level: 1, gridCols: 3, gridRows: 4, timeLimit: 120, name: '튜토리얼'),
    LevelConfig(level: 2, gridCols: 4, gridRows: 4, timeLimit: 150, name: '입문'),
    LevelConfig(level: 3, gridCols: 4, gridRows: 5, timeLimit: 180, name: '쉬움'),
    LevelConfig(level: 4, gridCols: 4, gridRows: 6, timeLimit: 210, name: '쉬움+'),
    LevelConfig(level: 5, gridCols: 5, gridRows: 6, timeLimit: 250, name: '보통'),
    LevelConfig(level: 6, gridCols: 6, gridRows: 6, timeLimit: 290, name: '보통+'),
    LevelConfig(level: 7, gridCols: 6, gridRows: 7, timeLimit: 330, name: '어려움'),
    LevelConfig(level: 8, gridCols: 6, gridRows: 8, timeLimit: 370, name: '어려움+'),
    LevelConfig(level: 9, gridCols: 7, gridRows: 8, timeLimit: 430, name: '매우 어려움'),
    LevelConfig(level: 10, gridCols: 8, gridRows: 8, timeLimit: 500, name: '마스터'),
  ];

  static String stageName(int stage) => _stageNames[(stage - 1) % 10];
  static String stageIcon(int stage) => _stageIcons[(stage - 1) % 10];

  static const _animals = [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯',
    '🦁','🐮','🐷','🐸','🐵','🐔','🐧','🦆','🦅','🦉',
    '🦇','🐺','🐗','🐴','🦄','🐝','🦋','🐛','🐌','🐞',
    '🦀','🦑','🐙','🦈','🐬','🐳','🦭','🐊',
  ];

  static const _food = [
    '🍎','🍊','🍋','🍇','🍓','🫐','🍑','🍒','🍍','🥭',
    '🥝','🍅','🥥','🥕','🌽','🥦','🧅','🥔','🍄','🥑',
    '🍕','🍔','🌮','🍜','🍱','🍣','🍩','🎂','🍦','🧁',
    '🍪','🍰','☕','🧃','🍵','🥐',
  ];

  static const _nature = [
    '🌸','🌺','🌻','🌼','🌷','🌹','🍀','🌿','🌱','🌲',
    '🌳','🌴','🌵','🎋','🍁','🍂','🍃','🌊','🌈','⭐',
    '🌙','☀️','⛅','🌤️','🌧️','⛈️','❄️','🔥','💧','⚡',
    '🌪️','🌫️','🏔️','🌋','🏝️','🌅',
  ];

  static const _objects = [
    '⌚','📱','💻','🖥️','⌨️','🖱️','📷','📹','🔭','🔬',
    '🧪','🔋','💡','🔦','🎸','🎹','🎺','🎻','🥁','🎮',
    '🎯','🎳','🎨','✏️','📚','🔑','🏆','💎','🧩','🎁',
    '🎈','🎉','🪄','🧲','🔮','🧸',
  ];

  static const _flags = [
    '🇰🇷','🇺🇸','🇯🇵','🇨🇳','🇫🇷','🇩🇪','🇬🇧','🇧🇷',
    '🇮🇳','🇦🇺','🇨🇦','🇮🇹','🇪🇸','🇲🇽','🇷🇺','🇿🇦',
    '🇸🇬','🇹🇭','🇻🇳','🇵🇭','🇲🇾','🇮🇩','🇹🇷','🇸🇦',
    '🇦🇪','🇪🇬','🇦🇷','🇵🇹','🇳🇱','🇸🇪','🇳🇴','🇩🇰',
  ];

  static const _koreanWords = [
    '가','나','다','라','마','바','사','아','자','차',
    '카','타','파','하','강','낮','달','말','밤','빛',
    '산','안','잠','창','칼','탈','팔','봄','솔','꽃',
    '별','눈','물','불','숲','집',
  ];

  static const _colorNames = [
    '빨강','파랑','초록','노랑','보라','주황','분홍','하늘',
    '민트','금색','은색','검정','흰색','갈색','남색','연두',
    '자주','청록','베이지','카키','라임','인디고','산호','마젠타',
    '시안','마룬','올리브','청자','자홍','암녹','자홍2','금빛',
  ];

  static const _colorValues = [
    Color(0xFFFF3B30), Color(0xFF007AFF), Color(0xFF34C759), Color(0xFFFFCC00),
    Color(0xFFAF52DE), Color(0xFFFF9500), Color(0xFFFF2D55), Color(0xFF5AC8FA),
    Color(0xFF4ECDC4), Color(0xFFFFD700), Color(0xFFC0C0C0), Color(0xFF1C1C1E),
    Color(0xFFF2F2F7), Color(0xFFA2845E), Color(0xFF002D62), Color(0xFF90EE90),
    Color(0xFF800080), Color(0xFF008B8B), Color(0xFFF5F5DC), Color(0xFF8B7355),
    Color(0xFF32CD32), Color(0xFF4B0082), Color(0xFFFF7F50), Color(0xFFFF00FF),
    Color(0xFF00FFFF), Color(0xFF800000), Color(0xFF808000), Color(0xFF4682B4),
    Color(0xFF9400D3), Color(0xFF006400), Color(0xFFDA70D6), Color(0xFFDAA520),
  ];

  static List<CardContent> getContents(int level, int stage, int pairCount) {
    final theme = StageTheme.values[(stage - 1) % StageTheme.values.length];
    return _buildContents(theme, pairCount, level, stage);
  }

  static List<CardContent> _buildContents(
      StageTheme theme, int pairCount, int level, int stage) {
    switch (theme) {
      case StageTheme.numbers:
        return List.generate(pairCount, (i) => CardContent(
          id: 'num_$i',
          display: '${i + 1}',
          gradientIndex: i % AppColors.cardGradients.length,
        ));

      case StageTheme.alphabet:
        return List.generate(pairCount, (i) => CardContent(
          id: 'alp_$i',
          display: String.fromCharCode(65 + (i % 26)),
          gradientIndex: (i + 4) % AppColors.cardGradients.length,
        ));

      case StageTheme.animals:
        return List.generate(pairCount, (i) => CardContent(
          id: 'ani_$i',
          display: _animals[i % _animals.length],
          gradientIndex: (i + 8) % AppColors.cardGradients.length,
          isEmoji: true,
        ));

      case StageTheme.food:
        return List.generate(pairCount, (i) => CardContent(
          id: 'fod_$i',
          display: _food[i % _food.length],
          gradientIndex: (i + 12) % AppColors.cardGradients.length,
          isEmoji: true,
        ));

      case StageTheme.nature:
        return List.generate(pairCount, (i) => CardContent(
          id: 'nat_$i',
          display: _nature[i % _nature.length],
          gradientIndex: (i + 16) % AppColors.cardGradients.length,
          isEmoji: true,
        ));

      case StageTheme.korean:
        return List.generate(pairCount, (i) => CardContent(
          id: 'kor_$i',
          display: _koreanWords[i % _koreanWords.length],
          gradientIndex: (i + 20) % AppColors.cardGradients.length,
        ));

      case StageTheme.flags:
        return List.generate(pairCount, (i) => CardContent(
          id: 'flg_$i',
          display: _flags[i % _flags.length],
          gradientIndex: (i + 2) % AppColors.cardGradients.length,
          isEmoji: true,
        ));

      case StageTheme.colors:
        return List.generate(pairCount, (i) => CardContent(
          id: 'col_$i',
          display: _colorNames[i % _colorNames.length],
          gradientIndex: i % AppColors.cardGradients.length,
          solidColor: _colorValues[i % _colorValues.length],
        ));

      case StageTheme.objects:
        return List.generate(pairCount, (i) => CardContent(
          id: 'obj_$i',
          display: _objects[i % _objects.length],
          gradientIndex: (i + 6) % AppColors.cardGradients.length,
          isEmoji: true,
        ));

      case StageTheme.mix:
        final rng = Random(level * 100 + stage);
        final all = [..._animals, ..._food, ..._nature, ..._objects]..shuffle(rng);
        return List.generate(pairCount, (i) => CardContent(
          id: 'mix_$i',
          display: all[i % all.length],
          gradientIndex: (i + level * 3) % AppColors.cardGradients.length,
          isEmoji: true,
        ));
    }
  }
}
