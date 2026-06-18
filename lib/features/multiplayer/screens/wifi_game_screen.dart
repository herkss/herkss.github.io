import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/wifi_game_provider.dart';
import '../../game/widgets/flip_card_widget.dart';
import '../../game/models/card_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import 'multi_result_screen.dart';

class WifiGameScreen extends StatefulWidget {
  final WifiGameProvider provider;
  const WifiGameScreen({super.key, required this.provider});

  @override
  State<WifiGameScreen> createState() => _WifiGameScreenState();
}

class _WifiGameScreenState extends State<WifiGameScreen> {
  int _prevPlayer = 1;
  bool _showTurnBanner = false;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider(create: ...) 방식으로 화면 unmount 시 자동 dispose
    return ChangeNotifierProvider(
      create: (_) => widget.provider,
      child: _WifiGameContent(onPlayerChanged: _handlePlayerChanged),
    );
  }

  void _handlePlayerChanged(int newPlayer) {
    if (!mounted || newPlayer == _prevPlayer) return;
    setState(() {
      _prevPlayer = newPlayer;
      _showTurnBanner = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showTurnBanner = false);
    });
  }

  // 턴 배너가 필요한 경우 Stack으로 overlay
  // _WifiGameContent에서 호출
}

class _WifiGameContent extends StatefulWidget {
  final void Function(int) onPlayerChanged;
  const _WifiGameContent({required this.onPlayerChanged});

  @override
  State<_WifiGameContent> createState() => _WifiGameContentState();
}

class _WifiGameContentState extends State<_WifiGameContent> {
  int _prevPlayer = 1;
  bool _showTurnBanner = false;

  void _checkPlayerChange(int newPlayer) {
    if (newPlayer == _prevPlayer) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _prevPlayer = newPlayer;
          _showTurnBanner = true;
        });
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) setState(() => _showTurnBanner = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WifiGameProvider>(
      builder: (context, gp, _) {
        _checkPlayerChange(gp.currentPlayer);

        // 게임 종료 → 결과 화면
        if (gp.state == WifiGameState.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, __) => MultiResultScreen(
                    level: gp.level,
                    stage: gp.stage,
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

        // 연결 끊김
        if (gp.state == WifiGameState.disconnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showDisconnectDialog(context));
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      _WifiTopBar(gp: gp),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _WifiHud(gp: gp),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _CardGrid(
                            cards: gp.cards,
                            cols: gp.levelConfig.gridCols,
                            onTap: gp.onCardTap,
                            myTurn: gp.isMyTurn && !gp.isEvaluating,
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
              if (_showTurnBanner)
                _TurnBanner(
                  player: gp.currentPlayer,
                  isMe: gp.currentPlayer == gp.myPlayerNum,
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('연결 끊김', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('상대방과의 연결이 끊어졌습니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              AudioService.instance.playUIClick();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text('메인 메뉴', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _WifiTopBar extends StatelessWidget {
  final WifiGameProvider gp;
  const _WifiTopBar({required this.gp});

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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi, color: AppColors.primary, size: 13),
                    const SizedBox(width: 4),
                    const Text(
                      '와이파이 1v1',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.2),
                    ),
                  ],
                ),
                Text(
                  'Lv.${gp.level} · Stage ${gp.stage}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
        content: const Text('나가면 연결이 끊어집니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.textSecondary))),
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

// ─── WiFi HUD ─────────────────────────────────────────────────────────────────

class _WifiHud extends StatelessWidget {
  final WifiGameProvider gp;
  const _WifiHud({required this.gp});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _PlayerPanel(
          label: gp.network.isHost ? '나 (P1)' : '상대 (P1)',
          score: gp.score1,
          pairs: gp.pairs1,
          isActive: gp.currentPlayer == 1,
          isMe: gp.network.isHost,
          gradient: AppColors.primaryGradient,
          alignRight: false,
        )),
        const SizedBox(width: 8),
        _VsColumn(currentPlayer: gp.currentPlayer),
        const SizedBox(width: 8),
        Expanded(child: _PlayerPanel(
          label: !gp.network.isHost ? '나 (P2)' : '상대 (P2)',
          score: gp.score2,
          pairs: gp.pairs2,
          isActive: gp.currentPlayer == 2,
          isMe: !gp.network.isHost,
          gradient: AppColors.goldGradient,
          alignRight: true,
        )),
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final String label;
  final int score;
  final int pairs;
  final bool isActive;
  final bool isMe;
  final LinearGradient gradient;
  final bool alignRight;

  const _PlayerPanel({
    required this.label, required this.score, required this.pairs,
    required this.isActive, required this.isMe,
    required this.gradient, required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(
          color: isActive
              ? (gradient == AppColors.primaryGradient ? AppColors.primary : AppColors.gold)
              : AppColors.primary.withValues(alpha: 0.15),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive ? [BoxShadow(
          color: (gradient == AppColors.primaryGradient ? AppColors.primary : AppColors.gold)
              .withValues(alpha: 0.3),
          blurRadius: 14,
        )] : [],
      ),
      child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!alignRight && isActive) ...[_Dot(gradient: gradient), const SizedBox(width: 5)],
              Text(label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w900,
                color: isMe ? Colors.white : AppColors.textSecondary,
                letterSpacing: 0.5,
              )),
              if (alignRight && isActive) ...[const SizedBox(width: 5), _Dot(gradient: gradient)],
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text('$score', key: ValueKey(score), style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : AppColors.textSecondary,
            )),
          ),
          Text('$pairs쌍', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final LinearGradient gradient;
  const _Dot({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7, height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms);
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
              color: AppColors.gold, size: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text('VS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              color: AppColors.textSecondary, letterSpacing: 2)),
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
              const Text('진행', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text('$matched / $total 쌍', style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
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
  final bool isMe;
  const _TurnBanner({required this.player, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final gradient = player == 1 ? AppColors.primaryGradient : AppColors.goldGradient;
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                color: (player == 1 ? AppColors.primary : AppColors.gold).withValues(alpha: 0.5),
                blurRadius: 30, spreadRadius: 4,
              )],
            ),
            child: Text(
              isMe ? '내 턴!' : '상대방 턴!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: 2),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1),
                  duration: 250.ms, curve: Curves.elasticOut)
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
  final bool myTurn;

  const _CardGrid({required this.cards, required this.cols, required this.onTap, required this.myTurn});

  static const _gap = 5.0;
  static const _ratio = 1.3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (cards.length / cols).ceil();
        final wByW = (constraints.maxWidth - _gap * (cols - 1)) / cols;
        final wByH = (constraints.maxHeight - _gap * (rows - 1)) / rows / _ratio;
        final cw = min(wByW, wByH);

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
                      child: Opacity(
                        opacity: (!myTurn && !cards[i].isFlipped && !cards[i].isMatched) ? 0.7 : 1.0,
                        child: FlipCardWidget(
                          key: ValueKey(cards[i].cardId),
                          card: cards[i],
                          onTap: () => onTap(i),
                          size: cw,
                          animationDelay: (i * 25).clamp(0, 600),
                        ),
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
