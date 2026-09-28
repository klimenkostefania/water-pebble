import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/droplet_field.dart';

/// Branded splash. A wall-clock timer drives the hand-off, never an animation
/// listener — animation scale is zero on CI emulators.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _handoff;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.loaderIntroMs),
    );

    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.9), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _intro,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
          ),
        );

    _intro.forward();

    _handoff = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs),
      () {
        if (mounted) {
          widget.onDone();
        }
      },
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.loaderTop,
            AppColors.primaryDark,
            AppColors.loaderMid,
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.bgLoader),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: DropletFieldPainter()),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: _pebble(),
                      ),
                    ),
                    const SizedBox(height: 34),
                    FadeTransition(
                      opacity: _fade,
                      child: const Text(
                        'WATER PEBBLE',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                          color: AppColors.textOnDark,
                          shadows: <Shadow>[
                            Shadow(color: Color(0x8C7ED6DF), blurRadius: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SlideTransition(
                      position: _slide,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Text(
                          'SIP BY SIP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                            color: AppColors.accent.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    FadeTransition(
                      opacity: _fade,
                      child: SizedBox(
                        width: 168,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  AppColors.accent,
                                  AppColors.highlight,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _fade,
                      child: const Text(
                        'LOADING…',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: AppColors.loaderHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pebble() {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: <Color>[AppColors.accent, AppColors.primary],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          AppAssets.spriteDroplet,
          width: 68,
          height: 68,
          fit: BoxFit.contain,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) =>
                  const SizedBox(width: 68, height: 68),
        ),
      ),
    );
  }
}
