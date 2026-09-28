import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../theme.dart';

/// 48 px translucent companion button. Same icon metrics as [PrimaryButton].
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.foreground = AppColors.primary,
    this.fill = Colors.white,
    this.fillAlpha = 0.88,
    this.borderColor = AppColors.primary,
    this.borderAlpha = 0.22,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color foreground;
  final Color fill;
  final double fillAlpha;
  final Color borderColor;
  final double borderAlpha;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final double dim = widget.enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: dim,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: AppConfig.pressMs),
        curve: Curves.easeOut,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.fill.withValues(alpha: widget.fillAlpha),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.borderColor.withValues(alpha: widget.borderAlpha),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.enabled
                  ? () {
                      _setPressed(false);
                      widget.onTap();
                    }
                  : null,
              onTapDown: (TapDownDetails _) => _setPressed(true),
              onTapCancel: () => _setPressed(false),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(widget.icon, size: 24, color: widget.foreground),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        height: 24 / 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: widget.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
