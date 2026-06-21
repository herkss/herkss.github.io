import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _ScoreBlockState extends State<_ScoreBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_ScoreBlock old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('점수',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Text(
            '${widget.score}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ComboBlock extends StatefulWidget {
  final int combo;
  const _ComboBlock({required this.combo});

  @override
  State<_ComboBlock> createState() => _ComboBlockState();
}

class _ComboBlockState extends State<_ComboBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );
    if (widget.combo >= 2) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_ComboBlock old) {
    super.didUpdateWidget(old);
    if (widget.combo >= 2 && widget.combo != old.combo) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.combo < 2) return const SizedBox(width: 50);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('콤보',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        // Use color alpha instead of Opacity widget — avoids compositing layer in CanvasKit
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Transform.scale(
            scale: _scale.value,
            child: Text(
              '×${widget.combo}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.accent.withValues(alpha: _opacity.value),
              ),
            ),
          ),
        ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('시간',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _color,
            fontFamily: 'monospace',
          ),
          child: Text(_formatted),
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
        Text('매칭',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
              : const LinearGradient(
                  colors: [Color(0xFF2A2550), Color(0xFF2A2550)]),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10)
                ]
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.surface,
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
