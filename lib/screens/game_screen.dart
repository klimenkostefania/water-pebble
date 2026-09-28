import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/hydration_store.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/pebble_vessel.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/secondary_button.dart';

/// "Quick Add" — the action screen. One tap is one glass.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.store,
    required this.onBack,
    required this.onFinish,
    required this.onSettings,
  });

  final HydrationStore store;
  final VoidCallback onBack;
  final ValueChanged<bool> onFinish;
  final VoidCallback onSettings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  Timer? _passive;
  Timer? _shortStop;
  Timer? _goalStop;

  bool _engaged = false;
  bool _finished = false;
  double _fromProgress = 0;
  double _toProgress = 0;

  @override
  void initState() {
    super.initState();

    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.waveMs),
    );
    _fromProgress = widget.store.progress;
    _toProgress = widget.store.progress;

    // Nobody touches the screen: give the capture pass plenty of time on the
    // vessel before the result takes over.
    _passive = Timer(
      const Duration(milliseconds: AppConfig.idlePassiveMs),
      _finish,
    );
  }

  @override
  void dispose() {
    _passive?.cancel();
    _shortStop?.cancel();
    _goalStop?.cancel();
    _wave.dispose();
    super.dispose();
  }

  void _finish() {
    if (_finished || !mounted) {
      return;
    }
    _finished = true;
    _passive?.cancel();
    _shortStop?.cancel();
    _goalStop?.cancel();
    widget.onFinish(widget.store.goalReached);
  }

  void _addGlass() {
    if (_finished) {
      return;
    }

    try {
      HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics are optional.
    }

    _fromProgress = widget.store.progress;
    widget.store.addGlass();
    _toProgress = widget.store.progress;
    _wave.forward(from: 0);

    if (!_engaged) {
      _engaged = true;
      _passive?.cancel();
      // Armed exactly once: shorter than the harness tap interval, so a result
      // always surfaces after the first glass.
      _shortStop = Timer(
        const Duration(milliseconds: AppConfig.idleAfterFirstTapMs),
        _finish,
      );
    }

    if (widget.store.goalReached) {
      _goalStop?.cancel();
      _goalStop = Timer(
        const Duration(milliseconds: AppConfig.goalReachedDelayMs),
        _finish,
      );
    }
  }

  void _undo() {
    if (_finished || !widget.store.canUndo) {
      return;
    }
    _fromProgress = widget.store.progress;
    widget.store.undo();
    _toProgress = widget.store.progress;
    _wave.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final HydrationStore store = widget.store;
    final double width = MediaQuery.of(context).size.width;
    final double vessel = math.min(width - 88, 300);

    return AppBackground(
      asset: AppAssets.bgGame,
      overlay: const <Color>[Color(0xCCF2FBFF), Color(0xE0E3F4FB)],
      bubbles: true,
      child: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                ScreenHeader(title: 'QUICK ADD',
                  titleSize: 13,
                  titleSpacing: 2.6,
                  centerTitle: true,
                  onBack: widget.onBack,
                  trailing: _goalPill(store),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 186),
                    child: AnimatedBuilder(
                      animation: _wave,
                      builder: (BuildContext context, Widget? _) {
                        final double t = Curves.easeOutCubic.transform(
                          _wave.value,
                        );
                        final double progress =
                            _fromProgress + (_toProgress - _fromProgress) * t;
                        return _vesselArea(store, vessel, progress, t);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PrimaryButton(
                    label: 'TAP TO ADD',
                    icon: Icons.add_rounded,
                    height: 60,
                    radius: 22,
                    letterSpacing: 1.4,
                    onTap: _addGlass,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryButton(
                          label: 'UNDO',
                          icon: Icons.remove_rounded,
                          enabled: store.canUndo,
                          onTap: _undo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'GOAL',
                          icon: Icons.flag_outlined,
                          onTap: widget.onSettings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalPill(HydrationStore store) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.flag_rounded, size: 18, color: AppColors.highlight),
          const SizedBox(width: 6),
          Text(
            '${store.goalMl} ml',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vesselArea(
    HydrationStore store,
    double vessel,
    double progress,
    double t,
  ) {
    final bool animating = _wave.isAnimating;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _dropletRow(store),
        const SizedBox(height: 18),
        SizedBox(
          width: vessel,
          height: vessel,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PebbleVessel(
                progress: progress,
                wavePhase: animating ? t : 0,
                size: vessel,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${store.todayMl}',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'ML TODAY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (animating)
                Positioned(
                  top: vessel * 0.20 - 40 * t,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Text(
                      '+${store.glassMl}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '+${store.glassMl} ML PER TAP',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _dropletRow(HydrationStore store) {
    final int done = store.glassesDone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < 6; i++)
          Padding(
            padding: EdgeInsets.only(right: i == 5 ? 0 : 10),
            child: Opacity(
              opacity: done > i ? 1.0 : 0.26,
              child: Image.asset(
                AppAssets.spriteDroplet,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stack) =>
                        const SizedBox(width: 22, height: 22),
              ),
            ),
          ),
      ],
    );
  }
}
