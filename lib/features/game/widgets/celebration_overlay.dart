import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';

class CelebrationOverlay extends StatefulWidget {
  final int level;
  final int stage;
  final GameProvider gp;
  final VoidCallback onNext;

  const CelebrationOverlay({
    super.key,
    required this.level,
    required this.stage,
    required this.gp,
    required this.onNext,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final AnimationController _heroCtrl;
  late final AnimationController _starsCtrl;
  late final AnimationController _btnCtrl;
  late final List<_Particle> _particles;
  bool _navigating = false;

  static const _autoNavDelay = Duration(milliseconds: 3800);

  @override
  void initState() {
    super.initState();
    _particles = _buildParticles();

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _starsCtrl.forward();
    });

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _btnCtrl.forward();
    });

    Future.delayed(_autoNavDelay, () {
      if (mounted && !_navigating) widget.onNext();
    });
  }

  List<_Particle> _buildParticles() {
    final rng = Random();
    const colors = [
      Color(0xFFFFD700),
      Color(0xFFFF6B6B),
      Color(0xFF4FC3F7),
      Color(0xFF81C784),
      Color(0xFFFFA726),
      Color(0xFFCE93D8),
      Color(0xFFFF80AB),
      Color(0xFF80DEEA),
    ];
    return List.generate(70, (_) => _Particle(
      x: rng.nextDouble(),
      phaseOffset: rng.nextDouble(),
      speed: 0.35 + rng.nextDouble() * 0.55,
      color: colors[rng.nextInt(colors.length)],
      w: 5 + rng.nextDouble() * 8,
      h: 3 + rng.nextDouble() * 5,
      rotation: rng.nextDouble() * 2 * pi,
      rotSpeed: (rng.nextDouble() - 0.5) * 8,
      xWobble: (rng.nextDouble() - 0.5) * 0.15,
    ));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _heroCtrl.dispose();
    _starsCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final stars = widget.gp.stars;
    final score = widget.gp.score;
    final nextStage = widget.stage < 10 ? widget.stage + 1 : null;
    final nextLevel = widget.stage >= 10 && widget.level < 10 ? widget.level + 1 : null;
    final hasNext = nextStage != null || nextLevel != null;

    final heroScale = CurvedAnimation(parent: _heroCtrl, curve: Curves.elasticOut);
    final btnScale = CurvedAnimation(parent: _btnCtrl, curve: Curves.elasticOut);

    return Material(
      color: Colors.black.withValues(alpha: 0.78),
      child: Stack(
        children: [
          // 파티클 컨페티
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (context, _) => CustomPaint(
              size: size,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiCtrl.value,
              ),
            ),
          ),

          // 중앙 콘텐츠
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 트로피
                ScaleTransition(
                  scale: heroScale,
                  child: const Text('🏆', style: TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 10),

                // 클리어 텍스트
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _heroCtrl,
                    curve: const Interval(0.1, 1.0, curve: Curves.elasticOut),
                  ),
                  child: ShaderMask(
                    shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                    child: const Text(
                      '스테이지 클리어!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 별점
                _StarRow(stars: stars, ctrl: _starsCtrl),
                const SizedBox(height: 18),

                // 점수
                FadeTransition(
                  opacity: _starsCtrl,
                  child: Text(
                    '$score 점',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // 다음 단계 버튼
                ScaleTransition(
                  scale: btnScale,
                  child: GestureDetector(
                    onTap: () {
                      if (!_navigating) {
                        _navigating = true;
                        AudioService.instance.playUIClick();
                        widget.onNext();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 17),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.55),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasNext
                                ? (nextStage != null ? '다음 스테이지' : '다음 레벨')
                                : '홈으로',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int stars;
  final AnimationController ctrl;

  const _StarRow({required this.stars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i < stars;
        final anim = CurvedAnimation(
          parent: ctrl,
          curve: Interval(
            i * 0.22,
            i * 0.22 + 0.55,
            curve: Curves.elasticOut,
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: ScaleTransition(
            scale: anim,
            child: Icon(
              active ? Icons.star_rounded : Icons.star_outline_rounded,
              color: active ? AppColors.starActive : AppColors.starInactive,
              size: active ? 56 : 46,
            ),
          ),
        );
      }),
    );
  }
}

// ───── 파티클 데이터 ─────
class _Particle {
  final double x;
  final double phaseOffset;
  final double speed;
  final Color color;
  final double w;
  final double h;
  final double rotation;
  final double rotSpeed;
  final double xWobble;

  const _Particle({
    required this.x,
    required this.phaseOffset,
    required this.speed,
    required this.color,
    required this.w,
    required this.h,
    required this.rotation,
    required this.rotSpeed,
    required this.xWobble,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // 각 파티클은 phaseOffset으로 시작 타이밍 다름
      final t = ((progress + p.phaseOffset) % 1.0);
      final y = t * (size.height + 40) - 20; // -20 위에서 시작
      final x = (p.x + sin(t * 2 * pi) * p.xWobble) * size.width;
      final rot = p.rotation + t * p.rotSpeed;

      paint.color = p.color.withValues(alpha: t < 0.85 ? 1.0 : (1.0 - t) / 0.15);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
