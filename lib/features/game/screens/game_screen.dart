import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/game_hud_widget.dart';
import '../models/card_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_data.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int stage;

  const GameScreen({super.key, required this.level, required this.stage});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initGame(widget.level, widget.stage);
    });
  }

  void _goToResult(BuildContext context) {
    if (_navigating || !mounted) return;
    _navigating = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          level: widget.level,
          stage: widget.stage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        if (gp.gameState == GameState.won || gp.gameState == GameState.lost) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToResult(context));
        }

        final config = gp.levelConfig;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(level: widget.level, stage: widget.stage),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const GameHudWidget(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _CardGrid(
                        cards: gp.cards,
                        cols: config.gridCols,
                        onTap: gp.onCardTap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const ItemBarWidget(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final int level;
  final int stage;

  const _TopBar({required this.level, required this.stage});

  @override
  Widget build(BuildContext context) {
    final stageName = LevelData.stageName(stage);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _confirmQuit(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Lv.$level • Stage $stage',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  stageName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmQuit(context),
            icon: const Icon(Icons.home_outlined, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('게임 종료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('정말 나가시겠어요?\n진행 상황이 사라집니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text('나가기', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final int cols;
  final void Function(int) onTap;

  const _CardGrid({required this.cards, required this.cols, required this.onTap});

  static const _gap = 5.0;
  static const _cardRatio = 1.3; // height = width * ratio

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (cards.length / cols).ceil();

        // 가로/세로 양쪽 기준으로 카드 크기 계산 후 작은 값 사용
        final cardWByWidth = (constraints.maxWidth - _gap * (cols - 1)) / cols;
        final cardHByHeight = (constraints.maxHeight - _gap * (rows - 1)) / rows;
        final cardWByHeight = cardHByHeight / _cardRatio;
        final cardW = min(cardWByWidth, cardWByHeight);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(rows, (r) {
              final start = r * cols;
              final end = min(start + cols, cards.length);
              return Padding(
                padding: EdgeInsets.only(bottom: r < rows - 1 ? _gap : 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(end - start, (c) {
                    final i = start + c;
                    return Padding(
                      padding: EdgeInsets.only(right: c < (end - start) - 1 ? _gap : 0),
                      child: FlipCardWidget(
                        key: ValueKey(cards[i].cardId),
                        card: cards[i],
                        onTap: () => onTap(i),
                        size: cardW,
                        animationDelay: (i * 25).clamp(0, 600),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
