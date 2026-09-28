import 'package:flutter/material.dart';

import '../theme.dart';

/// Compact round pebble with a water fill — the hero of the Today hub.
class PebbleGauge extends StatelessWidget {
  const PebbleGauge({
    super.key,
    required this.progress,
    required this.ml,
    required this.goalMl,
    this.size = 164,
  });

  final double progress;
  final int ml;
  final int goalMl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final int pct = goalMl <= 0 ? 0 : (ml * 100 / goalMl).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(painter: _GaugePainter(progress: progress)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$ml / $goalMl ml',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path circle = Path()..addOval(rect);

    canvas.drawCircle(
      rect.center,
      size.width / 2,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0xFFF7FCFE), Color(0xFFE3F4FB)],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(circle);

    final double level = size.height * (1 - progress);
    if (progress > 0) {
      canvas.drawRect(
        Rect.fromLTRB(0, level, size.width, size.height),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.accent.withValues(alpha: 0.85),
              AppColors.primary.withValues(alpha: 0.92),
            ],
          ).createShader(rect),
      );
    }

    // Goal marker: a dashed line at the top of the pebble while short of 100%.
    if (progress < 1) {
      final Paint dash = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35)
        ..strokeWidth = 2;
      const double dashW = 8;
      const double gapW = 7;
      double x = 10;
      while (x < size.width - 10) {
        canvas.drawLine(Offset(x, 14), Offset(x + dashW, 14), dash);
        x += dashW + gapW;
      }
    }

    // Highlight in the upper-left sector.
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.16, size.height * 0.12, size.width * 0.34,
          size.height * 0.18),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );

    canvas.restore();

    canvas.drawCircle(
      rect.center,
      size.width / 2 - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.primary.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
