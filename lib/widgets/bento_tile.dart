import 'package:flutter/material.dart';

import '../theme.dart';

/// White card that forms the bento grid. Content is clipped to the radius so
/// decorative sprites can never poke past a rounded corner.
class BentoTile extends StatelessWidget {
  const BentoTile({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.radius = 26,
    this.onTap,
  });

  final Widget child;
  final double? height;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? tap = onTap;

    Widget body = Padding(padding: padding, child: child);

    if (tap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(onTap: tap, child: body),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: body,
      ),
    );
  }
}
