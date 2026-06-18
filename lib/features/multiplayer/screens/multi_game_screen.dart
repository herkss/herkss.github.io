import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/multi_game_provider.dart';
import '../../game/widgets/flip_card_widget.dart';
import '../../game/models/card_model.dart';
import '../../../core/constants/app_colors.dart';
import 'multi_result_screen.dart';

class MultiGameScreen extends StatefulWidget {
  final int level;
  final int stage;

  const MultiGameScreen({super.key, required this.level, required this.stage});

  @override
  State<MultiGameScreen> createState() => _MultiGameScreenState();
}

class _MultiGameScreenState extends State<MultiGameScreen> {
  int _prevPlayer = 1;
  bool _showTurnBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MultiGameProvider>().initGame(widget.level, widget.stage);
    });
  }

  void _onPlayerChanged(int newPlayer) {
    if (!mounted) return;
    setState(() {
      _prevPlayer = newPlayer;
      _showTurnBanner = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showTurnBanner = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiGameProvider>(
      builder: (context, gp, _) {
        // 턴 변경 감지
        if (gp.currentPlayer != _prevPlayer && !gp.isEvaluating) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _onPlayerChanged(gp.currentPlayer));
        }

        // 게임 종료 → 결과 화면 이동
        if (gp.state == MultiGameState.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => MultiResultScreen(
                    level: widget.level,
                    stage: widget.stage,
                    score1: gp.score1,
                    score2: gp.score2,
                    pairs1: gp.pairs1,
                    pairs2: gp.pairs2,
                    winner: gp.winner,
                  ),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            }
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      _TopBar(level: widget.level, stage: widget.stage),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _MultiHud(gp: gp),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _CardGrid(
                            cards: gp.cards,
                            cols: gp.levelConfig.gridCols,
                            onTap: gp.onCardTap,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ProgressRow(matched: gp.matchedPairs, total: gp.totalPairs),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              // 턴 전환 배너
              if (_showTurnBanner)
                _TurnBanner(player: gp.currentPlayer),
            ],
          ),
        );
      },
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int level;
  final int stage;
  const _TopBar({required this.level, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
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
                  '1 vs 1 멀티플레이',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Lv.$level · Stage $stage',
                  style: const TextStyle(
                    fontSize: 14,
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

// ─── Multi HUD ────────────────────────────────────────────────────────────────

class _MultiHud extends StatelessWidget {
  final MultiGameProvider gp;
  const _MultiHud({required this.gp});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _PlayerPanel(
            playerNum: 1,
            score: gp.score1,
            pairs: gp.pairs1,
            isActive: gp.currentPlayer == 1,
            alignRight: false,
          ),
        ),
        const SizedBox(width: 8),
        _VsColumn(currentPlayer: gp.currentPlayer),
        const SizedBox(width: 8),
        Expanded(
          child: _PlayerPanel(
            playerNum: 2,
            score: gp.score2,
            pairs: gp.pairs2,
            isActive: gp.currentPlayer == 2,
            alignRight: true,
          ),
        ),
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final int playerNum;
  final int score;
  final int pairs;
  final bool isActive;
  final bool alignRight;

  const _PlayerPanel({
    required this.playerNum,
    required this.score,
    required this.pairs,
    required this.isActive,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = playerNum == 1 ? AppColors.primaryGradient : AppColors.goldGradient;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(
          color: isActive
              ? (playerNum == 1 ? AppColors.primary : AppColors.gold)
              : AppColors.primary.withValues(alpha: 0.15),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (playerNum == 1 ? AppColors.primary : AppColors.gold)
                      .withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!alignRight && isActive)
                _ActiveDot(gradient: gradient),
              if (!alignRight && isActive) const SizedBox(width: 6),
              ShaderMask(
                shaderCallback: (b) => (isActive ? gradient : const LinearGradient(
                  colors: [AppColors.textSecondary, AppColors.textSecondary],
                )).createShader(b),
                child: Text(
                  'P$playerNum',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (alignRight && isActive) const SizedBox(width: 6),
              if (alignRight && isActive) _ActiveDot(gradient: gradient),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$pairs쌍',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActiveDot extends StatelessWidget {
  final LinearGradient gradient;
  const _ActiveDot({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 500.ms)
        .then()
        .fadeOut(duration: 500.ms);
  }
}

class _VsColumn extends StatelessWidget {
  final int currentPlayer;
  const _VsColumn({required this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              currentPlayer == 1 ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
              key: ValueKey(currentPlayer),
              color: AppColors.gold,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Row ─────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  final int matched;
  final int total;
  const _ProgressRow({required this.matched, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '$matched / $total 쌍',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? matched / total : 0,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Turn Banner ──────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  final int player;
  const _TurnBanner({required this.player});

  @override
  Widget build(BuildContext context) {
    final isP1 = player == 1;
    final gradient = isP1 ? AppColors.primaryGradient : AppColors.goldGradient;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isP1 ? AppColors.primary : AppColors.gold).withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Text(
              'P$player 의 턴!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 250.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 200.ms)
              .then(delay: 700.ms)
              .fadeOut(duration: 300.ms),
        ),
      ),
    );
  }
}

// ─── Card Grid ────────────────────────────────────────────────────────────────

class _CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final int cols;
  final void Function(int) onTap;

  const _CardGrid({required this.cards, required this.cols, required this.onTap});

  static const _gap = 5.0;
  static const _cardRatio = 1.3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (cards.length / cols).ceil();
        final cardWByWidth = (constraints.maxWidth - _gap * (cols - 1)) / cols;
        final cardHByHeight = (constraints.maxHeight - _gap * (rows - 1)) / rows;
        final cardWByHeight = cardHByHeight / _cardRatio;
        final cardW = min(cardWByWidth, cardWByHeight);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
