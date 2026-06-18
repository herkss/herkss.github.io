import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';

class GameHudWidget extends StatelessWidget {
  const GameHudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              _ScoreBlock(score: gp.score),
              const SizedBox(width: 8),
              _ComboBlock(combo: gp.combo),
              const Spacer(),
              _TimerBlock(
                remaining: gp.timeRemaining,
                ratio: gp.timeRatio,
              ),
              const SizedBox(width: 8),
              _PairsBlock(
                matched: gp.matchedPairs,
                total: gp.totalPairs,
              ),
              const SizedBox(width: 6),
              _MuteButton(),
            ],
          ),
        );
      },
    );
  }
}

class _MuteButton extends StatefulWidget {
  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  bool _muted = AudioService.instance.muted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.toggleMute();
        setState(() => _muted = AudioService.instance.muted);
      },
      child: Icon(
        _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        color: _muted ? AppColors.textSecondary : AppColors.accentBlue,
        size: 20,
      ),
    );
  }
}

class _ScoreBlock extends StatefulWidget {
  final int score;
  const _ScoreBlock({required this.score});

  @override
  State<_ScoreBlock> createState() => _ScoreBlockState();
}

class _ScoreBlockState extends State<_ScoreBlock> {
  int _prev = 0;

  @override
  void didUpdateWidget(_ScoreBlock old) {
    super.didUpdateWidget(old);
    _prev = old.score;
  }

  @override
  Widget build(BuildContext context) {
    final changed = widget.score != _prev;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('점수', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(
          '${widget.score}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.gold,
          ),
        ).animate(key: ValueKey(widget.score), target: changed ? 1 : 0)
            .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 250.ms),
      ],
    );
  }
}

class _ComboBlock extends StatelessWidget {
  final int combo;
  const _ComboBlock({required this.combo});

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox(width: 50);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('콤보', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(
          '×$combo',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ).animate(key: ValueKey(combo))
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 200.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 150.ms),
      ],
    );
  }
}

class _TimerBlock extends StatelessWidget {
  final int remaining;
  final double ratio;

  const _TimerBlock({required this.remaining, required this.ratio});

  Color get _color {
    if (ratio > 0.5) return AppColors.timerNormal;
    if (ratio > 0.25) return AppColors.timerWarning;
    return AppColors.timerDanger;
  }

  String get _formatted {
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = ratio <= 0.25;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('시간', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(
          _formatted,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _color,
            fontFamily: 'monospace',
          ),
        ).animate(
          key: ValueKey(isLow),
          onPlay: (c) => isLow ? c.repeat() : c.stop(),
        ).shimmer(
          duration: 700.ms,
          color: isLow ? AppColors.timerDanger.withOpacity(0.6) : Colors.transparent,
        ),
      ],
    );
  }
}

class _PairsBlock extends StatelessWidget {
  final int matched;
  final int total;

  const _PairsBlock({required this.matched, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('매칭', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(
          '$matched/$total',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.accentGreen,
          ),
        ),
      ],
    );
  }
}

class ItemBarWidget extends StatelessWidget {
  const ItemBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ItemButton(
              icon: '💡',
              label: '힌트',
              count: gp.hintCount,
              onTap: gp.hintCount > 0 ? gp.useHint : null,
            ),
            const SizedBox(width: 16),
            _ItemButton(
              icon: '👁️',
              label: '피크',
              count: gp.peekCount,
              onTap: gp.peekCount > 0 ? gp.usePeek : null,
            ),
          ],
        );
      },
    );
  }
}

class _ItemButton extends StatelessWidget {
  final String icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  const _ItemButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = count > 0 && onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: active
              ? AppColors.primaryGradient
              : const LinearGradient(colors: [Color(0xFF2A2550), Color(0xFF2A2550)]),
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: active ? Colors.white.withOpacity(0.3) : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
