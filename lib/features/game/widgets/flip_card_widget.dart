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
  bool _showFront = false;
  bool _entryDone = false;

  @override
  void initState() {
    super.initState();

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic);

    final isShowing = widget.card.isFlipped || widget.card.isMatched || widget.card.isHinted;
    if (isShowing) {
      _flipCtrl.value = 1.0;
      _showFront = true;
    }

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );

    _entryCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _entryDone = true);
      }
    });

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
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _buildFlipContent(CardModel card) {
    if (_flipCtrl.isCompleted) return _CardFront(card: card, size: widget.size);
    if (_flipCtrl.isDismissed) return _CardBack(size: widget.size);

    // 2D scale-X flip: no perspective matrix → no compositing layer in CanvasKit
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, _) {
        final t = _flipAnim.value;
        final isFront = t > 0.5;
        if (isFront != _showFront) _showFront = isFront;
        // First half [0→0.5]: scaleX 1→0 (back face narrows)
        // Second half [0.5→1]: scaleX 0→1 (front face widens)
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

    if (_entryDone) return tappable;

    // Scale-only entry (no Opacity widget → no compositing layer in CanvasKit)
    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) =>
          Transform.scale(scale: _entryScale.value, child: child),
      child: tappable,
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
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                  color: AppColors.primary.withOpacity(0.6),
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
      ..color = AppColors.primary.withOpacity(0.08)
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

    Color borderColor = Colors.white.withOpacity(0.2);
    List<BoxShadow> shadows = [
      BoxShadow(
        color: grad[0].withOpacity(0.4),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    if (card.isMatched) {
      borderColor = AppColors.cardMatched;
      shadows = [
        BoxShadow(
          color: AppColors.cardMatched.withOpacity(0.6),
          blurRadius: 16,
          spreadRadius: 2,
          offset: const Offset(0, 0),
        ),
      ];
    } else if (card.isHinted) {
      borderColor = AppColors.gold;
      shadows = [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.7),
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
                  color: Colors.black.withOpacity(0.4),
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
