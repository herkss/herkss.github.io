import 'package:flutter/material.dart';

class CardContent {
  final String id;
  final String display;
  final int gradientIndex;
  final bool isEmoji;
  final Color? solidColor;

  const CardContent({
    required this.id,
    required this.display,
    required this.gradientIndex,
    this.isEmoji = false,
    this.solidColor,
  });
}

class CardModel {
  final String cardId;
  final String pairId;
  final CardContent content;
  final bool isFlipped;
  final bool isMatched;
  final bool isMismatched;
  final bool isHinted;

  const CardModel({
    required this.cardId,
    required this.pairId,
    required this.content,
    this.isFlipped = false,
    this.isMatched = false,
    this.isMismatched = false,
    this.isHinted = false,
  });

  CardModel copyWith({
    bool? isFlipped,
    bool? isMatched,
    bool? isMismatched,
    bool? isHinted,
  }) =>
      CardModel(
        cardId: cardId,
        pairId: pairId,
        content: content,
        isFlipped: isFlipped ?? this.isFlipped,
        isMatched: isMatched ?? this.isMatched,
        isMismatched: isMismatched ?? this.isMismatched,
        isHinted: isHinted ?? this.isHinted,
      );
}

enum GameState { idle, playing, paused, won, lost }
