import 'package:flutter/material.dart';

import '../theme.dart';

/// Layered screen background: AI artwork -> gradient overlay -> decorative
/// bubbles -> content. Never a flat fill.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.asset,
    this.imageOpacity = 1.0,
    this.overlay = const <Color>[Colors.transparent, Colors.transparent],
    this.baseGradient = const <Color>[AppColors.bg, AppColors.bgAlt],
    this.bubbles = false,
    this.bubbleColor = AppColors.accent,
  });

  final Widget child;
  final String? asset;
  final double imageOpacity;
  final List<Color> overlay;
  final List<Color> baseGradient;
  final bool bubbles;
  final Color bubbleColor;

  @override
  Widget build(BuildContext context) {
    final String? bg = asset;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: baseGradient,
        ),
      ),
      child: Stack(
        children: <Widget>[
          if (bg != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bg),
                    fit: BoxFit.cover,
                    opacity: imageOpacity,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: overlay,
                ),
              ),
            ),
          ),
          if (bubbles) ...<Widget>[
            _bubble(top: 118, right: 16, size: 120, alpha: 0.10),
            _bubble(top: 226, left: 12, size: 72, alpha: 0.08),
            _bubble(bottom: 130, right: 30, size: 48, alpha: 0.12),
          ],
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _bubble({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bubbleColor.withValues(alpha: alpha),
          ),
        ),
      ),
    );
  }
}
