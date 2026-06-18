import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/card_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  final int level;
  final int stage;

  const ResultScreen({super.key, required this.level, required this.stage});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final won = gp.gameState == GameState.won;
    final stars = gp.stars;
    final nextStage = stage < 10 ? stage + 1 : null;
    final nextLevel = stage >= 10 && level < 10 ? level + 1 : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ResultHeader(won: won),
                  const SizedBox(height: 32),
                  if (won) _StarDisplay(stars: stars),
                  const SizedBox(height: 28),
                  _StatsCard(gp: gp),
                  const SizedBox(height: 36),
                  _ActionButtons(
                    level: level,
                    stage: stage,
                    nextStage: nextStage,
                    nextLevel: nextLevel,
                    won: won,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final bool won;
  const _ResultHeader({required this.won});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          won ? '🎉' : '😢',
          style: const TextStyle(fontSize: 72),
        ).animate().scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) => (won
                  ? AppColors.goldGradient
                  : const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF757575)]))
              .createShader(bounds),
          child: Text(
            won ? '스테이지 클리어!' : '시간 초과!',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }
}

class _StarDisplay extends StatelessWidget {
  final int stars;
  const _StarDisplay({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            active ? Icons.star_rounded : Icons.star_outline_rounded,
            color: active ? AppColors.starActive : AppColors.starInactive,
            size: active ? 56 : 48,
          ).animate(delay: Duration(milliseconds: 500 + i * 200))
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(
                duration: 600.ms,
                color: active ? AppColors.goldLight : Colors.transparent,
              ),
        );
      }),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final GameProvider gp;
  const _StatsCard({required this.gp});

  @override
  Widget build(BuildContext context) {
    final m = gp.timeLimit - gp.timeRemaining;
    final timeTaken = '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _StatRow(label: '최종 점수', value: '${gp.score}점', highlight: true),
          const Divider(color: Color(0xFF2E2A55), height: 20),
          _StatRow(label: '소요 시간', value: timeTaken),
          _StatRow(label: '실수 횟수', value: '${gp.mistakes}회'),
          _StatRow(label: '이동 횟수', value: '${gp.moves}회'),
          _StatRow(label: '최고 콤보', value: '×${gp.maxCombo}'),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 20 : 14,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.gold : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final int level;
  final int stage;
  final int? nextStage;
  final int? nextLevel;
  final bool won;

  const _ActionButtons({
    required this.level,
    required this.stage,
    required this.nextStage,
    required this.nextLevel,
    required this.won,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (won && (nextStage != null || nextLevel != null))
          _GradientButton(
            label: nextStage != null ? '다음 스테이지 →' : '다음 레벨 →',
            gradient: AppColors.goldGradient,
            onTap: () {
              AudioService.instance.playUIClick();
              final nl = nextStage != null ? level : nextLevel!;
              final ns = nextStage ?? 1;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GameScreen(level: nl, stage: ns)),
              );
            },
          ).animate(delay: 700.ms).fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 12),
        _GradientButton(
          label: '다시 하기',
          gradient: AppColors.primaryGradient,
          onTap: () {
            AudioService.instance.playUIClick();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameScreen(level: level, stage: stage)),
            );
          },
        ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            AudioService.instance.playUIClick();
            Navigator.popUntil(context, (r) => r.isFirst);
          },
          child: const Text(
            '메인 메뉴',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ).animate(delay: 900.ms).fadeIn(duration: 300.ms),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
