import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';
import '../../game/screens/game_screen.dart';

class StageSelectScreen extends StatelessWidget {
  final int level;
  const StageSelectScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final config = LevelData.levels[level - 1];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(level: level, config: config),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, i) {
                      return _StageCard(
                        stage: i + 1,
                        level: level,
                        delay: i * 50,
                        onTap: () {
                          AudioService.instance.playUIClick();
                          Navigator.push(context, _gameRoute(level, i + 1));
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _gameRoute(int level, int stage) => PageRouteBuilder(
    pageBuilder: (_, a, __) => GameScreen(level: level, stage: stage),
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: a, curve: Curves.easeOut),
          ),
          child: child,
        )),
    transitionDuration: const Duration(milliseconds: 350),
  );
}

class _TopBar extends StatelessWidget {
  final int level;
  final LevelConfig config;

  const _TopBar({required this.level, required this.config});

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.cardGradients[(level - 1) * 3 % AppColors.cardGradients.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
              ),
              ShaderMask(
                shaderCallback: (b) => LinearGradient(colors: gradient).createShader(b),
                child: Text(
                  'Level $level — ${config.name}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '${config.gridCols}×${config.gridRows} 그리드  •  ${config.pairCount}쌍  •  ${config.timeLimit}초',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final int stage;
  final int level;
  final int delay;
  final VoidCallback onTap;

  const _StageCard({
    required this.stage,
    required this.level,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeName = LevelData.stageName(stage);
    final themeIcon = LevelData.stageIcon(stage);
    final gradIdx = ((stage - 1) + level) % AppColors.cardGradients.length;
    final gradient = AppColors.cardGradients[gradIdx];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          border: Border.all(
            color: gradient[0].withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 8,
              child: Opacity(
                opacity: 0.12,
                child: Text(themeIcon, style: const TextStyle(fontSize: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stage $stage',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(themeIcon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        themeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut, duration: 300.ms);
  }
}
