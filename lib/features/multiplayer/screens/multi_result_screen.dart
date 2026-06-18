import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/multi_game_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import 'multi_game_screen.dart';

class MultiResultScreen extends StatelessWidget {
  final int level;
  final int stage;
  final int score1;
  final int score2;
  final int pairs1;
  final int pairs2;
  final int winner; // 0 = 무승부, 1 = P1, 2 = P2

  const MultiResultScreen({
    super.key,
    required this.level,
    required this.stage,
    required this.score1,
    required this.score2,
    required this.pairs1,
    required this.pairs2,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
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
                  _WinnerHeader(winner: winner),
                  const SizedBox(height: 36),
                  _ScoreBoard(
                    score1: score1,
                    score2: score2,
                    pairs1: pairs1,
                    pairs2: pairs2,
                    winner: winner,
                  ),
                  const SizedBox(height: 40),
                  _ActionButtons(level: level, stage: stage),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Winner Header ────────────────────────────────────────────────────────────

class _WinnerHeader extends StatelessWidget {
  final int winner;
  const _WinnerHeader({required this.winner});

  @override
  Widget build(BuildContext context) {
    final emoji = winner == 0 ? '🤝' : '🏆';
    final label = winner == 0 ? '무승부!' : 'P$winner 승리!';
    final gradient = winner == 1
        ? AppColors.primaryGradient
        : winner == 2
            ? AppColors.goldGradient
            : const LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFFBDBDBD)]);

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 80))
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (b) => gradient.createShader(b),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        )
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}

// ─── Score Board ──────────────────────────────────────────────────────────────

class _ScoreBoard extends StatelessWidget {
  final int score1;
  final int score2;
  final int pairs1;
  final int pairs2;
  final int winner;

  const _ScoreBoard({
    required this.score1,
    required this.score2,
    required this.pairs1,
    required this.pairs2,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PlayerResultCard(
            playerNum: 1,
            score: score1,
            pairs: pairs1,
            isWinner: winner == 1,
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlayerResultCard(
            playerNum: 2,
            score: score2,
            pairs: pairs2,
            isWinner: winner == 2,
            gradient: AppColors.goldGradient,
          ),
        ),
      ],
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

class _PlayerResultCard extends StatelessWidget {
  final int playerNum;
  final int score;
  final int pairs;
  final bool isWinner;
  final LinearGradient gradient;

  const _PlayerResultCard({
    required this.playerNum,
    required this.score,
    required this.pairs,
    required this.isWinner,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isWinner
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradient.colors.first.withValues(alpha: 0.25),
                  gradient.colors.last.withValues(alpha: 0.10),
                ],
              )
            : null,
        color: isWinner ? null : AppColors.surface,
        border: Border.all(
          color: isWinner
              ? gradient.colors.first.withValues(alpha: 0.7)
              : AppColors.primary.withValues(alpha: 0.2),
          width: isWinner ? 2 : 1,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          if (isWinner) ...[
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 28),
            const SizedBox(height: 6),
          ],
          ShaderMask(
            shaderCallback: (b) => gradient.createShader(b),
            child: Text(
              'P$playerNum',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isWinner ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '점',
            style: TextStyle(
              fontSize: 12,
              color: isWinner ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$pairs 쌍 획득',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final int level;
  final int stage;
  const _ActionButtons({required this.level, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GradientButton(
          label: '다시 하기',
          gradient: AppColors.primaryGradient,
          onTap: () {
            AudioService.instance.playUIClick();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => MultiGameProvider(),
                  child: MultiGameScreen(level: level, stage: stage),
                ),
              ),
            );
          },
        ).animate(delay: 700.ms).fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
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
        ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
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
