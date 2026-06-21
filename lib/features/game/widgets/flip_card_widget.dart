import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../../../core/constants/app_colors.dart';

class FlipCardWidget extends StatefulWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final double size;
  final int animationDelay;

  const FlipCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.size,
    this.animationDelay = 0,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final AnimationController _matchCtrl;
  late final Animation<double> _matchBounce;
  bool _showFront = false;
  bool _entryDone = false;

  @override
  void initState() {
    super.initState();

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220), // 빠른 플립
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);

    final isShowing = widget.card.isFlipped || widget.card.isMatched || widget.card.isHinted;
    if (isShowing) {
      _flipCtrl.value = 1.0;
      _showFront = true;
    }

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _entryCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _entryDone = true);
      }
    });

    _matchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // 1.0 → 1.28 → 0.92 → 1.0 bounce
    _matchBounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _matchCtrl, curve: Curves.easeInOut));

    if (widget.animationDelay > 0) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _entryCtrl.forward();
      });
    } else {
      _entryCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasShowing = oldWidget.card.isFlipped || oldWidget.card.isMatched || oldWidget.card.isHinted;
    final isShowing = widget.card.isFlipped || widget.card.isMatched || widget.card.isHinted;

    if (isShowing && !wasShowing) {
      _showFront = false;
      _flipCtrl.forward();
    } else if (!isShowing && wasShowing) {
      _flipCtrl.reverse();
    }

    // 카드 매칭 시 바운스 애니메이션
    if (widget.card.isMatched && !oldWidget.card.isMatched) {
      _matchCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _entryCtrl.dispose();
    _matchCtrl.dispose();
    super.dispose();
  }

  Widget _buildFlipContent(CardModel card) {
    if (_flipCtrl.isCompleted) return _CardFront(card: card, size: widget.size);
    if (_flipCtrl.isDismissed) return _CardBack(size: widget.size);

    // 2D scale-X 플립 — 투시 행렬 없이 어핀 변환 (saveLayer 없음)
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, _) {
        final t = _flipAnim.value;
        final isFront = t > 0.5;
        if (isFront != _showFront) _showFront = isFront;
        final scaleX = isFront ? (t - 0.5) * 2.0 : 1.0 - t * 2.0;
        return Transform(
          transform: Matrix4.diagonal3Values(scaleX, 1.0, 1.0),
          alignment: Alignment.center,
          child: isFront
              ? _CardFront(card: card, size: widget.size)
              : _CardBack(size: widget.size),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final canTap = !card.isMatched && !card.isFlipped && widget.onTap != null;
    final flipContent = _buildFlipContent(card);
    final tappable = GestureDetector(
      onTap: canTap ? widget.onTap : null,
      child: flipContent,
    );

    // 매칭 바운스 (항상 포함 — value=0 일 때 scale=1.0 이므로 시각적 변화 없음)
    final bounced = AnimatedBuilder(
      animation: _matchCtrl,
      builder: (_, child) => Transform.scale(scale: _matchBounce.value, child: child),
      child: tappable,
    );

    if (_entryDone) return bounced;

    // 진입 스케일 애니메이션 (Opacity 없음 → saveLayer 없음)
    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) => Transform.scale(scale: _entryScale.value, child: child),
      child: bounced,
    );
  }
}

class _CardBack extends StatelessWidget {
  final double size;
  const _CardBack({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: AppColors.cardBackGradient,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size * 1.3),
            painter: _CardPatternPainter(),
          ),
          Container(
            width: size * 0.44,
            height: size * 0.44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const spacing = 12.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardFront extends StatelessWidget {
  final CardModel card;
  final double size;

  const _CardFront({required this.card, required this.size});

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.cardGradients;
    final idx = card.content.gradientIndex % gradients.length;
    final grad = gradients[idx];

    Color borderColor = Colors.white.withValues(alpha: 0.2);
    List<BoxShadow> shadows = [
      BoxShadow(
        color: grad[0].withValues(alpha: 0.4),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    if (card.isMatched) {
      borderColor = AppColors.cardMatched;
      shadows = [
        BoxShadow(
          color: AppColors.cardMatched.withValues(alpha: 0.7),
          blurRadius: 18,
          spreadRadius: 3,
          offset: const Offset(0, 0),
        ),
      ];
    } else if (card.isHinted) {
      borderColor = AppColors.gold;
      shadows = [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.7),
          blurRadius: 18,
          spreadRadius: 3,
        ),
      ];
    }

    return Container(
      width: size,
      height: size * 1.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: card.content.solidColor != null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: grad,
              ),
        color: card.content.solidColor,
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.content.display,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: card.content.isEmoji ? size * 0.42 : size * 0.38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
          if (card.isMatched) ...[
            const SizedBox(height: 4),
            const Icon(Icons.check_circle, color: Colors.white, size: 14),
          ],
        ],
      ),
    );
  }
}
