import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Large pebble-shaped vessel. The wave only moves while a glass is being
/// poured — at rest the painter is static, so the window goes idle.
class PebbleVessel extends StatelessWidget {
  const PebbleVessel({
    super.key,
    required this.progress,
    required this.wavePhase,
    required this.size,
  });

  final double progress;
  final double wavePhase;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: CustomPaint(
        painter: WaterPainter(progress: progress, wavePhase: wavePhase),
      ),
    );
  }
}

class WaterPainter extends CustomPainter {
  const WaterPainter({required this.progress, required this.wavePhase});

  final double progress;
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    canvas.drawCircle(
      rect.center,
      size.width / 2,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0xFFFAFDFF), Color(0xFFDCEFF6)],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    if (progress > 0) {
      final double level = size.height * (1 - progress);
      final Path water = Path()..moveTo(0, level);
      const double amplitude = 7;
      for (double x = 0; x <= size.width; x += 4) {
        final double t = x / size.width;
        final double y =
            level + math.sin(t * math.pi * 4 + wavePhase * math.pi * 2) * amplitude;
        water.lineTo(x, y);
      }
      water
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        water,
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

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height * 0.13,
        size.width * 0.30,
        size.height * 0.16,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
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
  bool shouldRepaint(covariant WaterPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
}
