import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../theme.dart';

/// Tall gradient CTA. Icon is always 24 px and the label line-height matches
/// it, so the row never drifts off the baseline.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradient = const <Color>[AppColors.primary, AppColors.accent],
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.shadowColor = AppColors.primary,
    this.height = 58,
    this.radius = 20,
    this.letterSpacing = 1.2,
    this.backgroundAsset,
    this.backgroundOpacity = 0.35,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;
  final Color textColor;
  final Color iconColor;
  final Color shadowColor;
  final double height;
  final double radius;
  final double letterSpacing;
  final String? backgroundAsset;
  final double backgroundOpacity;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final String? bgAsset = widget.backgroundAsset;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: AppConfig.pressMs),
      curve: Curves.easeOut,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: widget.gradient,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: widget.shadowColor.withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            children: <Widget>[
              if (bgAsset != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: widget.backgroundOpacity,
                    child: Image.asset(
                      bgAsset,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stack,
                          ) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _setPressed(false);
                      widget.onTap();
                    },
                    onTapDown: (TapDownDetails _) => _setPressed(true),
                    onTapCancel: () => _setPressed(false),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            widget.icon,
                            size: 24,
                            color: widget.iconColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 16,
                              height: 24 / 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: widget.letterSpacing,
                              color: widget.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
