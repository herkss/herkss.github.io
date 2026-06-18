import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../levels/screens/level_select_screen.dart';
import '../../multiplayer/screens/multi_lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.playMenuBgm();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _BgPainter(_bgCtrl.value),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildTitle(),
                const Spacer(flex: 1),
                _buildCardPreview(),
                const Spacer(flex: 1),
                _buildButtons(context),
                const Spacer(flex: 2),
                _buildFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.goldGradient.createShader(b),
          child: const Text(
            'MEMORY',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 8,
              height: 1,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
        ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: const Text(
            'CARD',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 16,
              height: 1,
            ),
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
        const SizedBox(height: 8),
        const Text(
          '기억력 카드 매칭 게임',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildCardPreview() {
    final items = ['🐶', '🌸', '⭐', '🎮', '🦋', '💎'];
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(items.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _MiniCard(emoji: items[i], delay: i * 80),
          );
        }),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _MainButton(
            label: '솔로 플레이',
            icon: '🎯',
            gradient: AppColors.goldGradient,
            delay: 500,
            onTap: () {
              AudioService.instance.playUIClick();
              Navigator.push(context, _pageRoute(const LevelSelectScreen()))
                  .then((_) => AudioService.instance.playMenuBgm());
            },
          ),
          const SizedBox(height: 14),
          _MainButton(
            label: '멀티 플레이',
            icon: '👥',
            gradient: AppColors.primaryGradient,
            delay: 600,
            onTap: () {
              AudioService.instance.playUIClick();
              Navigator.push(context, _pageRoute(const MultiLobbyScreen()))
                  .then((_) => AudioService.instance.playMenuBgm());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      '10 레벨 × 10 스테이지 = 100 도전',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        letterSpacing: 1,
      ),
    ).animate(delay: 800.ms).fadeIn(duration: 500.ms);
  }

  PageRouteBuilder _pageRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: SlideTransition(
          position: Tween(begin: const Offset(0.1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
          child: child,
        )),
    transitionDuration: const Duration(milliseconds: 350),
  );
}

class _MiniCard extends StatefulWidget {
  final String emoji;
  final int delay;
  const _MiniCard({required this.emoji, required this.delay});

  @override
  State<_MiniCard> createState() => _MiniCardState();
}

class _MiniCardState extends State<_MiniCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2400 + widget.delay * 50),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, sin(_ctrl.value * pi) * -6),
        child: Container(
          width: 52,
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.cardGradients[widget.delay ~/ 80 % AppColors.cardGradients.length],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), curve: Curves.elasticOut);
  }
}

class _MainButton extends StatelessWidget {
  final String label;
  final String icon;
  final LinearGradient gradient;
  final int delay;
  final VoidCallback onTap;

  const _MainButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.delay,
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0818), Color(0xFF1A0E3F), Color(0xFF0A1628)],
        ).createShader(rect),
    );

    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.6;
    final rng = Random(42);
    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * 2 * pi;
      final r = 30 + rng.nextDouble() * 60;
      final opacity = 0.04 + 0.06 * sin(t * 2 * pi + phase);
      paint.color = AppColors.primary.withValues(alpha: opacity.clamp(0.0, 1.0));

      final cx = x + sin(t * 2 * pi + phase) * 20;
      final cy = y + cos(t * 2 * pi + phase * 1.3) * 15;
      _drawRoundRect(canvas, cx, cy, r * 0.65, r * 0.85, 8, paint);
    }
  }

  void _drawRoundRect(Canvas c, double x, double y, double w, double h, double r, Paint p) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        Radius.circular(r),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
