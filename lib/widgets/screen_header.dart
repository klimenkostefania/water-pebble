import 'package:flutter/material.dart';

import '../theme.dart';

/// Round 44x44 icon button used for back / settings affordances.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.background = Colors.white,
    this.backgroundAlpha = 0.86,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color background;
  final double backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

/// Shared header for every screen. Keeps the 44 px status-bar inset in one
/// place so no screen slides under the system bar.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.onBack,
    this.trailing,
    this.titleSize = 20,
    this.titleSpacing = 0,
    this.titleColor = AppColors.textPrimary,
    this.eyebrowColor = AppColors.textSecondary,
    this.centerTitle = false,
  });

  final String title;
  final String? eyebrow;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double titleSize;
  final double titleSpacing;
  final Color titleColor;
  final Color eyebrowColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final String? brow = eyebrow;
    final VoidCallback? back = onBack;

    final Widget titleBlock = Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (brow != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              brow,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: eyebrowColor,
              ),
            ),
          ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: titleSpacing,
            color: titleColor,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 44, left: 20, right: 20, bottom: 10),
      child: SizedBox(
        height: 62,
        child: Row(
          children: <Widget>[
            if (back != null)
              CircleIconButton(icon: Icons.arrow_back_rounded, onTap: back)
            else
              const SizedBox(width: 0),
            if (back != null) const SizedBox(width: 14),
            Expanded(child: titleBlock),
            const SizedBox(width: 14),
            trailing ?? const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}
